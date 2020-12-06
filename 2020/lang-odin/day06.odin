package day06

import "core:fmt"
import "core:strings"
import "core:container"

input := string(#load("../input/day06.txt"));

main :: proc() {
	lines := strings.split(input, "\n");
	defer delete(lines);

	group := 0;
	first := true;
	Answer_Set :: bit_set['a'..'z'];
	part1, part2: [500]Answer_Set; // lazy I know

 	for line in lines {
 		line := strings.trim_space(line);
 		if line == "" { // empty line means new group
 			group += 1;
 			first = true;
 			continue;
 		}

 		answers: Answer_Set;
 		for a in line do answers |= {a};
 		part1[group] |= answers;

 		if first do part2[group] |= answers;
		else     do part2[group] &= answers;
		first = false;
 	}
 	group += 1;

 	set_sum :: proc(a: []Answer_Set) -> (sum: int) {
 		for s in a {
 			sum += card(s);
 		}
 		return;
 	}

 	fmt.printf("Part1: %d\nPart2: %d\n", set_sum(part1[:group]), set_sum(part2[:group]));
}

