module EventDriven
  # The most basic event. Does not store information, but allows clients to stop propagation
  class Event
    # Stops the event from being sent to other listeners
    #
    # @return [void]
    def stop_propagation
      @stopped = true
    end

    # Whether the event has been stopped
    #
    # @return [Boolean] true if the event was stopped
    def stopped?
      !!@stopped
    end
  end
end
