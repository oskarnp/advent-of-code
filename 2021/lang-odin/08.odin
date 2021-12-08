package day08

import "core:fmt"
import "core:testing"
import "core:strings"
import "core:runtime"

Segment_Set :: bit_set['a'..'g']
Display :: [14]Segment_Set
State :: struct {
    displays: [dynamic]Display,
}

parse :: proc(input: string) -> (result: State) {
    i: int
    s: Segment_Set
    d: Display
    for ch in input {
        switch ch {
        case 'a'..'g':
            s += {ch}
        case ' ', '|', '\n':
            if s != {} {
                d[i] = s
                i += 1
            }
            if ch == '\n' {
                assert(i == 14)
                append(&result.displays, d)
                i = 0
            }
            s = {}
        case:
            unreachable()
        }
    }
    return
}

part1 :: proc(input: string) -> (result: int) {
    state := parse(input)
    for display in &state.displays {
        for set in display[10:] {
            switch card(set) {
            case 2, 4, 3, 7: result += 1
            }
        }
    }
    return
}

part2 :: proc(input: string) -> (result: int) {
    state := parse(input)
    for display in &state.displays {
        unique := display[:10]
        output := display[10:]

        resolved :: proc(sets: ..Segment_Set) -> bool {
            for set in sets {
                if set == {} {
                    return false
                }
            }
            return true
        }

        digit: [10]Segment_Set
        analyze: for len(unique) > 0 {
            for set, i in unique {
                modified: bool
                assert(set != {})
                switch card(set) {
                case 2: assert(digit[1] == {}); digit[1] = set; modified = true
                case 4: assert(digit[4] == {}); digit[4] = set; modified = true
                case 3: assert(digit[7] == {}); digit[7] = set; modified = true
                case 7: assert(digit[8] == {}); digit[8] = set; modified = true
                case 6: // 0 or 6 or 9
                    if resolved(digit[1], digit[4]) {
                        if digit[4] < set {
                            assert(digit[9] == {}); digit[9] = set; modified = true
                        } else { // 0 or 6
                            if digit[1] < set {
                                assert(digit[0] == {}); digit[0] = set; modified = true
                            } else {
                                assert(digit[6] == {}); digit[6] = set; modified = true
                            }
                        }
                    }
                case 5: // 2 or 3 or 5
                    if resolved(digit[7], digit[8], digit[9]) {
                        if digit[7] < set {
                            assert(digit[3] == {}); digit[3] = set; modified = true
                        } else { // 2 or 5
                            e := digit[8] - digit[9]
                            if e < set {
                                assert(digit[2] == {}); digit[2] = set; modified = true
                            } else {
                                assert(digit[5] == {}); digit[5] = set; modified = true
                            }
                        }
                    }
                case: unreachable()
                }
                if modified {
                    slice_unordered_remove(&unique, i)
                    continue analyze
                }
            }
        }

        output_value: int
        for set in output {
            for i in 0..<10 do if digit[i] == set {
                output_value *= 10
                output_value += i
            }
        }

        result += output_value
    }
    return
}

slice_unordered_remove :: proc(slice: ^[]$T, i: int) {
    n := len(slice)-1
    if i != n {
        slice[i], slice[n] = slice[n], slice[i]
    }
    (^runtime.Raw_Slice)(slice).len -= 1
}

problem_input := string(#load("../input/08.txt"))
example_input := `be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
`

main :: proc() {
    fmt.println("Part1", part1(problem_input))
    fmt.println("Part2", part2(problem_input))
}

@(test)
test_part1 :: proc(t: ^testing.T) {
    testing.expect_value(t, part1(example_input), 26)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
    testing.expect_value(t, part2(example_input), 61229)
}

