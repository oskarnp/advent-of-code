package day01

import "core:fmt"
import "core:math"
import "util"

main :: proc() {
	result: int

	example_numbers := []int{199, 200, 208, 210, 200, 207, 240, 269, 260, 263}
	assert(part1(example_numbers) == 7)
	assert(part2(example_numbers) == 5)

	problem_numbers := util.parse_integers_from_string(string(#load("../input/01.txt")))
	fmt.println("Part1:", part1(problem_numbers))
	fmt.println("Part2:", part2(problem_numbers))
}

part1 :: proc(ns: []int) -> (count: int) {
	previous_value := ns[0]
	for n in ns[1:] {
		value := n
		if value > previous_value {
			count += 1
		}
		previous_value = value
	}
	return
}

part2 :: proc(ns: []int) -> int {
	remain := ns
	count, sum, previous_sum: int

	previous_sum, remain = sum_and_slide(remain)
	for len(remain) >= 3 {
		sum, remain = sum_and_slide(remain)
		if sum > previous_sum {
			count += 1
		}
		previous_sum = sum
	}

	sum_and_slide :: proc(ns: []int) -> (result: int, remain: []int) {
		result = math.sum(ns[:3])
		remain = ns[1:]
		return
	}

	return count
}
