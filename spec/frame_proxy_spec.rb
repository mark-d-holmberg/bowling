require_relative '../lib/frame_proxy'
require_relative '../lib/frame'

describe 'FrameProxy' do
  context 'concerning instance methods' do
    it 'knows how to reference all the frames' do
      frame_proxy = FrameProxy.new
      frames = [] # TODO: make this actually be something
      expect(frame_proxy.all).to match_array(frames)
    end

    it 'takes a frame and can return relevant sequential frames' do
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      set = Set.new
      set.add(frame_1)
      set.add(frame_2)
      set.add(frame_3)

      frame_proxy = FrameProxy.new(set)
      frame_proxy.current!(frame_1)
      expect(frame_proxy.next).to eq(frame_2)
    end

    # TODO: DRY
    it 'knows how many frames there are' do
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      set = Set.new
      set.add(frame_1)
      set.add(frame_2)
      set.add(frame_3)

      frame_proxy = FrameProxy.new(set)
      expect(frame_proxy.size).to eql(3)
    end

    it 'knows if the given frame is the last frame of the game' do
      # pending 'not implemented yet'
      frame_1 = Frame.new(1, '4', '3')
      frame_2 = Frame.new(2, '9', '/')
      frame_3 = Frame.new(3, '2', '-')

      set = Set.new
      set.add(frame_1)
      set.add(frame_2)
      set.add(frame_3)

      frame_proxy = FrameProxy.new(set)

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
