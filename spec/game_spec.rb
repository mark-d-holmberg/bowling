# frozen_string_literal: true

require_relative '../lib/game'

describe 'BowlingGame' do
  context 'validations' do
    it 'raises Frames are Required if nothing is passed in' do
      expect { BowlingGame.new() }.to raise_error(ArgumentError, 'Frames are required!')
    end

    it 'raises cant be nil if nil is passed in' do
      expect { BowlingGame.new(nil) }.to raise_error(ArgumentError, 'No arguments can be nil!')
    end

    it 'raise cant be empty array if an empty array is passed in' do
      expect { BowlingGame.new([]) }.to raise_error(ArgumentError, 'Frame data is required for all elements!')
    end

    it 'handles mixed state' do
      expect { BowlingGame.new(%w[1 2], [], nil) }.to raise_error(ArgumentError, 'Frame data is required for all elements!')
    end
  end

  context 'frame proxy' do
    it 'has a frame proxy' do
      game = BowlingGame.new(['4', '3'], ['2', '1'], ['2', '3'], ['7', '1'], ['3', '6'], ['2', '2'], ['8', '1'], ['6', '3'], ['2', '3'], ['1', '1'])
      expect(game.frame_proxy).not_to be_nil
    end
  end

  context '.calculate_score' do
    it 'handles simple scores' do
      expect(
        BowlingGame.new(
          ['4', '3'], ['2', '1'], ['2', '3'], ['7', '1'], ['3', '6'], ['2', '2'], ['8', '1'], ['6', '3'], ['2', '3'], ['1', '1']
        ).calculate_score
      ).to eq 61
    end

    it 'handles zeroes' do
      expect(
        BowlingGame.new(
          ['4', '3'], ['-', '1'], ['2', '-'], ['7', '1'], ['-', '6'], ['2', '-'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
        ).calculate_score
      ).to eq 40
    end

    it 'calculates one frame for 7' do
      expect(BowlingGame.new(['4', '3']).calculate_score).to eq(7)
    end

    # IT would be 21 if we had the next frame
    it 'calculates two frames for 19 with the next frame' do
      game = BowlingGame.new(['4', '3'], ['9', '/'], ['2', '-'])
      expect(game.calculate_score).to eq(21)
    end

    it 'handles spares' do
      expect(
        BowlingGame.new(
          ['4', '3'], ['9', '/'], ['2', '-'], ['7', '/'], ['-', '6'], ['2', '/'], ['8', '-'], ['6', '-'], ['-', '-'], ['-', '-']
        ).calculate_score
      ).to eq 69
    end

    it 'handles strikes' do
      expect(
        BowlingGame.new(
          ['X', '-'], ['2', '6'], ['X', '-'], ['7', '2'], ['X', '-'], ['-', '3'], ['X', '-'], ['-', '-'], ['3', '2'], ['1', '1']
        ).calculate_score
      ).to eq 87
    end

    it 'handles spares followed by a strike' do
      expect(
        BowlingGame.new(
          ['4', '3'], ['2', '6'], ['6', '/'], ['X', '-'], ['3', '3'], ['7', '/'], ['2', '1'], ['7', '/'], ['X', '-'], ['3', '2']
        ).calculate_score
      ).to eq 112
    end

    it 'handles strikes followed by a spare' do
      expect(
        BowlingGame.new(
          ['4', '3'], ['2', '6'], ['X', '-'], ['3', '/'], ['3', '3'], ['X', '-'], ['2', '/'], ['7', '/'], ['3', '6'], ['3', '2']
        ).calculate_score
      ).to eq 118
    end

    it 'handles consecutive strikes' do
      game = BowlingGame.new(['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '2'])
      expect(game.calculate_score).to eq 135
    end

    it 'handles a spare in the last frame' do
      game = BowlingGame.new(['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['3', '/', '6'])
      expect(game.calculate_score).to eq 146
    end

    it 'handles a strike in the last frame' do
      game = BowlingGame.new(['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '2'])
      expect(game.calculate_score).to eq 149
    end

    it 'handles a strike followed by a spare in the last frame' do
      game = BowlingGame.new(['X', '-'], ['X', '-'], ['6', '3'], ['X', '-'], ['X', '-'], ['7', '/'], ['2', '1'], ['7', '2'], ['2', '3'], ['X', '7', '/'])
      expect(game.calculate_score).to eq 150
    end

    it 'handles a perfect game' do
      game = BowlingGame.new(['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', '-'], ['X', 'X', 'X'])
      expect(game.calculate_score).to eq 300
    end
  end
end
