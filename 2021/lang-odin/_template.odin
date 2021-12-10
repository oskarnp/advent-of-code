package dayXX

import "core:fmt"
import "core:testing"

State :: struct {
}

parse :: proc(input: string) -> (state: State) {
	return
}

part1 :: proc(input: string) -> (result: int) {
	state := parse(input)
	return
}

part2 :: proc(input: string) -> (result: int) {
	state := parse(input)
	return
}

main :: proc() {
	fmt.println("Part1", part1(problem_input))
	fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(example_input), max(int))
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(example_input), max(int))
}

example_input := ``
problem_input := string(#load("../input/XX.txt"))
