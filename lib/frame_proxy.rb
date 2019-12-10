# frozen_string_literal: true

require 'set'

class FrameProxy
  attr_accessor :all_frames, :current

  def initialize(my_frames = Set.new())
    @all_frames = my_frames

    # By default we set the number of frames, so add needs to keep it in check
  end

  # Return all the frames, sorted by the frame number
  def all
    @all_frames.sort_by { |frame| frame.number }
  end

  # Add a frame to the set
  def add(frame)
    @all_frames.add(frame)
  end

  # Set the current frame
  def current!(my_frame)
    @current = my_frame  # Do we want to set this to the frame, or the frame number?
  end

  # Find the next frame(s)
  def next
    return nil unless @current
    return nil if @current.number > size

    # you're not the last frame
    @all_frames.find { |frame| frame.number == (@current.number + 1) }
  end

  def size
    @all_frames.length
  end

  def last_frame?
    return nil unless @current

    @current.number == size
  end

  # TODO: need to know if this is the last frame before we can fill out 'next'
end
