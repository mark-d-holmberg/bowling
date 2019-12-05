# Ignore this file
require 'rspec/autorun'

class BowlingGame
  # Scoring
  # 1 point per pin
  # Spare ( [N, /] ): 10 points + value of next shot
  # Strike ( [X, -] ): 10 points + sum of the values of the next 2 shots
  # 10 Pins total

  attr_accessor :all_frames

  def initialize(*args)
    # Validate that we got decent input
    validate_args!(args)

    # Init our list of frame instances
    @all_frames = args.map.with_index.map do |argument, index|
      Frame.new((index+1), argument.first, argument.last)
    end

    # Set the frames
    @all_frames.each do |frame|
      next_frame_index = frame.number + 1 # we've 1-based this one
      if next_frame = @all_frames.detect { |k| k.number == next_frame_index }
        frame.set_next_frame(next_frame)
      end
    end
  end

  def calculate_score
    @all_frames.sum { |frame| frame.score }
  end

  private

  # Reject stupidity
  def validate_args!(arguments)
    # check for empty array
    raise ArgumentError, 'stupid array' if arguments.any? { |arg| arg.is_a?(Array) && arg.empty? }

    # check for nils
    raise ArgumentError, 'stupid nil' if arguments.any? { |arg| arg.nil? }

    # check for just empty
    raise ArgumentError, 'Frames are required!' if arguments.empty? and arguments.is_a?(Array)
  end
end

class Frame
  attr_accessor :first_bowl, :second_bowl, :number, :is_spare, :is_strike, :next_frame

  def initialize(number = nil, first_bowl = nil, second_bowl = nil)
    raise ArgumentError, 'Frame Number is required!' if number.nil?
    raise ArgumentError, 'First Bowl is required!' if first_bowl.nil?
    raise ArgumentError, 'Second Bowl is required!' if second_bowl.nil?

    # TODO: Transform input values
    @number = number # set frame number

    # Transform the first bowl
    @first_bowl = case first_bowl.to_s
    when 'X'
      @is_strike = true
      10
    when '-', ''
      0
    else
      # It's a number
      first_bowl.to_i if first_bowl.respond_to?(:to_i)
    end

    # Transform second bowl
    @second_bowl = case second_bowl.to_s
    when '/'
      # Indicate that the second shot of this frame was a spare.
      @is_spare = true
      0
      # 10, which is the total, minus the value of what they had in the first bowl
      # 10 - @first_bowl


      # The value of the spare frame is:
      #    It's the first bowl/spare + value of the first bowl of the NEXT frame


    when '-', ''
      # It's nil or they have bad aim
      0
    else
      # It's a number
      second_bowl.to_i if second_bowl.respond_to?(:to_i)
    end

    # Default next_frame to nil
    @next_frame = nil
  end

  # Indicate what our next frame is. Probably only need to pass in the first bowl score
  def set_next_frame(frame)
    @next_frame = frame #if frame.is_a?(Frame)
  end

  # No strike and no spare
  def single?
    !is_strike && !is_spare
  end

  # Double is two strikes
  def double?
    return false unless @next_frame
    @is_strike && @next_frame.is_strike
  end

  # This one is a strike and my next frame is a double
  def triple?
    return false unless @next_frame && @next_frame.next_frame
    @is_strike && @next_frame.double?
  end

  # Are you a strike
  def is_strike?
    @is_strike
  end

  # are you a spare
  def is_spare?
    @is_spare
  end

  # def inspect
  #   "#<Frame:#{"0x00%x" % (object_id << 1)}, @first_bowl=#{@first_bowl}, @second_bowl=#{@second_bowl}, @number=#{@number}, @is_spare=#{@is_spare}, @is_strike=#{@is_strike}, @has_next_frame?=#{@next_frame ? true : false}, @score=#{score}>"
  # end

  # We can't know the score for a FRAME when it's a spare if there is no next_frame!
  # The TOTAL score for THIS frame (could depend on the next 2/3 frames)
  # TODO: you need to make a clear distinction for:
  # * the TOTAL score for the game
  # * the score for *this FRAME* when it's a spare/strike and
  #   * There is a next frame
  #   * There is NOT a next frame
  # # TODO: When this is a strike, and the next frame is a spare, it's just 10 for the bonus
  def score
    # raise "next frame is missing" if @is_spare && !@next_frame

    # Are you a single?
    # Are you a double?
    # Are you a triple?


    # This frame is a single, no spares or strikes. Could have missed outright
    if single?
      return [first_bowl, second_bowl].compact.sum
    end

    # This frame is a strike and the next frame is a strike
    if double?
      return 10 + (@next_frame.score - @next_frame.second_bowl)
    end

    # if is_strike?
    # end
    if @next_frame
      # This frame is a strike
      if is_strike?

        # This frame is a strike, but the next one is a single (not spare or strike)
        if @next_frame.single?
          return [10, @next_frame.first_bowl, @next_frame.second_bowl].compact.sum
        end

        # if @next_frame.is_strike?
        #   if @next_frame.
        #   # raise self.inspect
        #   # # raise @next_frame.inspect
        #   # raise "combo breaker"
        # end
      end

      # This frame is a spare
      if is_spare?
        return [10, @next_frame.first_bowl].compact.sum
      end
    else
      # You're a spare or a strike, but there's nothing after you
      return 0 if is_spare? # Ain't got no next frame

      return 10 if is_strike?
    end

    # if @next_frame && (@is_spare || @is_strike)
    #   if @is_strike
    #     if @next_frame.is_strike
    #       10 + @next_frame.first_bowl
    #     elsif @next_frame.is_spare
    #       20
    #     else
    #       [10, @next_frame.first_bowl, @next_frame.second_bowl].compact.sum
    #     end
    #   elsif @is_spare
    #     [10, @next_frame.first_bowl].compact.sum
    #   end
    # else
    #   # No special conditions
    #   [first_bowl, second_bowl].compact.sum
    # end

    # if @is_strike && @next_frame
    #   [10, @next_frame.first_bowl, @next_frame.second_bowl].compact.sum
    # elsif @is_spare && @next_frame
    #   10 + @next_frame.first_bowl
    # else
    #   [first_bowl, second_bowl].compact.sum
    # end

    # TODO: Spare ( [N, /] ): 10 points + value of next shot
  end
