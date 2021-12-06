package day06

import "core:fmt"
import "core:testing"
import "core:math"
import "util"

main :: proc() {
    fmt.println("Part1", part1(problem_input))
    fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
    testing.expect_value(t, part1(example_input), 5934)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    testing.expect_value(t, part2(example_input), 26984457539)
}

part1 :: proc(input: string) -> int {
    initial_state := util.parse_integers_from_string(input, 0, ",")
    return simulate(initial_state, 80)
}

part2 :: proc(input: string) -> int {
    initial_state := util.parse_integers_from_string(input, 0, ",")
    return simulate(initial_state, 256)
}

problem_input := string(#load("../input/06.txt"))
example_input := `3,4,3,1,2`

simulate :: proc(initial_state: []int, days: int) -> int {
    fishes: [9]int // number of fishes at [age]
    for age in initial_state {
        fishes[age] += 1
    }
    for in 1..=days {
        births := fishes[0]
        #unroll for i in 0..<len(fishes)-1 {
            fishes[i] = fishes[i+1]
        }
        fishes[6] += births
        fishes[8]  = births
    }
    return math.sum(fishes[:])
}