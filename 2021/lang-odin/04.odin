package day04

import "core:fmt"
import "core:testing"
import "core:math"
import "core:strings"
import "core:strconv"
import "core:text/scanner"
import "util"

main :: proc() {
	fmt.println("Part1", part1(problem_input))
	fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(example_input), 4512)
}
@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(example_input), 1924)
}

Board :: struct {
	marked:  [BOARD_SIZE]bool,
	numbers: [BOARD_SIZE]int,
	bingo:   bool,
}

State :: struct {
	drawn_numbers: []int,
	boards:        [dynamic]Board,
}

part1 :: proc(input: string) -> int {
	state := parse(input)
	for draw in state.drawn_numbers {
		for board in &state.boards {
			mark(draw, &board)
			if bingo(&board) {
				return draw * math.sum(board.numbers[:])
			}
		}
	}
	unreachable()
}

part2 :: proc(input: string) -> (result: int) {
	state := parse(input)
	for draw in state.drawn_numbers {
		for board in &state.boards do if !board.bingo {
			mark(draw, &board)
			if bingo(&board) {
				board.bingo = true
				result = draw * math.sum(board.numbers[:])
			}
		}
	}
	return
}

bingo :: proc(board: ^Board) -> bool {
	// NOTE(Oskar): Could maybe be clever to turn these into [5][5] matrices and math.sum() on the transposed and non-transposed?
	//              Maybe could even use soa_slice somehow ?
	m := board.marked
	for row in 0..<BOARD_ROWS {
		sum: int
		for col in 0..<BOARD_COLS {
			sum += 1 if m[BOARD_COLS*row + col] else 0
		}
		if sum == BOARD_COLS {
			return true
		}
	}
	for col in 0..<BOARD_COLS {
		sum: int
		for row in 0..<BOARD_ROWS {
			sum += 1 if m[BOARD_COLS*row + col] else 0
		}
		if sum == BOARD_ROWS {
			return true
		}
	}
	return false
}

mark :: proc(drawn_number: int, board: ^Board) {
	for number, i in board.numbers {
		if number == drawn_number {
			board.marked[i]  = true
			board.numbers[i] = 0
			break
		}
	}
}

parse :: proc(input: string) -> (result: State) {
	first_newline_pos := strings.index(input, "\n")
	result.drawn_numbers = string_numbers_to_integers(strings.split(input[:first_newline_pos], ","))

	string_numbers_to_integers :: proc(strings: []string) -> []int {
		numbers := make([]int, len(strings))
		for str, i in strings {
			#no_bounds_check numbers[i] = strconv.atoi(str)
		}
		return numbers
	}

	using scanner
	i := 0
	s := init(&Scanner{}, input[first_newline_pos:])
	scratch: [BOARD_SIZE]int
	loop: for do switch tok := scan(s); tok {
		case EOF: break loop
		case Int:
			scratch[i] = strconv.atoi(token_text(s))
			i += 1
			if i == BOARD_SIZE {
				board := Board{numbers = scratch, marked = {}}
				append(&result.boards, board)
				scratch = {}
				i = 0
			}
		case: unreachable()
	}
	assert(i == 0)

	return
}

BOARD_ROWS      :: 5
BOARD_COLS      :: 5
BOARD_SIZE      :: BOARD_ROWS * BOARD_COLS

problem_input := string(#load("../input/04.txt"))
example_input := `7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
`