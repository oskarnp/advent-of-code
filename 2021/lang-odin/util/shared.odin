package aoc_2021_util

import "core:strings"
import "core:strconv"

parse_integers_from_string :: proc(input: string, base := 0, sep := "\n", allocator := context.allocator) -> []int {
	context.allocator = allocator
	n: int
	ok: bool
	lines := strings.split(input, sep)
	numbers := make([]int, len(lines))
	for line in lines {
		#no_bounds_check numbers[n], ok = strconv.parse_int(strings.trim_space(line), base)
		if ok {
			n += 1
		}
	}
	return numbers[:n]
}