end


## Specs
# describe 'Frame' do
#   context 'validations' do
#     it 'requires the number' do
#       expect { Frame.new(nil, '1', '5') }.to raise_error(ArgumentError, 'Frame Number is required!')
#     end

#     it 'requires the first bowl' do
#       expect { Frame.new(1, nil, '5') }.to raise_error(ArgumentError, 'First Bowl is required!')
#     end

#     it 'requires the second bowl' do
#       expect { Frame.new(1, '1', nil) }.to raise_error(ArgumentError, 'Second Bowl is required!')
#     end
#   end

#   context 'setting scores for both shots' do
#     it 'can set the scores for when they are both numeric' do
#       frame = Frame.new(1, '1', '5')
#       expect(frame.number).to eql(1)
#       expect(frame.first_bowl).to eql(1)
#       expect(frame.second_bowl).to eql(5)
#     end

#     # the *value* of the second shot is zero, but that is different than the
#     # SCORE for Frame number 2.
#     it 'can set the scores for when the second shot is a spare' do
#       frame = Frame.new(2, '3', '/')
#       expect(frame.number).to eql(2)
#       expect(frame.first_bowl).to eql(3)
#       expect(frame.second_bowl).to eql(0)
#     end

#     it 'can set the scores for when the second shot is a miss' do
#       frame = Frame.new(3, '4', '-')
#       expect(frame.number).to eql(3)
#       expect(frame.first_bowl).to eql(4)
#       expect(frame.second_bowl).to eql(0)
#     end

