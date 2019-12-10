# frozen_string_literal: true

require_relative '../lib/frame'

describe 'Frame' do
  context 'validations' do
    it 'requires the number' do
      expect { Frame.new(nil, '1', '5') }.to raise_error(ArgumentError, 'Frame Number is required!')
    end

    it 'requires the first bowl' do
      expect { Frame.new(1, nil, '5') }.to raise_error(ArgumentError, 'First Bowl is required!')
    end

    it 'requires the second bowl' do
      expect { Frame.new(1, '1', nil) }.to raise_error(ArgumentError, 'Second Bowl is required!')
    end

    it 'defaults current_game to nil' do
      expect(Frame.new(1, '1', '5').current_game).to be_nil
    end
  end

  context 'setting scores for both shots' do
    it 'can set the scores for when they are both numeric' do
      frame = Frame.new(1, '1', '5')
      expect(frame.number).to eql(1)
      expect(frame.first_bowl).to eql(1)
      expect(frame.second_bowl).to eql(5)
    end

    # the *value* of the second shot is zero, but that is different than the
    # SCORE for Frame number 2.
    it 'can set the scores for when the second shot is a spare' do
      frame = Frame.new(2, '3', '/')
      expect(frame.number).to eql(2)
      expect(frame.first_bowl).to eql(3)
      expect(frame.second_bowl).to eql(0)
    end

    it 'can set the scores for when the second shot is a miss' do
      frame = Frame.new(3, '4', '-')
      expect(frame.number).to eql(3)
      expect(frame.first_bowl).to eql(4)
      expect(frame.second_bowl).to eql(0)
    end

    it 'can set the scores for when the first shot is a strike' do
      frame = Frame.new(4, 'X', '-')
      expect(frame.number).to eql(4)
      expect(frame.first_bowl).to eql(10)
      expect(frame.second_bowl).to eql(0)
    end
  end

  # the score for the entire frame!, not just the shots
  context 'concerning Frame SCORE' do
    it 'when both shots are missed it is zero' do
      frame = Frame.new(1, '-', '-')
      expect(frame.number).to eql(1)
      expect(frame.score).to eql(0)
    end

    it 'when the first shot hits and the second misses' do
      frame = Frame.new(2, '1', '-')
      expect(frame.number).to eql(2)
      expect(frame.score).to eql(1)
    end

    it 'when the first shot misses and the second hits' do
      frame = Frame.new(3, '-', '4')
      expect(frame.number).to eql(3)
      expect(frame.score).to eql(4)
    end

    it 'when both shots hit' do
      frame = Frame.new(4, '9', '1')
      expect(frame.number).to eql(4)
      expect(frame.score).to eql(10)
    end

    # Spare ( [N, /] ): 10 points + value of next shot
    it 'when the first shot hits and the second shot is a spare' do
      game = BowlingGame.new(['9', '/'], ['2', '-'])
      # 12 for the FRAME
      # + 2 = 14 for the whole game?
      frame_1, frame_2 = game.frame_proxy.all.to_a

      expect(frame_1.number).to eql(1)
      expect(frame_2.number).to eql(2)

      expect(frame_1.score).to eql(12)
      expect(frame_2.score).to eql(2)
    end

    it 'handles the case from Magnus' do
      # 7 (4,3) + (10 (9 and spare) + 2 (whcih was from the next (third) frame) + 2 (the value of the first shot in the third frame
      # ['4', '3'], ['9', '/'], ['2', '-']
      game = BowlingGame.new(['4', '3'], ['9', '/'], ['2', '-'])

      frames = game.frame_proxy.all.to_a

      frame_1 = frames.shift
      frame_2 = frames.shift
      frame_3 = frames.shift

      expect(frame_1.number).to eql(1)
      expect(frame_2.number).to eql(2)
      expect(frame_3.number).to eql(3)

      # The total score for the game is 21
      expect(frame_1.score).to eql(7)
      expect(frame_2.score).to eql(12)
      expect(frame_3.score).to eql(2)
    end
  end
end
