package day02

import "core:fmt"
import "core:strings"
import "core:text/scanner"
import "core:strconv"
import "core:testing"

problem_input := string(#load("../input/02.txt"))
example_input := `forward 5
down 5
forward 8
up 3
down 8
forward 2`

main :: proc() {
	r1 := part1(problem_input)
	fmt.println("Part1", r1.x*r1.y)
	r2 := part2(problem_input)
	fmt.println("Part2", r2.x*r2.y)
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	r := part1(example_input)
	testing.expect_value(t, r.x*r.y, 150)
}
@(test)
test_part2 :: proc(t: ^testing.T) {
	r := part2(example_input)
	testing.expect_value(t, r.x*r.y, 900)
}

part1 :: proc(input: string) -> (r: [2]int) {
	using scanner
	s := init(&Scanner{}, input)
	loop: for {
		c := expect_ident(s)
		n := expect_int(s)
		switch c {
		case "forward": r += {+n, 0}
		case "down":    r += {0, +n}
		case "up":      r += {0, -n}
		}
		if peek_token(s) == EOF {
			break loop
		}
	}
	return
}

part2 :: proc(input: string) -> (r: [3]int) {
	using scanner
	s := init(&Scanner{}, input)
	loop: for {
		c := expect_ident(s)
		n := expect_int(s)
		switch c {
		case "down":    r += {0, 0, +n}
		case "up":      r += {0, 0, -n}
		case "forward": r += {+n, +n*r.z, 0}
		}
		if peek_token(s) == EOF {
			break loop
		}
	}
	return
}

expect_ident :: proc(s: ^scanner.Scanner) -> string {
	using scanner
	ch := scan(s)
	if ch != Ident {
		fmt.panicf("expected identifier at {}:{}", s.line, s.column)
	}
	return token_text(s)
}

expect_int :: proc(s: ^scanner.Scanner) -> int {
	using scanner
	ch := scan(s)
	if ch != Int {
		fmt.panicf("expected int @ {}:{}", s.line, s.column)
	}
	value, ok := strconv.parse_int(token_text(s))
	if !ok {
		fmt.panicf("invalid int @ {}:{}", s.line, s.column)
	}
	return value
}
