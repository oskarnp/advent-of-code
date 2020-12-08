package day08

import "core:fmt"
import "core:text/scanner"
import "core:strconv"
import "core:container"

DEBUG :: false;

input := string(#load("../input/day08.txt"));
possibly_corrupt : container.Queue(int); /* addresses to patch */

Instr :: struct {
	opcode : string,
	offset : int,
	addr   : int,
}

Program :: struct {
	pc, acc : int,
	instrs  : [dynamic] Instr,
	success : bool,
	hit     : [1000] b8,
	patch   : Maybe(int),
}

main :: proc() {
	part1();
	part2();
}

part1 :: proc() {
	prg : Program;
	load(&prg);
	exec(&prg);
	assert(prg.success == false);
	fmt.println("Part 1:", prg.acc);
}

part2 :: proc() {
	prg : Program;
	load(&prg);
	for container.queue_len(possibly_corrupt) > 0 {
		prg.patch = container.queue_pop_front(&possibly_corrupt);
		exec(&prg);
		if prg.success {
			fmt.println("Part 2:", prg.acc);
			return;
		}
		reset(&prg);
	}
	unreachable();
}

reset_full :: proc(prg : ^Program) {
	clear(&prg.instrs);
	reset(prg);
}

reset :: proc(using prg : ^Program) {
	pc = 0;
	acc = 0;
	success = false;
	hit = {};
	patch = nil;
}

load :: proc(prg: ^Program) {
	reset_full(prg);
	address := 0;
	container.queue_clear(&possibly_corrupt);
	s := scanner.init(&scanner.Scanner{}, string(input));
	for scanner.peek(s) != scanner.EOF {
		opcode := scan_ident(s);
		sign   := scan_rune(s);
		offset := scan_int(s);
		append(&prg.instrs, Instr{opcode, offset if sign=='+' else -offset, address});
		if opcode == "jmp" || opcode == "nop" {
			container.queue_push_front(&possibly_corrupt, address);
		}
		address += 1;
	}
}

exec :: proc(using prg: ^Program) {
	for {
		if pc >= len(instrs) {
			success = true;
			return;
		}

		ins := &instrs[pc];
		when DEBUG do fmt.printf("%s %+d acc %d\n", ins.opcode, ins.offset, acc);

		if hit[ins.addr] {
			success = false;
			return;
		}
		hit[ins.addr] = true;

		opcode := ins.opcode;
		if patch != nil && ins.addr == patch.? {
			when DEBUG do fmt.println("patching", ins.addr);
			if opcode == "jmp" {
				opcode = "nop";
			} else if opcode == "nop" {
				opcode = "jmp";
			}
		}

		switch opcode {
		case "nop": pc  += 1;
		case "acc": acc += ins.offset;
			        pc  += 1;
		case "jmp": pc  += ins.offset;
		case: unreachable();
		}
	}
}

scan_ident :: proc(s: ^scanner.Scanner) -> string { tok := scanner.scan(s); assert(tok == scanner.Ident); return scanner.token_text(s); }
scan_rune  :: proc(s: ^scanner.Scanner) -> rune   { tok := scanner.scan(s); return tok; }
scan_int   :: proc(s: ^scanner.Scanner) -> int    { tok := scanner.scan(s); assert(tok == scanner.Int); val, ok := strconv.parse_int(scanner.token_text(s)); assert(ok); return val; }