package day05

import "core:fmt"
import "core:strings"

main :: proc() {
	input := string(#load("../input/day05.txt"));
	highest_seat_id := 0;
	occupied_seats: [128][8]bool;

	lines := strings.split(input, "\n");
	defer delete(lines);

	for line in lines {
		line := strings.trim_space(line);
		if line == "" do continue;

		lo, hi := 0, 127;
		for ch in line[:7] {
			half := (hi-lo+1)/2;
			switch ch {
			case 'F': hi -= half;
			case 'B': lo += half;
			case: unreachable();
			}
		}
		assert(lo == hi);
		row := lo;

		lo, hi = 0, 7;
		for ch in line[7:] {
			half := (hi-lo+1)/2;
			switch ch {
			case 'L': hi -= half;
			case 'R': lo += half;
			case: unreachable();
			}
		}
		assert(lo == hi);
		col := lo;

		occupied_seats[row][col] = true;

		seat_id := 8*row + col;
		if seat_id > highest_seat_id do highest_seat_id = seat_id;
	}

	fmt.println("Part1:", highest_seat_id);

	// This can be solved programmatically, but visually was just simpler.
	fmt.println("Part2");
	for r, ri in occupied_seats {
		fmt.printf("%03d: ", ri);
		for c in r {
			if c do fmt.printf("x");
			else do fmt.printf(".");
		}
		fmt.printf("\n");
	}
}