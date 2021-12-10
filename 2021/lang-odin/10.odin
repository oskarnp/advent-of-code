package day10

import "core:fmt"
import "core:testing"
import "core:strings"
import "core:slice"

part1 :: proc(input: string) -> (score: int) {
	corrupt: bool
	stack: [dynamic]rune
	for ch in input {
		if ch == '\n' {
			corrupt = false
			clear(&stack)
		} else if !corrupt do switch ch {
			case '{','[','(','<':
				append(&stack, ch)
			case ')': if len(stack) == 0 || pop(&stack) != '(' { score += 3;     corrupt = true }
			case ']': if len(stack) == 0 || pop(&stack) != '[' { score += 57;    corrupt = true }
			case '}': if len(stack) == 0 || pop(&stack) != '{' { score += 1197;  corrupt = true }
			case '>': if len(stack) == 0 || pop(&stack) != '<' { score += 25137; corrupt = true }
			case: unreachable()
		}
	}
	return
}

part2 :: proc(input: string) -> int {
	stack:   [dynamic]rune
	scores:  [dynamic]int
	corrupt: bool
	for ch in input {
		switch ch {
		case '{','[','(','<':
			if !corrupt { append(&stack, ch) }
		case ')': if len(stack) == 0 || pop(&stack) != '(' { corrupt = true }
		case ']': if len(stack) == 0 || pop(&stack) != '[' { corrupt = true }
		case '}': if len(stack) == 0 || pop(&stack) != '{' { corrupt = true }
		case '>': if len(stack) == 0 || pop(&stack) != '<' { corrupt = true }
		case '\n':
			incomplete := len(stack) != 0
			if incomplete && !corrupt {
				slice.reverse(stack[:])
				append(&scores, completion_score(stack[:]))
			}
			clear(&stack)
			corrupt = false
		case:
			unreachable()
		}
	}

	completion_score :: proc(slice: []rune) -> (score: int) {
		for ch in slice {
			switch ch {
			case '(',')': score = 5*score + 1
			case '[',']': score = 5*score + 2
			case '{','}': score = 5*score + 3
			case '<','>': score = 5*score + 4
			case: unreachable()
			}
		}
		return
	}

	slice.sort(scores[:])
	return scores[len(scores)/2]
}

main :: proc() {
	fmt.println("Part1", part1(problem_input))
	fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(example_input), 26397)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(example_input), 288957)
}

example_input := `[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
`
problem_input := string(#load("../input/10.txt"))