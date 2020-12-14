package day14

import "core:fmt"
import "core:text/scanner"
import "core:strconv"

puzzle := string(#load("../input/day14.txt"));

sample1 := `
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
`;

sample2 := `
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
`;

U36_MAX :: 1 << 36 - 1;

State :: struct {
	ok                  : bool,
	mask_use, mask_set  : uint,
	mem_addr, mem_value : uint,
	expect              : enum { Ident=0, Mask_Value, Mem_Addr, Mem_Value },
	mem                 : map[uint]uint,
	scan                : scanner.Scanner,
}

main :: proc() {
	// Part 1
	a1 := exec(input = puzzle, eval = proc(using state: ^State) {
		mem[mem_addr] = (mem_value & mask_use) | mask_set;
	});

	// Part 2
	a2 := exec(input = puzzle, eval = proc(using state: ^State) {
		x := transmute(bit_set[0..35;uint]) mask_use;
		n := 1 << uint(card(x));
		for _, i in 0..<n {
			modified_addr := (mem_addr & ~mask_use) | mask_set | mask_floating(uint(i), mask_use);
			mem[modified_addr] = mem_value;
		}
		mask_floating :: proc(value: uint, mask : uint) -> (result: uint) {
			value_bitpos : uint;
			for mask_bitpos := uint(0); mask_bitpos < 36; mask_bitpos += 1 {
				if mask & (1 << mask_bitpos) != 0 {
					if value & (1 << value_bitpos) != 0 {
						result |= 1 << mask_bitpos;
					}
					value_bitpos += 1;
				}
			}
			return;
		}
	});

	fmt.println(a1, a2);
}

exec :: proc(input : string, eval : proc(^State)) -> uint {
	using state : State;
	scanner.init(&scan, input);
	loop: for {
		if expect == .Mask_Value {
			scan_mask_string :: proc(using state: ^State) -> string {
				// NOTE: We are trying to parse an actual string token here but the input
				// data doesn't have quotes around it so need to work around a bit.
				scanner.scan(&scan); // skip '='
				scanner.scan(&scan);
				start := scan.tok_pos;
				scan.whitespace -= 1<<'\n';
				for scanner.scan(&scan) != '\n' {
				}
				scan.whitespace += 1<<'\n';
				end := scan.tok_pos;
				return scan.src[start:end];
			}

			mask_string := scan_mask_string(&state);
			assert(len(mask_string) == 36);
			for ch, i in mask_string {
				pos := uint(35 - i);
				if ch == '1' {
					mask_set |= 1<<pos;
				} else if ch == '0' {
					/* ignore */
				} else if ch == 'X' {
					mask_use |= 1<<pos;
				} else {
					unreachable();
				}
			}
			expect = .Ident;
		}

		tok := scanner.scan(&scan);
		switch tok {
		case scanner.EOF:
			assert(expect == .Ident);
			break loop;
		case '[', ']', '=':
			continue loop;
		case scanner.Ident:
			text := scanner.token_text(&scan);
			if expect == .Mask_Value {
			} else {
				assert(expect == .Ident);
				if text == "mask" {
					mask_use = 0;
					mask_set = 0;
					expect = .Mask_Value;
				} else if text == "mem" {
					expect = .Mem_Addr;
				} else {
					unreachable();
				}
			}
		case scanner.Int:
			#partial switch expect {
			case .Mem_Addr:
				mem_addr, ok = strconv.parse_uint(scanner.token_text(&scan));
				assert(ok);
				expect = .Mem_Value;
			case .Mem_Value:
				mem_value, ok = strconv.parse_uint(scanner.token_text(&scan));
				assert(ok);
				assert(mem_value >= 0 && mem_value <= U36_MAX);
				eval(&state);
				expect = .Ident;
			case:
				fmt.println(scanner.token_text(&scan));
				unreachable();
			}
		case:
			unreachable();
		}
	}

	sum : uint;
	for k, v in mem {
		sum += v;
	}
	return sum;
}