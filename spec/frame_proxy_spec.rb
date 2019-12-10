require_relative '../lib/frame_proxy'
require_relative '../lib/frame'

describe 'FrameProxy' do
  context '.all / .add' do
    it 'returns an empty list if there are no frames' do
      frame_proxy = FrameProxy.new
      expect(frame_proxy.all).to match_array([])
    end

    it 'returns all the frames in sequential order' do
      frame_proxy = FrameProxy.new
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      # Add the first frame
      frame_proxy.add(frame_1)
      expect(frame_proxy.all).to match_array([frame_1])

      # Add the second frame
      frame_proxy.add(frame_2)
      expect(frame_proxy.all).to match_array([frame_1, frame_2])

      # Add the third frame
      frame_proxy.add(frame_3)
      expect(frame_proxy.all).to match_array([frame_1, frame_2, frame_3])
    end
  end

  context '.next / .current' do
    it 'takes a frame and can return relevant sequential frames' do
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      frame_proxy = FrameProxy.new

      frame_proxy.add(frame_1)
      frame_proxy.add(frame_2)
      frame_proxy.add(frame_3)

      # Expect current to be nil
      expect(frame_proxy.current).to be_nil

      # Set current
      frame_proxy.current!(frame_1)

      # Make sure current is set
      expect(frame_proxy.current).to eql(frame_1)

      # Make sure we have next
      expect(frame_proxy.next).to eq(frame_2)
    end

    it 'returns nil for current if there are no frames' do
      frame_proxy = FrameProxy.new
      expect(frame_proxy.current).to be_nil
    end

    it 'returns nil for next if the frame number is greater than the number of frames' do
      frame_proxy = FrameProxy.new
      frame_1 = Frame.new(2, '4', '3')
      frame_proxy.add(frame_1)
      expect(frame_proxy.next).to be_nil
    end

    it 'returns nil if it is the last frame' do
      frame_proxy = FrameProxy.new
      frame_1 = Frame.new(1, '4', '3')
      frame_proxy.add(frame_1)
      expect(frame_proxy.next).to be_nil
    end
  end

  context '.size and .last_frame?' do
    # TODO: DRY
    it 'knows how many frames there are' do
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      frame_proxy = FrameProxy.new

      frame_proxy.add(frame_1)
      frame_proxy.add(frame_2)
      frame_proxy.add(frame_3)

      expect(frame_proxy.size).to eql(3)
    end

    it 'knows if the given frame is the last frame of the game' do
      # pending 'not implemented yet'
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      frame_proxy = FrameProxy.new

      frame_proxy.add(frame_1)
      frame_proxy.add(frame_2)
      frame_proxy.add(frame_3)

      # Set the current frame to 1
      frame_proxy.current!(frame_1)
      expect(frame_proxy.last_frame?).to be_falsey

      # Set the current frame to 2
      frame_proxy.current!(frame_2)
      expect(frame_proxy.last_frame?).to be_falsey

      # Frame_3 should be the last one
      frame_proxy.current!(frame_3)
      expect(frame_proxy.last_frame?).to be_truthy
    end
  end
end
