# frozen_string_literal: true

# Author: Hundter Biede (hbiede.com)
# Version: 1.0
# License: MIT

require 'csv'

# Determines if sufficient arguments were given to the program
#   else, exits
def arg_count_validator
  # print help if no arguments are given or help is requested
  return unless ARGV.length < 2 || ARGV[0] == '--help'

  error_message = 'Usage: ruby %s [VoterInputFileName] [TokenOutputFileName]'
  error_message += "\n\tOne header must contain \"School\", \"Organization\", "
  error_message += 'or "Chapter"'
  error_message += "\n\tAnother header must contain \"Delegates\" or \"Votes\""
  warn format(error_message, $PROGRAM_NAME)
  exit 1
end

# Read the contents of the given CSV file
#
# @param [String] file_name The name of the file
# @return [Array<String>]the contents of the given CSV file
def read_csv(file_name)
  begin
    # @type [Array<Array<String>>]
    csv = CSV.read(file_name)
  rescue Errno::ENOENT
    warn format('Sorry, the file %<File>s does not exist', File: file_name)
    exit 1
  end
  csv.delete_if { |line| line =~ /^\s*$/ } # delete blank lines
  csv.map { |line| line[0] }.compact
end

# Generate an empty 2D array of a given size (square)
#
# @param [Integer] size The length of the board
# @return [Array<Array<String>>]
def gen_empty_array(size)
  board = []
  (0...size).each do
    board.push(Array.new(size, ''))
  end
  board
end

# Generate a 2D array of words
#
# @param [Array<String>] word_list The list of words that can be used
# @return [Array<Array<String>>] The board of shuffled words
def gen_words(word_list)
  shuffled_list = word_list.uniq.shuffle
  board = gen_empty_array(5)
  (0...25).each do |i|
    board[i / 5][i % 5] = shuffled_list[i]
  end
  board
end

# Count the number of free spaces in a 2D array of strings
#
# @param [Array<Array<String>>] board 2D array of strings
# @return [Integer] number of blank spaces
def number_of_empty_spaces(board)
  count = 0
  board.each { |line| count += line.count('') }
  count
end

# Verifies there is room for the number of board insertions else exits
#
# @param [Array<Array<String>>] board 2D array of strings
# @param [Integer] times Number of spaces to fill the 2D
def verify_board_space(board, times)
  empty_spaces = number_of_empty_spaces(board)
  return unless times > empty_spaces

  warn format('Cannot fill a board with %<Empty>s empty spaces %<Times>s times',
              Empty: empty_spaces, Times: times)
  exit 1
end

# Assigns a letter to random tiles on the board `times` times, not replacing
#   already filled spots
#
# @param [Array<Array<String>>] board 2D array of strings
# @param [String] letter The letter to fill the board with
# @param [Integer] times The number of times to insert the letter into the board
def assign_board_tiles(board, letter, times)
  verify_board_space(board, times)
  placed = 0
  while placed < times
    tile = rand(25)
    valid = board[tile / 5][tile % 5].strip.empty?
    board[tile / 5][tile % 5] = letter if valid
    placed += 1 if valid
  end
end

# Generate Spy Key
#
# @return [Array<Array<String>>] The spy key
def gen_spy_board
  is_blue_playing_first = [true, false].sample # random boolean
  puts (is_blue_playing_first ? 'Blue' : 'Red') + ' plays first'

  board = gen_empty_array(5)
  assign_board_tiles(board, is_blue_playing_first ? 'B' : 'R', 9)
  assign_board_tiles(board, is_blue_playing_first ? 'R' : 'B', 8)
  assign_board_tiles(board, 'X', 1)
  board
end

# Find the length of the longest word on the board
#
# @param [Array<Array<String>>] board The 2D array to be searched
# @return [Integer] The longest word length on the board
def longest_word(board)
  longest_word_length = -1
  board.each do |line|
    line.each do |word|
      longest_word_length = [word.length, longest_word_length].max
    end
  end
  longest_word_length
end

# Print the board
#
# @param [Array<Array<String>>] board The board to be printed
def print_board(board)
  format_string = format('%%-%<Length>ds', Length: longest_word(board))
  board.each do |line|
    puts('| ' + (line.map { |word| format(format_string, word) }.join(' | ')) + '| ')
  end
end

# Run the main program
def main
  board = gen_words(read_csv(ARGV[0]))
  spy_board = gen_spy_board

  print_board(board)
  puts "\n\n"
  print_board(spy_board)
end

main
