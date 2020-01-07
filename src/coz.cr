module Coz
  enum Type
    Throughput = 1
    Begin      = 2
    End        = 3
  end

  @[Extern]
  struct Counter
    getter count : LibC::SizeT
    getter backoff : LibC::SizeT

    def initialize(@count : LibC::SizeT, @backoff : LibC::SizeT)
    end

    alias GetCounterFunction = Proc(LibC::Int, LibC::Char*, Counter*)

    @@get_counter = begin
      addr = LibC.dlsym(LibC::RTLD_DEFAULT, "_coz_get_counter")
      GetCounterFunction.new(addr, Pointer(Void).null) if addr
    end

    def self.get(type : Type, name : String) : Counter*
      if get_counter = @@get_counter
        get_counter.call(LibC::Int.new(type), name.to_unsafe)
      else
        Pointer(Counter).malloc(1, Counter.new(0, 0))
      end
    end

    def increment : Nil
      Atomic::Ops.atomicrmw(:add, pointerof(@count), 1, :monotonic, false)
    end

    macro increment(type, name)
      ::Coz.__cache(:%counter.to_i) { ::Coz::Counter.get({{type}}, {{name}}) }
    end
  end

  @@counters = Pointer(Counter*).malloc(1)
  @@counters_size = 1

  # :nodoc:
  def self.__cache(token : Int32) : Nil
    unless token < @@counters_size
      @@counters = @@counters.realloc(token + 1)
      @@counters_size = token + 1
    end

    counter = @@counters[token]
    counter = @@counters[token] = yield if counter.null?
    counter.value.increment
  end

  macro progress
    ::Coz.__cache(:%counter.to_i) { ::Coz::Counter.get(:throughput, "#{__FILE__}:#{__LINE__}") }
  end

  macro progress(name)
    ::Coz.__cache(:%counter.to_i) { ::Coz::Counter.get(:throughput, {{name}}) }
  end

  macro begin(name)
    ::Coz.__cache(:%counter.to_i) { ::Coz::Counter.get(:begin, {{name}}) }
  end

  macro end(name)
    ::Coz.__cache(:%counter.to_i) { ::Coz::Counter.get(:end, {{name}}) }
  end

  macro latency(name)
    ::Coz.begin({{name}})
    begin
      {{yield}}
    ensure
      ::Coz.end({{name}})
    end
  end
end
