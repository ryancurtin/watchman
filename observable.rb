class Observer
  # supporting different types of events a la Backbone
  # change, sync, etc

  attr_accessor :parent, :name, :events

  def initialize(parent)
    @events = {}
    @parent = parent
  end

  def add_event(name, callback, *args)
    @events[name] ||= []
    @events[name] << [callback, args]
  end

  def trigger_event(name)
    if @events[name]
      @events[name].each do |e|
        e[1] = [e[1]] unless e[1].class == Array
        args = e[1].map!{|arg| (arg.class == Hash && arg[:var]) ? @parent.instance_variable_get(arg[:var]) : arg }
        if e[1].empty?
          return @parent.instance_variable_get(e[0][:var])
        else
          @parent.send(e[0], *args)
        end
      end

    else
      return false
    end
  end

end

module Observable
  attr_accessor :observer, :events

# Mixes into any Ruby object
# Need to be added to any Ruby class
# Array of callbacks to fire on 'change' event - similar to Javscript

  def add_observer
    @observer = Observer.new(self)
  end

  def bind(name, callback, *args)
    return false unless @observer
    @observer.add_event(name, callback, *args)
  end

  def trigger(name)
    return false unless @observer.events[name]
    @observer.trigger_event(name)
  end

end

class Example
  include Observable

  attr_accessor :abc

  def initialize
    @abc = 1
  end

  def incr
    @abc += 1
    trigger('change')
  end

  def watchman(v)
    puts "Variable has changed to: #{v}"
  end

end

ex = Example.new
ex.add_observer
ex.bind('change', 'watchman', {:var => "@abc"})
ex.incr
