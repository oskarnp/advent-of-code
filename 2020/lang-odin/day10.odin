package day10

import "core:slice"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:math"

jolts: [dynamic]int;

main :: proc() {
	lines := strings.split(string(#load("../input/day10.txt")), "\n");
	for line in lines {
		line := strings.trim_space(line);
		if line == "" do continue;
		jolt, ok := strconv.parse_int(line);
		assert(ok);
		append(&jolts, jolt);
	}

	append(&jolts, 0);
	slice.sort(jolts[:]);
	append(&jolts, 3 + slice.last(jolts[:]));

	a1 := part1();
	a2 := part2();
	fmt.println("Part 1", a1);
	fmt.println("Part 2", a2);
}

part1 :: proc() -> int {
	sums : [4]int;
	for j := 1; j < len(jolts); j += 1 {
		sums[jolts[j] - jolts[j-1]] += 1;
	}
	return sums[1] * sums[3];
}

part2 :: proc() -> int {
	m : map[int]int;
	m[0] = 1;
	for i := 1; i < len(jolts); i += 1 {
		m[i] = 0;
		for j := i - 1; j >= 0 && jolts[i] - jolts[j] <= 3; j -= 1 {
			m[i] += m[j];
		}
	}
	return m[len(m)-1];
}