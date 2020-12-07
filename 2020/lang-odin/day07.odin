package day07

import "core:fmt"
import "core:text/scanner"
import "core:strconv"

N :: 100;

dict: map[string]Bag;

Bag :: struct {
	num:     int,
	amounts: [N]int,
	colors:  [N]string,
}

main :: proc() {
	input := string(#load("../input/day07.txt"));

	/*
		Pseudo EBNF

		spec        = color "bags contain" nbag { "," nbag } "." .
		color       = ident " " ident .
		nbag        = decimal_int " " color " " ( "bag" | "bags" )
			        | "no other bags"
			        .
		ident       = "a" ... "z" .
		decimal_int = "1" ... "9" { "0" ... "9" }

		NOTE: scanner allows more than this, but out-of-scope to do strict parsing.
	*/
	s := scanner.init(&scanner.Scanner{}, input);
	for scanner.peek(s) != scanner.EOF {
		a := scan_color(s);
		scan_ident(s); // "bags"
		scan_ident(s); // "contain"
		inner: for {
			switch scanner.peek_token(s) {
			case scanner.Ident:
				scan_ident(s); // "no"
				scan_ident(s); // "other"
				scan_ident(s); // "bags"
			case '.':
				scanner.next(s);
				break inner;
			case ',':
				scanner.next(s);
				fallthrough;
			case scanner.Int:
				n := scan_int(s);
				b := scan_color(s);
				scan_ident(s); // "bags" | "bag"
				d: ^Bag;
				if a in dict {
					d = &dict[a];
				} else {
					dict[a] = {};
					d = &dict[a];
				}
				d.amounts[d.num] = n;
				d.colors[d.num] = b;
				d.num += 1;
			case:
				unreachable();
			}
		}
	}

	part1 :: proc() -> (sum: int) {
		recursive_exists :: proc(k, s: string) -> bool {
			if k == s do return true;
			v, ok := dict[k];
			if ok {
				for i in 0..<v.num {
					if recursive_exists(v.colors[i], s) {
						return true;
					}
				}
			}
			return false;
		}

		search := "shiny gold";
		for k, v in dict {
			if k != search {
				sum += 1 if recursive_exists(k, search) else 0;
			}
		}
		return;
	}

	part2 :: proc() -> int {
		recursive_sum :: proc(k : string) -> (sum: int) {
			v, ok := dict[k];
			if ok {
				for i in 0..<v.num {
					sum += v.amounts[i] + v.amounts[i] * recursive_sum(v.colors[i]);
				}
			}
			return;
		}
		return recursive_sum("shiny gold");
	}

	fmt.println(part1(), part2());
}

scan_color :: proc(s: ^scanner.Scanner) -> string {
	tok1_pos, tok2_end: int;
	tok1 := scanner.scan(s); assert(tok1 == scanner.Ident);
	tok1_pos = s.tok_pos;
	tok2 := scanner.scan(s); assert(tok2 == scanner.Ident);
	tok2_end = s.tok_end;
	return string(s.src[tok1_pos:tok2_end]);
}

scan_ident :: proc(s: ^scanner.Scanner) -> string {
	tok := scanner.scan(s);
	assert(tok == scanner.Ident);
	return scanner.token_text(s);
}

scan_int :: proc(s: ^scanner.Scanner) -> int {
	tok := scanner.scan(s);
	assert(tok == scanner.Int);
	val, val_ok := strconv.parse_int(scanner.token_text(s));
	assert(val_ok);
	return val;
}