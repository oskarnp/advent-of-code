package day02

import "core:fmt"
import "core:text/scanner"
import "core:strconv"

main :: proc() {
	s: scanner.Scanner;
	scanner.init(&s, string(#load("../input/day02.txt")));
	part1(s);
	part2(s);
}

part1 :: proc(s: scanner.Scanner) {
	s := s;
	num_valid: int;
	for {
		if scanner.peek(&s) == scanner.EOF do break;
		min, max, test_ch := get_spec(&s);
		counter: int;
		inner: for {
			switch password_ch := scanner.next(&s); password_ch {
			case scanner.EOF, '\n': break inner;
			case test_ch: counter += 1;
			}
		}
		if counter >= min && counter <= max {
			num_valid += 1;
		}
	}
	fmt.println("part1:", num_valid);
}

part2 :: proc(s: scanner.Scanner) {
	s := s;
	num_valid: int;
	for {
		if scanner.peek(&s) == scanner.EOF do break;
		min, max, test_ch := get_spec(&s);
		valid: bool;
		position: int = 1;
		inner: for {
			switch password_ch := scanner.next(&s); password_ch {
			case scanner.EOF, '\n': break inner;
			case test_ch: valid ~= position == min || position == max;
			}
			position += 1;
		}
		if valid do num_valid += 1;
	}
	fmt.println("part2:", num_valid);
}

get_spec :: proc(s: ^scanner.Scanner) -> (min: int, max: int, ch: rune) {
	get_int :: proc(p: ^scanner.Scanner) -> int {
		tok := scanner.scan(p);
		assert(tok == scanner.Int);
		num, ok := strconv.parse_int(scanner.token_text(p));
		assert(ok);
		return num;
	}
	min = get_int(s);
	scanner.next(s); // skip '-'
	max = get_int(s);
	scanner.next(s); // skip ' '
	ch = scanner.next(s);
	scanner.next(s); // skip ':'
	scanner.next(s); // skip ' '
	return;
}