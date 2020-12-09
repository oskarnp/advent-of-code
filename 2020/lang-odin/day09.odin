package day09

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math/bits"

DEBUG :: false;
input := string(#load("../input/day09.txt"));
preamble_length := 25;

main :: proc() {

	make_int_list_from_strings :: proc(slist : []string, allocator := context.allocator) -> []int {
		ok : bool;
		ilist := make([]int, len(slist), allocator);
		for s, i in slist {
			ilist[i], ok = strconv.parse_int(s);
			assert(ok);
		}
		return ilist;
	}

	lines := strings.split(input, "\n");
	defer delete(lines);
	numbers := make_int_list_from_strings(lines);
	defer delete(numbers);

	find_sum_from_list :: proc(sum : int, list : []int) -> (bool, int, int) {
		list := list;
		for len(list) > 0 {
			a := list[0];
			for b in list[1:] {
				if sum - a == b {
					return true, a, b;
				}
			}
			list = list[1:];
		}
		return false, 0, 0;
	}

	cursor := 0;
	for i in preamble_length..<len(numbers) {
		sum := numbers[i];
		ok, a, b := find_sum_from_list(sum, numbers[cursor:][:preamble_length]);
		if ok {
			when DEBUG do fmt.printf("found! %d == %d+%d\n", sum, a, b);
		} else {
			fmt.println("part1 answer", sum);
			part2(sum, i, numbers);
			break;
		}
		cursor += 1;
	}
}

part2 :: proc(sum, idx : int, list : []int) {
	assert(sum == list[idx]);
	slice.reverse(list[:idx]);
	rlist := list;
	outer: for len(rlist) > 0 {
		rsum := 0;
		rmin, rmax := bits.I64_MAX, bits.I64_MIN;
		for r, i in rlist {
			rmin, rmax = min(rmin, r), max(rmax, r);
			rsum += r;
			if rsum > sum {
				rlist = rlist[1:];
				continue outer;
			} else if rsum == sum {
				fmt.println("part2 answer", rmin+rmax);
				return;
			}
		}
	}
}