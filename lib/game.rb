# frozen_string_literal: true

class BowlingGame
  # Scoring
  # 1 point per pin
  # Spare ( [N, /] ): 10 points + value of next shot
  # Strike ( [X, -] ): 10 points + sum of the values of the next 2 shots
  # 10 Pins total

  attr_accessor :frame_proxy

  # TODO: you could probably store the score of the third shot of the final frame on the Bowling game itself to save from having to have an attribute for last_frame_bowl on ALL frames, most of which would never be used.

  # TODO: you could also indicate that a bowling game is made of a specified number of frames, and use that to determine whether the current frame is the last frame or not

  # TODO: Instead of storing next_frame as an object (possibly) for the current frame, you could store a way for this current frame to *find* the next frame (when applicable), rather than duplicating the frame data on every frame (except the last frame). Find a way to look it up / reference it, rather than storing it like a non-optimized "linked list"

  def initialize(*args)
    # Validate that we got decent input
    validate_args!(args)

    # Can we just add a simple FrameProxy, without touching anything else?
    @frame_proxy = FrameProxy.new

    # Populate the Proxy. Now we only have to iterate once.
    args.map.with_index.map do |argument, index|
      first_bowl, second_bowl, last_frame_bowl = argument
      frame = Frame.new((index+1), first_bowl, second_bowl, last_frame_bowl)
      frame.set_current_game!(self)
      @frame_proxy.add(frame)
    end
  end

  def calculate_score
    @frame_proxy.all.map { |frame| frame.score }.compact.sum
  end

  private

  # Reject stupidity
  def validate_args!(arguments)
    # check for empty array
    raise ArgumentError, 'Frame data is required for all elements!' if arguments.any? { |arg| arg.is_a?(Array) && arg.empty? }

    # check for nils
    raise ArgumentError, 'No arguments can be nil!' if arguments.any? { |arg| arg.nil? }

    # check for just empty
    raise ArgumentError, 'Frames are required!' if arguments.empty? and arguments.is_a?(Array)
  end
end
