package day07

import "core:fmt"
import "core:testing"
import "core:slice"
import "util"

main :: proc() {
    fmt.println("Part1", part1(problem_input))
    fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
    testing.expect_value(t, part1(example_input), 37)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    testing.expect_value(t, part2(example_input), 168)
}

part1 :: proc(input: string) -> int {
    xs := util.parse_integers_from_string(input, 0, ",")
    cost :: proc(xs: []int, x0: int) -> (fuel: int) {
        for x in xs {
            fuel += abs(x-x0)
        }
        return
    }
    return least_fuel(xs, cost)
}

part2 :: proc(input: string) -> int {
    xs := util.parse_integers_from_string(input, 0, ",")
    cost :: proc(xs: []int, x0: int) -> (fuel: int) {
        for x in xs {
            n := abs(x-x0)
            fuel += n*(n+1)/2
        }
        return
    }
    return least_fuel(xs, cost)
}

least_fuel :: proc(xs: []int, cost: proc([]int, int) -> int) -> int {
    x1, x2 := slice.min(xs), slice.max(xs)
    minfuel := max(int)
    for x in x1..=x2 {
        minfuel = min(minfuel, cost(xs, x))
    }
    return minfuel
}

problem_input := string(#load("../input/07.txt"))
example_input := `16,1,2,0,4,2,7,1,2,14`