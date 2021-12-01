package aoc_2021_util

import "core:strings"
import "core:strconv"

parse_integers_from_string :: proc(input: string, allocator := context.allocator) -> []int {
	context.allocator = allocator
	n: int
	ok: bool
	lines := strings.split(input, "\n")
	numbers := make([]int, len(lines))
	for line in lines {
		#no_bounds_check numbers[n], ok = strconv.parse_int(strings.trim_space(line))
		if ok {
			n += 1
		}
	}
	return numbers[:n]
}