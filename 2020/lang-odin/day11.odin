package day11

import "core:fmt"
import "core:strings"
import "core:mem"

Directions :: [?][2]int{
	{-1, -1}, { 0, -1}, {+1, -1},
	{-1,  0},           {+1,  0},
	{-1, +1}, { 0, +1}, {+1, +1},
};

Grid :: struct {
	data: []byte,
	rows, cols: int,
}

main :: proc() {
	a1 := part1();
	a2 := part2();
	fmt.println(a1, a2);
}

part1 :: proc() -> int {
	count_adjacent_occupied :: proc(grid: Grid, x, y: int) -> (sum: int) {
		inline for d in Directions {
			sum += 1 if grid_at(grid, x+d.x, y+d.y) == '#' else 0;
		}
		return;
	}
	return simulate(
		rule_empty = proc(grid: Grid, x, y: int) -> bool {
			return count_adjacent_occupied(grid, x, y) == 0;
		},
		rule_occupied = proc(grid: Grid, x, y: int) -> bool {
			return count_adjacent_occupied(grid, x, y) >= 4;
		});
}

part2 :: proc() -> int {
	count_visibly_occupied :: proc(grid: Grid, x, y: int) -> (sum: int) {
		outer: for d,i in Directions {
			tx, ty := x, y;
			inner: for {
				tx += d.x;
				ty += d.y;
				switch grid_at(grid, tx, ty) {
				case '#':
					sum += 1;
					continue outer;
				case 'L', '?':
					break inner;
				}
			}
		}
		return;
	}
	return simulate(
		rule_empty = proc(grid: Grid, x, y: int) -> bool {
			return count_visibly_occupied(grid, x, y) == 0;
		},
		rule_occupied = proc(grid: Grid, x, y: int) -> bool {
			return count_visibly_occupied(grid, x, y) >= 5;
		});
}

grid_at :: proc(using grid: Grid, x, y: int) -> byte {
	if 0 <= y && y < rows {
		if 0 <= x && x < cols {
			#no_bounds_check
			return data[y*cols + x];
		}
	}
	return '?';
}

clone_grid :: proc(grid: Grid, allocator := context.allocator) -> Grid {
	return {
		data = mem.clone_slice(grid.data, allocator),
		rows = grid.rows,
		cols = grid.cols,
	};
}

simulate :: proc(rule_empty, rule_occupied: proc(Grid, int, int) -> bool) -> int {
	data, rows, cols := parse_input();
	defer delete(data);
	grid := Grid{data, rows, cols};
	#no_bounds_check for {
		keep_going : bool;
		temp_grid := clone_grid(grid, context.temp_allocator);
		for y in 0..<rows {
			for x in 0..<cols {
				at := &data[y*cols + x];
				switch grid_at(temp_grid, x, y) {
				case 'L': if rule_empty(temp_grid, x, y)    { keep_going = true; at^ = '#'; }
				case '#': if rule_occupied(temp_grid, x, y) { keep_going = true; at^ = 'L'; }
				}
			}
		}
		if !keep_going do break;
	}
	count_all_occupied :: proc(using grid: Grid) -> (sum: int) {
		for ch in data {
			sum += 1 if ch == '#' else 0;
		}
		return;
	}
	return count_all_occupied(grid);
}

parse_input :: proc() -> (grid: []byte, rows, cols: int) {
	sb: strings.Builder;
	strings.init_builder(&sb);
	lines := strings.split(string(#load("../input/day11.txt")), "\n");
	defer delete(lines);
	for line in lines {
		line := strings.trim_space(line);
		if line == "" do continue;
		if cols == 0 do cols = len(line);
		rows += 1;
		strings.write_string(&sb, line);
	}
	grid = transmute([]byte) strings.to_string(sb);
	return;
}