#     it 'can set the scores for when the first shot is a strike' do
#       frame = Frame.new(4, 'X', '-')
#       expect(frame.number).to eql(4)
#       expect(frame.first_bowl).to eql(10)
#       expect(frame.second_bowl).to eql(0)
#     end
#   end

#   # the score for the entire frame!, not just the shots
#   context 'concerning Frame SCORE' do
#     it 'when both shots are missed it is zero' do
#       frame = Frame.new(1, '-', '-')
#       expect(frame.number).to eql(1)
#       expect(frame.score).to eql(0)
#     end

#     it 'when the first shot hits and the second misses' do
#       frame = Frame.new(2, '1', '-')
#       expect(frame.number).to eql(2)
#       expect(frame.score).to eql(1)
#     end

#     it 'when the first shot misses and the second hits' do
#       frame = Frame.new(3, '-', '4')
#       expect(frame.number).to eql(3)
#       expect(frame.score).to eql(4)
#     end

#     it 'when both shots hit' do
#       frame = Frame.new(4, '9', '1')
#       expect(frame.number).to eql(4)
#       expect(frame.score).to eql(10)
#     end

#     # Spare ( [N, /] ): 10 points + value of next shot
#     it 'when the first shot hits and the second shot is a spare' do
#       frame_1 = Frame.new(1, '9', '/') # 12 for the FRAME
#       frame_2 = Frame.new(2, '2', '-') # + 2 = 14 for the whole game?

#       frame_1.set_next_frame(frame_2)

#       expect(frame_1.number).to eql(1)
#       expect(frame_2.number).to eql(2)

#       expect(frame_1.score).to eql(12)
#       expect(frame_2.score).to eql(2)
#     end

#     it 'handles the case from Magnus' do
#       # 7 (4,3) + (10 (9 and spare) + 2 (whcih was from the next (third) frame) + 2 (the value of the first shot in the third frame
#       # ['4', '3'], ['9', '/'], ['2', '-']
#       frame_1 = Frame.new(1, '4', '3')
#       frame_2 = Frame.new(2, '9', '/')
#       frame_3 = Frame.new(3, '2', '-')

#       frame_1.set_next_frame(frame_2)
#       frame_2.set_next_frame(frame_3)

#       expect(frame_1.number).to eql(1)
#       expect(frame_2.number).to eql(2)
#       expect(frame_3.number).to eql(3)

#       # The total score for the game is 21
#       expect(frame_1.score).to eql(7)
#       expect(frame_2.score).to eql(12)
#       expect(frame_3.score).to eql(2)
#     end
#   end
# end

# describe 'BowlingGame' do
#   context 'validations' do
#     it 'raises Frames are Required if nothing is passed in' do
#       expect { BowlingGame.new() }.to raise_error(ArgumentError, 'Frames are required!')
#     end

#     it 'raises cant be nil if nil is passed in' do
#       expect { BowlingGame.new(nil) }.to raise_error(ArgumentError, 'stupid nil')
#     end

#     it 'raise cant be empty array if an empty array is passed in' do
#       expect { BowlingGame.new([]) }.to raise_error(ArgumentError, 'stupid array')
#     end

#     it 'handles mixed state' do
#       expect { BowlingGame.new(%w[1 2], [], nil) }.to raise_error(ArgumentError, 'stupid array')
#     end
#   end

#   it 'handles simple scores' do
#     # Sums all the frames up
#     expect(
#       BowlingGame.new(
#         ['4', '3'], ['2', '1'], ['2', '3'], ['7', '1'], ['3', '6'], ['2', '2'], ['8', '1'], ['6', '3'], ['2', '3'], ['1', '1']
#       ).calculate_score
#     ).to eq 61
#   end

#   it 'handles zeroes' do
#     expect(
#       BowlingGame.new(
#         ['4', '3'], ['-', '1'], ['2', '-'], ['7', '1'], ['-', '6'], ['2', '-'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
#       ).calculate_score
#     ).to eq 40
#   end

