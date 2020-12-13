package day12

import "core:fmt"
import "core:text/scanner"
import "core:strconv"

Instruction :: struct {
	action : rune,
	amount : int,
}

main :: proc() {
	a1 := part1();
	a2 := part2();
	fmt.println(a1, a2);
}

part1 :: proc() -> int {
	ship_heading  := 90;
	ship_position := [2]int{0, 0};

	instructions := parse();
	defer delete(instructions);

	for inst in instructions {
		switch inst.action {
		case 'F':
			ship_position += inst.amount * direction_vector(ship_heading);
		case 'N', 'S', 'E', 'W':
			ship_position += inst.amount * direction_vector(action_to_heading(inst.action));
		case 'L':
			ship_heading -= inst.amount;
		case 'R':
			ship_heading += inst.amount;
		case:
			unreachable();
		}
	}

	return manhattan_distance(ship_position, {0,0});
}

part2 :: proc() -> int {
	ship_position := [2]int{0, 0};
	waypoint_relposition := [2]int{+10, +1};

	instructions := parse();
	defer delete(instructions);

	rotate_vector :: proc(degrees: int, v: [2]int) -> [2]int {
		switch degrees %% 360 {
		case   0: return v;
		case  90: return { v.y, -v.x};
		case 180: return {-v.x, -v.y};
		case 270: return {-v.y,  v.x};
		case: unreachable();
		}
	}

	for inst in instructions {
		switch inst.action {
		case 'F':
			ship_position += inst.amount * waypoint_relposition;
		case 'N', 'S', 'E', 'W':
			waypoint_relposition += inst.amount * direction_vector(action_to_heading(inst.action));
		case 'L':
			waypoint_relposition = rotate_vector(-inst.amount, waypoint_relposition);
		case 'R':
			waypoint_relposition = rotate_vector(+inst.amount, waypoint_relposition);
		case:
			unreachable();
		}
	}

	return manhattan_distance(ship_position, {0,0});
}

action_to_heading :: proc(action: rune) -> int {
	switch action {
	case 'N': return 0;
	case 'E': return 90;
	case 'S': return 180;
	case 'W': return 270;
	case: unreachable();
	}
}

direction_vector :: proc(heading: int) -> [2]int {
	switch heading %% 360 {
		case   0: return { 0, +1};
		case  90: return {+1,  0};
		case 180: return { 0, -1};
		case 270: return {-1,  0};
		case: unreachable();
	}
}

manhattan_distance :: proc(a, b: [2]int) -> int {
	return abs(a.x - b.x) + abs(a.y - b.y);
}

parse :: proc() -> (list: [dynamic]Instruction) {
	next : Instruction;
	s := scanner.init(&scanner.Scanner{}, string(#load("../input/day12.txt")));
	loop: for {
		switch tok := scanner.peek(s); tok {
		case scanner.EOF: break loop;
		case 'A'..'Z':
			next.action = scanner.next(s);
		case '0'..'9':
			ok : bool;
			tok := scanner.scan(s);
			assert(tok == scanner.Int);
			next.amount, ok = strconv.parse_int(scanner.token_text(s));
			assert(ok);
			append(&list, next);
			next = {};
		case:
			scanner.next(s);
		}
	}
	return;
}