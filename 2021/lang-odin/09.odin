package day09

import "core:fmt"
import "core:testing"
import "core:strings"
import "core:slice"

State :: struct {
	map_rows, map_cols: int,
	heightmap: []int,
	visited: []bool,
}

index_map :: #force_inline proc(using state: State, row, col: int) -> int {
	return row*map_cols + col
}

print_map :: proc(using state: State) {
	for row in 0..<map_rows {
		for col in 0..<map_cols {
			fmt.printf("%d", heightmap[index_map(state, row, col)])
		}
		fmt.printf("\n")
	}
}

parse :: proc(input: string) -> (state: State) {
	lines := strings.split(input, "\n")
	state.map_rows = 2+len(lines)
	state.map_cols = 2+len(lines[0])
	state.heightmap = make([]int, state.map_rows*state.map_cols)
	state.visited = make([]bool, state.map_rows*state.map_cols)
	slice.fill(state.heightmap, 9)
	for line, row in lines {
		i := index_map(state, row+1, 1)
		for ch, col in line {
			state.heightmap[i+col] = int(ch) - int('0')
		}
	}
	return
}

part1 :: proc(input: string) -> (result: int) {
	state := parse(input)
	for row in 1..<state.map_rows-1 {
		#no_bounds_check for col in 1..<state.map_cols-1 {
			a := state.heightmap[index_map(state, row+0, col+0)]
			if a<state.heightmap[index_map(state, row-1, col+0)] &&
			   a<state.heightmap[index_map(state, row+1, col+0)] &&
			   a<state.heightmap[index_map(state, row+0, col-1)] &&
			   a<state.heightmap[index_map(state, row+0, col+1)]
	   		{ result += 1+a }
		}
	}
	return
}

part2 :: proc(input: string) -> (result: int) {
	state := parse(input)
	basin_size :: proc(using state: State, row, col: int) -> (size: int) {
		i := index_map(state, row, col)
		a := heightmap[i]
		if !visited[i] && a != 9 {
			visited[i] = true
			size += 1
			size += basin_size(state, row+1, col+0)
			size += basin_size(state, row-1, col+0)
			size += basin_size(state, row+0, col+1)
			size += basin_size(state, row+0, col-1)
		}
		return
	}
	basins: [dynamic]int
	for row in 1..<state.map_rows-1 {
		for col in 1..<state.map_cols-1 {
			size := basin_size(state, row, col)
			if size>0 { append(&basins, size) }
		}
	}
	slice.reverse_sort(basins[:])
	return basins[0]*basins[1]*basins[2]
}

main :: proc() {
	fmt.println("Part1", part1(problem_input))
	fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(example_input), 15)
}
@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(example_input), 1134)
}

example_input := `2199943210
3987894921
9856789892
8767896789
9899965678`
problem_input := string(#load("../input/09.txt"))