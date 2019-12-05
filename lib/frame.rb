class Frame
  attr_accessor :first_bowl, :second_bowl, :number, :is_spare, :is_strike, :next_frame, :last_frame_bowl, :last_frame_bowl_is_strike, :last_frame_bowl_is_spare

  def initialize(number = nil, first_bowl = nil, second_bowl = nil, last_frame_bowl = nil)
    raise ArgumentError, 'Frame Number is required!' if number.nil?
    raise ArgumentError, 'First Bowl is required!' if first_bowl.nil?
    raise ArgumentError, 'Second Bowl is required!' if second_bowl.nil?

    @number = number # set frame number

    # Set this score if applicable
    @last_frame_bowl = case last_frame_bowl.to_s
    when 'X'
      @last_frame_bowl_is_strike = true
      10
    when '/'
      @last_frame_bowl_is_spare = true
      0
    when '-', ''
      0
    else
      # It's a number
      last_frame_bowl.to_i if last_frame_bowl.respond_to?(:to_i)
    end

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

  def is_last_frame?
    !last_frame_bowl.nil?
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
    # Are you a single?
    # Are you a double?
    # Are you a triple?


    # This frame is a single, no spares or strikes. Could have missed outright
    if single?
      return [first_bowl, second_bowl].compact.sum
    end

    # This frame is a strike and the next frame is a strike
    if double? && @next_frame&.next_frame
      # TODO: check to make sure there is a next_frame.next_frame
      return 10 + (10 + @next_frame.next_frame.first_bowl)
    end


    if @next_frame
      # This frame is a strike
      if is_strike?
        # This frame is a strike, but the next one is a single (not spare or strike)
        if @next_frame.single?
          return 10 + @next_frame.score
        end

        # The current frame is a strike, but the next frame is a spare
        if @next_frame.is_spare?
          return 20
        end

        if @next_frame.is_last_frame? && @next_frame.is_strike?
          return 30
        end
      end

      # This frame is a spare
      if is_spare?
        return [10, @next_frame.first_bowl].compact.sum
      end
    else
      # Last frame of the game
      if is_last_frame?
        # We got a spare for our first throw
        if is_spare?
          return 10 + last_frame_bowl
        end

        # We got a Strike for our first throw
        if is_strike?
          # Check what the last_frame_bowl is
          if @last_frame_bowl_is_spare
            return 20
          end

          if @last_frame_bowl_is_strike
            return 30
          end

          return 10 + second_bowl + last_frame_bowl
        end
      else
        # We're not on the last frame
        # You're a spare or a strike, but there's nothing after you
        return 0 if is_spare? # Ain't got no next frame

        return 10 if is_strike?
      end
    end
  end
end
