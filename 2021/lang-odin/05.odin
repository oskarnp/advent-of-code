package day05

import "core:fmt"
import "core:testing"
import "core:strconv"
import "core:text/scanner"
import "core:math/linalg"

main :: proc() {
	fmt.println("Part1", part1(problem_input))
	fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(example_input), 5)
}
@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(example_input), 12)
}

count_overlaps :: proc(input: string, allow_diagonals: bool) -> int {
	grid: map[Point]int
	state := parse(input)
	for line in state.lines {
		if allow_diagonals || (line.p1.x == line.p2.x || line.p1.y == line.p2.y) {
			dir := linalg.clamp(line.p2 - line.p1, -1, +1)
			for p := line.p1; p != line.p2 + dir; p += dir {
				grid[p] += 1
			}
		}
	}
	n := 0
	for _, v in grid do if v >= 2 {
		n += 1
	}
	return n
}

part1 :: proc(input: string) -> int {
	return count_overlaps(input, false)
}
part2 :: proc(input: string) -> int {
	return count_overlaps(input, true)
}

problem_input := string(#load("../input/05.txt"))
example_input := `0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2`

parse :: proc(input: string) -> (result: State) {
	using scanner
	i := 0
	s := init(&Scanner{}, input)
	s.whitespace += {'-', '>', ','}
	line: Line
	loop: for {
		tok := scan(s)
		switch tok {
		case EOF: break loop
		case Int:
			n, ok := strconv.parse_int(token_text(s))
			assert(ok)
			switch i {
			case 0: line.p1.x = n
			case 1: line.p1.y = n
			case 2: line.p2.x = n
			case 3: line.p2.y = n
			case:   unreachable()
			}
			i += 1
			if i == 4 {
				append(&result.lines, line)
				line = {}
				i = 0
			}
		case:
			unreachable()
		}
	}
	return
}

State :: struct {
	lines: [dynamic]Line,
}

Line :: struct {
	p1, p2: Point,
}

Point :: [2]int
