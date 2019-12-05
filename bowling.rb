# Ignore this file
require 'rspec/autorun'

class BowlingGame
  # Scoring
  # 1 point per pin
  # Spare ( [N, /] ): 10 points + value of next shot
  # Strike ( [X, -] ): 10 points + sum of the values of the next 2 shots
  # 10 Pins total
  attr_accessor :frames

  def initialize(*args)
    raise ArgumentError, 'Frames are required!' if args.empty?
    @frames = args
  end

  # Naive solution, just add stuff up
  def calculate_score
    # @frames.flatten.compact.map(&:to_i).sum
    # @frames.map.with_index { |k, i| Frame.new((i+1), k.first, k.last).sum }.sum
    #my_frames = frames

    # TODO: actually calculate the score magically

    # Previous implementation
    # my_frames.map(&:sum).sum
    Frame.final_scoring(frames)
  end

  def frames
    # Manipulate it here
    @frames.map.with_index { |k, i| Frame.new((i+1), k.first, k.last) }
  end
end

class Frame
  attr_accessor :first_bowl, :second_bowl, :frame_number, :spare_score, :is_spare

  def initialize(frame_number = nil, first_bowl = nil, second_bowl = nil)
    raise ArgumentError, 'Frame Number is required!' if frame_number.nil?
    raise ArgumentError, 'First Bowl is required!' if first_bowl.nil?

    # Set the frame number, assume, that it will be an integer
    @frame_number = frame_number.to_i

    #@first_bowl = first_bowl.to_i if first_bowl.is_a?(String)
    parse_first_bowl(first_bowl)

    parse_second_bowl(second_bowl)
  end

  def set_spare_score(my_spare_score)
    @spare_score = my_spare_score
  end

  # add stuff
  def sum
    # You have to consider the previous frames when calculating the score
    # [first_bowl, second_bowl].compact.sum

    [first_bowl, second_bowl, spare_score].compact.sum

#     # Temporary
#     if frame_number == 1
#       # Ignoring spares currently in the first frame
#       [first_bowl, second_bowl].compact.sum
#     else
#       # DO other stuff

#     end
  end

  def self.final_scoring(frames)
    # The value of the spare frame is:
    #    It's the first bowl/spare + value of the first bowl of the NEXT frame

    # Probably an n +1 fix later
    frames.each do |frame|
      if frame.is_spare
        frame.set_spare_score(frames.detect { |k| k.frame_number == frame.frame_number + 1}.first_bowl)
      end
    end

    frames.map(&:sum).sum
  end

  private

  def parse_first_bowl(my_first_bowl = nil)
    @first_bowl = case my_first_bowl.to_s
    when 'X'
      10
    when '-', ''
      0
    else
      # It's a number, doesn't handle spares yet
      my_first_bowl.to_i if my_first_bowl.respond_to?(:to_i)
    end
  end

  # 7 + (10+2) + 2 +

  # ['4', '3'], ['9', '/'], ['2', '-'], ['7', '/'], ['-', '6'], ['2', '/'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']

  def parse_second_bowl(my_second_bowl = nil)
    #return 0 if my_second_bowl.nil?

    # @second_bowl = my_second_bowl.to_i if !my_second_bowl.nil? && my_second_bowl.is_a?(String)

    @second_bowl = case my_second_bowl.to_s
    when '/'
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
      my_second_bowl.to_i if my_second_bowl.respond_to?(:to_i)
    end
  end
end

describe 'BowlingGame' do
  # Passing
  it 'requires frames to be passed in' do
    # never assume people pass  you anything valid ever
    expect { BowlingGame.new() }.to raise_error(ArgumentError)
  end

  # Passing
  it 'handles simple scores' do
    # Sums all the frames up
    expect(
      BowlingGame.new(
        ['4', '3'], ['2', '1'], ['2', '3'], ['7', '1'], ['3', '6'], ['2', '2'], ['8', '1'], ['6', '3'], ['2', '3'], ['1', '1']
      ).calculate_score
    ).to eq 61
  end

  # Passing
  it 'handles zeroes' do
    expect(
      BowlingGame.new(
        ['4', '3'], ['-', '1'], ['2', '-'], ['7', '1'], ['-', '6'], ['2', '-'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
      ).calculate_score
    ).to eq 40
  end

  it "works for the first two frames" do
    # 7 (4,3) + (10 (9 and spare) + 2 (whcih was from the next (third) frame) + 2 (the value of the first shot in the third frame

    # The value of the spare frame is:
    #    It's the first bowl/spare + value of the first bowl of the NEXT frame
    expect(
      BowlingGame.new(
        ['4', '3'], ['9', '/'], ['2', '-']
      ).calculate_score
    ).to eq(21)
  end

  it 'handles spares' do
    expect(
      BowlingGame.new(
        ['4', '3'], ['9', '/'], ['2', '-'], ['7', '/'], ['-', '6'], ['2', '/'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
      ).calculate_score
    ).to eq 69
  end
  xit 'handles strikes' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['2', '6'], ['X', '-'], ['7', '2'], ['X', '-'], ['-', '3'], ['X', '-'], ['-', '-'], ['3', '2'], ['1', '1']
      ).calculate_score
    ).to eq 87
  end
  xit 'handles spares followed by a strike' do
    expect(
      BowlingGame.new(
        ['4', '3'], ['2', '6'], ['6', '/'], ['X', '-'], ['3', '3'], ['7', '/'], ['2', '1'], ['7', '/'], ['X', '-'], ['3', '2']
      ).calculate_score
    ).to eq 112
  end
  xit 'handles strikes followed by a spare' do
    expect(
      BowlingGame.new(
        ['4', '3'], ['2', '6'], ['X', '-'], ['3', '/'], ['3', '3'], ['X', '-'], ['2', '/'], ['7', '/'], ['3', '6'], ['3', '2']
      ).calculate_score
    ).to eq 118
  end
  xit 'handles consecutive strikes' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '2']
      ).calculate_score
    ).to eq 135
  end
  xit 'handles a spare in the last frame' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '/', '6']
      ).calculate_score
    ).to eq 146
  end
  xit 'handles a strike in the last frame' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '2']
      ).calculate_score
    ).to eq 149
  end
  xit 'handles a strike followed by a spare in the last frame' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '/']
      ).calculate_score
    ).to eq 150
  end
  xit 'handles a perfect game' do
    expect(
      BowlingGame.new(
        ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', 'X', 'X']
      ).calculate_score
    ).to eq 300
  end
end
