describe EventDriven::Dispatcher do
  let(:listener) do
    double 'SomethingCallable',
      call: true
  end

  let(:listener_2) do
    double 'SomethingCallable',
      call: true
  end

  describe '#add_listener' do
    it 'adds the listener to the passed event name' do
      expect {
        subject.add_listener(event_name: :foo, listener: listener)
      }.to change { subject.listeners_for?(:foo) }.from(false).to(true)
    end
    it 'defaults the priority to 0' do
      subject.add_listener(event_name: :foo, listener: listener)
      expect(subject.priority(event_name: :foo, listener: listener)).to eql 0
    end
    it 'allows the user to set the priority to something other than 0' do
      subject.add_listener(event_name: :foo, listener: listener, priority: 2)
      expect(subject.priority(event_name: :foo, listener: listener)).to eql 2
    end
  end

  describe '#dispatch' do
    before do
      subject.add_listener(event_name: :foo, listener: listener)
      subject.add_listener(event_name: :foo, listener: listener_2)
    end

    context 'called with only an event name' do
      it 'dispatches a new empty event to all listeners' do
        subject.dispatch(event_name: :foo)
        expect(listener).to have_received(:call).with(instance_of(EventDriven::Event), :foo)
        expect(listener_2).to have_received(:call).with(instance_of(EventDriven::Event), :foo)
      end
    end

    context 'listeners have priorities' do
      let(:dispatcher) do
        described_class.new
      end

      before do
        dispatcher.add_listener(event_name: :foo, listener: listener)
        dispatcher.add_listener(event_name: :foo, listener: listener_2, priority: 3)
      end

      it 'dispatches events from highest to lowest priority' do
        dispatcher.dispatch(event_name: :foo)
        expect(listener_2).to have_received(:call).ordered
        expect(listener).to have_received(:call).ordered
      end
    end

    context 'a listener stops propagation of an event' do
      let(:dispatcher) do
        described_class.new
      end
      let(:listener_3) do
        stub = double('SomeCallable')
        allow(stub).to receive(:call) do |event, _event_name|
          event.stop_propagation
        end
        stub
      end

      before do
        dispatcher.add_listener(event_name: :foo, listener: listener)
        dispatcher.add_listener(event_name: :foo, listener: listener_2, priority: 3)
        dispatcher.add_listener(event_name: :foo, listener: listener_3, priority: 1)
      end

      it 'does not call listeners after the one which stops propagation' do
        dispatcher.dispatch(event_name: :foo)
        expect(listener_2).to have_received(:call).ordered
        expect(listener_3).to have_received(:call).ordered
        expect(listener).not_to have_received(:call)
      end
    end
  end

  describe '#listeners_for?' do
    before do
      subject.add_listener(event_name: :bar, listener: listener)
    end
    context 'the event name has listeners' do
      it 'returns true' do
        expect(subject.listeners_for?(:bar)).to be_truthy
      end
    end
    context 'the event name has no listeners' do
      it 'returns false' do
        expect(subject.listeners_for?(:foo)).to be_falsey
      end
    end
  end


  describe '#listeners_for' do
    before do
      subject.add_listener(event_name: :bar, listener: listener)
      subject.add_listener(event_name: :foo, listener: listener_2)
    end

    it 'returns the listeners for the event name' do
      expect(subject.listeners_for(:foo)).to eql [listener_2]
    end

    context 'for a key that has no listeners' do
      it 'returns an empty array' do
        expect(subject.listeners_for(:baz)).to eql []
      end
    end

    context 'listeners have priorities' do
      let(:listener_3) do
        double 'SomeCallable',
          call: true
      end

      before do
        subject.add_listener(event_name: :foo, listener: listener_3, priority: 10)
      end

      it 'returns listeners in descending priority order' do
        expect(subject.listeners_for(:foo)).to eql [listener_3, listener_2]
      end
    end
  end

  describe '#remove_listener' do
    before do
      subject.add_listener(event_name: :foo, listener: listener)
      subject.add_listener(event_name: :foo, listener: listener_2)
    end

    it 'removes the listener from the list' do
      expect {
        subject.remove_listener(event_name: :foo, listener: listener_2)
      }.to change { subject.listeners_for(:foo) }.from([listener, listener_2]).to([listener])
    end
  end


end
