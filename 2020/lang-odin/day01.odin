package day01

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	numbers: [dynamic]int;
	input := #load("../input/day01.txt");
	lines := strings.split(cast(string)input, "\n");
	for line in lines {
		number, ok := strconv.parse_int(line);
		if !ok do break;
		append(&numbers, number);
	}

	part1 :: proc(n: []int) { 
		loop:
		for a in n {
			for b in n {
				if a + b == 2020 {
					fmt.println("Part1:", a*b);
					break loop;
				}
			}
		}
	}

	part2 :: proc(n: []int) { 
		loop:
		for a in n {
			for b in n {
				for c in n {
					if a + b + c == 2020 {
						fmt.println("Part2:", a*b*c);
						break loop;
					}
				}
			}
		}
	}

	part1(numbers[:]);
	part2(numbers[:]);
}