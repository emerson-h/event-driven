module EventDriven
  # A basic event dispatcher
  class Dispatcher
    attr_reader :events, :sorted_listeners
    private :events, :sorted_listeners

    def initialize
      @events = Hash.new do |hash, event_name|
        hash[event_name] = Hash.new do |events_by_priority, priority|
          events_by_priority[priority] = Array.new
        end
      end
      @sorted_listeners = Hash.new do |hash, event_name|
        hash[event_name] = Array.new
      end
    end

    # Adds a listener to a specific event
    #
    # @param event_name [String, Symbol] the name of the desired event
    # @param listener [Callable] the listener to add to the event. Should implement #call, which will be invoked with
    #   event and event_name when an event is dispatched
    # @param priority [Fixnum] optional
    def add_listener(event_name:, listener:, priority: 0)
      events[event_name][priority] << listener
      update_sorted_listeners(event_name)
    end


    # Does an event have any listeners
    #
    # @param event_name [String, Symbol] the name of the desired event
    #
    # @return [Boolean] true if there are listeners
    def listeners_for?(event_name)
      events[event_name].any? do |events_by_priority|
        events_by_priority.length > 0
      end
    end

    # Get the priority a listener has for a given event name
    #
    # @param event_name [String, Symbol] the name of the desired event
    # @param listener [Callable] the desired listener
    #
    # @return [Fixnum, nil] returns the priority or nil if the listener is not subscribed to the event
    def priority(event_name:, listener:)
      prioritized_events = events[event_name]
      prioritized_events.each_pair do |priority, listeners|
        return priority if listeners.include?(listener)
      end
    end

    # Dispatches the passed event to all subscribed listeners in priority order
    #
    # @param event_name [String, Symbol] the name of the event being dispatched
    # @param event [EventDriven::Event] the event to dispatch along with the name
    #
    # @return [void]
    def dispatch(event_name:, event: EventDriven::Event.new)
      listeners_for(event_name).each do |listener|
        listener.call(event, event_name) unless event.stopped?
      end
    end

    # All of the listeners for the passed event name
    #
    # @param event_name [String, Symbol] the name of the desired event
    #
    # @return [Array<Callable>] the listeners for the provided event sorted by priority
    def listeners_for(event_name)
      unless sorted_listeners.has_key?(event_name)
        update_sorted_listeners(event_name)
      end
      sorted_listeners[event_name]
    end

    # Removes a listener from a specified event name
    #
    # @param event_name [String, Symbol] the name of the desired event
    # @param listener [Callable] the listener to remove
    #
    # @return [void]
    def remove_listener(event_name:, listener:)
      events[event_name].each_value do |listeners|
        listeners.delete(listener)
      end
      update_sorted_listeners(event_name)
    end

    private def update_sorted_listeners(event_name)
      sorted_listeners.delete(event_name)
      sorted_pair_iterator = events[event_name].each_pair.sort { |pair_a, pair_b| -pair_a[0] <=> -pair_b[0] }
      sorted_listeners[event_name] = sorted_pair_iterator.map { |priority_listeners_list| priority_listeners_list[1..-1] }.flatten
    end
  end
end
