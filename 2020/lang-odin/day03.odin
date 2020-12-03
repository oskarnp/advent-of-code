package day03

import "core:fmt"
import "core:strings"

main :: proc() {
	grid := strings.split(string(#load("../input/day03.txt")), "\n");
	part1(grid);
	part2(grid);
}

part1 :: proc(grid: []string) {
	fmt.println("Part1:", count_trees(3, 1, grid));
}

part2 :: proc(grid: []string) {
	slopes := [?][2]int{ {1,1}, {3,1}, {5,1}, {7,1}, {1,2} };
	result := 1;
	for slope in slopes {
		result *= count_trees(slope.x, slope.y, grid);
	}
	fmt.println("Part2:", result);
}

count_trees :: proc(dx, dy: int, grid: []string) -> (sum: int) {
	x, y: int;
	mod := len(grid[0]) - 1; // -1 since '\n' is part of string
	for y < len(grid) {
		if grid[y][x%mod] == '#' {
			sum += 1;
		}
		x += dx;
		y += dy;
	}
	return;
}
