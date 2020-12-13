package day13

import "core:fmt"
import "core:strings"
import "core:strconv"

input  := string(#load("../input/day13.txt"));

main :: proc() {
	a1 := part1();
	a2 := part2();
	fmt.println(a1, a2);
}

part1 :: proc() -> int {
	lines := strings.split(input, "\n");
	estimate, estimate_ok := strconv.parse_int(strings.trim_space(lines[0]));
	assert(estimate_ok);

	id_list : [dynamic]int;
	str_id_list := strings.split(strings.trim_space(lines[1]), ",");
	for str_id in str_id_list {
		id, ok := strconv.parse_int(str_id);
		if !ok do continue;
		append(&id_list, id);
	}

	for time := estimate; ; time += 1 {
		for id in id_list {
			if time % id == 0 {
				return id*(time-estimate);
			}
		}
	}
}

part2 :: proc() -> int {
	lines := strings.split(input, "\n");
	estimate, estimate_ok := strconv.parse_int(strings.trim_space(lines[0]));
	assert(estimate_ok);

	Bus :: struct {
		id: int,
		offset: int,
	};
	buses : [dynamic]Bus;

	offset : int;
	str_id_list := strings.split(strings.trim_space(lines[1]), ",");
	for str_id in str_id_list {
		id, ok := strconv.parse_int(str_id);
		if ok {
			append(&buses, Bus{id, offset});
		}
		offset += 1;
	}

	time, increment := 0, 1;
	for bus in buses {
		for (time + bus.offset) % bus.id != 0 {
			time += increment;
		}
		increment *= bus.id;
	}
	return time;
}