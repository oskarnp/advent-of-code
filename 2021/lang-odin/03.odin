package day03

import "core:fmt"
import "core:strings"
import "core:text/scanner"
import "core:strconv"
import "core:testing"
import "util"

problem_input := string(#load("../input/03.txt"))
example_input := `00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
`

main :: proc() {
	{
		report := util.parse_integers_from_string(problem_input, 2)
		result := part1(report, 12)
		fmt.println("Part1", result)
	}
	{
		report := util.parse_integers_from_string(problem_input, 2)
		result := part2(report, 12)
		fmt.println("Part2", result)
	}
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	report := util.parse_integers_from_string(example_input, 2)
	result := part1(report, 5)
	testing.expect_value(t, result, 198)
}
@(test)
test_part2 :: proc(t: ^testing.T) {
	report := util.parse_integers_from_string(example_input, 2)
	result := part2(report, 5)
	testing.expect_value(t, result, 230)
}

part1 :: proc(slice: []int, nbits: int) -> int {
	gamma, epsilon: int
	for pos := nbits-1; pos >= 0; pos -= 1 {
		if m := most_common_bit(slice, pos); m > 0 {
			gamma |= 1<<uint(pos)
		} else if m < 0 {
			epsilon |= 1<<uint(pos)
		}
	}
	return gamma*epsilon
}

part2 :: proc(slice: []int, nbits: int) -> int {
	oxygen_rating := search(slice, nbits, proc(s: []int, p: int) -> bool { return most_common_bit(s, p) >= 0 })
	c02_rating    := search(slice, nbits, proc(s: []int, p: int) -> bool { return most_common_bit(s, p)  < 0 })

	search :: proc(slice: []int, nbits: int, test: proc([]int, int) -> bool) -> int {
		slice := slice
		for pos := nbits-1; pos >= 0; pos -= 1 {
			slice = filter(slice, pos, 1 if test(slice, pos) else 0)
			if len(slice) == 1 {
				break
			}
		}
		return slice[0]
	}

	filter :: proc(slice: []int, pos, val: int) -> []int {
		n := len(slice)
		for i := 0; i < n; i += 1 {
			testval := 1 if slice[i] & (1<<uint(pos)) != 0 else 0
			if val != testval {
				slice[i], slice[n-1] = slice[n-1], slice[i]
				n -= 1
				i -= 1
			}
		}
		return slice[:n]
	}

	return oxygen_rating * c02_rating
}

// >0 if 1 is more common
// <0 if 0 is more common
// =0 if 0 and 1 are equally common
most_common_bit :: proc(slice: []int, pos: int) -> (result: int) {
	for x in slice {
		result += +1 if x & (1<<uint(pos)) != 0 else -1
	}
	return
}