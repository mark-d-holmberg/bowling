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
      first_bowl, second_bowl, last_frame_bowl = argument
      Frame.new((index+1), first_bowl, second_bowl, last_frame_bowl)
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
    @all_frames.map { |frame| frame.score }.compact.sum
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