#   it 'calculates one frame for 7' do
#     expect(BowlingGame.new(['4', '3']).calculate_score).to eq(7)
#   end

#   # We can't calculate the total score because the last frame is a spare and we need the next frame's info
#   it 'calculates two frames for 7 without the next frame', focus: true do
#     game = BowlingGame.new(['4', '3'], ['9', '/'])

#     # raise game.all_frames.inspect

#     expect(game.calculate_score).to eq(7)
#   end

#   # IT would be 21 if we had the next frame
#   it 'calculates two frames for 19 with the next frame' do
#     game = BowlingGame.new(['4', '3'], ['9', '/'], ['2', '-'])
#     expect(game.calculate_score).to eq(21)
#   end

#   # it "works for the first two frames" do
#   #   # 7 (4,3) + (10 (9 and spare) + 2 (whcih was from the next (third) frame) + 2 (the value of the first shot in the third frame

#   #   # The value of the spare frame is:
#   #   #    It's the first bowl/spare + value of the first bowl of the NEXT frame
#   #       # ['4', '3'], ['9', '/'], ['2', '-']
#   #   expect(
#   #     BowlingGame.new(
#   #       ['4', '3'], ['9', '/'], ['2', '-']
#   #     ).calculate_score
#   #   ).to eq(21)
#   # end

#   it 'handles spares' do
#     # TODO: calculate this by hand!
#     expect(
#       BowlingGame.new(
#         ['4', '3'], ['9', '/'], ['2', '-'], ['7', '/'], ['-', '6'], ['2', '/'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
#       ).calculate_score
#     ).to eq 69
#   end

#   it 'handles strikes' do
#     expect(
#       BowlingGame.new(
#         ['X', '-'], ['2', '6'], ['X', '-'], ['7', '2'], ['X', '-'], ['-', '3'], ['X', '-'], ['-', '-'], ['3', '2'], ['1', '1']
#       ).calculate_score
#     ).to eq 87
#   end

#   it 'handles spares followed by a strike' do
#     expect(
#       BowlingGame.new(
#         ['4', '3'], ['2', '6'], ['6', '/'], ['X', '-'], ['3', '3'], ['7', '/'], ['2', '1'], ['7', '/'], ['X', '-'], ['3', '2']
#       ).calculate_score
#     ).to eq 112
#   end

#   xit 'handles strikes followed by a spare' do
#     expect(
#       BowlingGame.new(
#         ['4', '3'], ['2', '6'], ['X', '-'], ['3', '/'], ['3', '3'], ['X', '-'], ['2', '/'], ['7', '/'], ['3', '6'], ['3', '2']
#       ).calculate_score
#     ).to eq 118
#   end

#   it 'handles consecutive strikes' do
#     # ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '2']
#     # game = BowlingGame.new(['X', '-'], ['X', '-'], ['6', '3'])
#     game = BowlingGame.new(['X', '-'], ['X', '-'], ['4', '2'])
#     raise game.all_frames.map(&:score).inspect
#     expect(game.calculate_score).to eq 46 # 135
#   end

#   xit 'handles a spare in the last frame' do
#     expect(
#       BowlingGame.new(
#         ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '/', '6']
#       ).calculate_score
#     ).to eq 146
#   end

#   xit 'handles a strike in the last frame' do
#     expect(
#       BowlingGame.new(
#         ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '2']
#       ).calculate_score
#     ).to eq 149
#   end

#   xit 'handles a strike followed by a spare in the last frame' do
#     expect(
#       BowlingGame.new(
#         ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '/']
#       ).calculate_score
#     ).to eq 150
#   end

#   xit 'handles a perfect game' do
#     expect(
#       BowlingGame.new(
#         ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', 'X', 'X']
#       ).calculate_score
#     ).to eq 300
#   end
# end
