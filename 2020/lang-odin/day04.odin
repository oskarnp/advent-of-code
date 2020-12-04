package day04

import "core:fmt"
import "core:strings"
import "core:reflect"
import "core:strconv"
import "core:text/scanner"

Field :: enum {
	byr, // (Birth Year)
	iyr, // (Issue Year)
	eyr, // (Expiration Year)
	hgt, // (Height)
	hcl, // (Hair Color)
	ecl, // (Eye Color)
	pid, // (Passport ID)
	cid, // (Country ID)
}

Field_Set :: bit_set[Field];

Required_Fields : Field_Set : ~Field_Set{} &~ {.cid};

Passport :: struct {
	fields_set : Field_Set,
	fields : map[Field]string,
}

main :: proc() {
	lines : []string = strings.split(string(#load("../input/day04.txt")), "\n");
	defer delete(lines);
	passports := parse_input(lines);
	defer delete(passports);
	fmt.println("Part1:", part1(passports[:]));
	fmt.println("Part2:", part2(passports[:]));
}

part1 :: proc(passports: []Passport) -> (num_valid: int) {
	for p in passports {
		num_valid += 1 if Required_Fields <= p.fields_set else 0;
	}
	return;
}

part2 :: proc(passports: []Passport) -> (num_valid: int) {
	loop: for p in passports {
		if Required_Fields > p.fields_set do continue loop;

		// byr (Birth Year) - four digits; at least 1920 and at most 2002.
		if !str_valid_int_range(p.fields[.byr], 1920, 2002) do continue loop;

		// iyr (Issue Year) - four digits; at least 2010 and at most 2020.
		if !str_valid_int_range(p.fields[.iyr], 2010, 2020) do continue loop;

		// eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
		if !str_valid_int_range(p.fields[.eyr], 2020, 2030) do continue loop;

		// hgt (Height) - a number followed by either cm or in:
		//   If cm, the number must be at least 150 and at most 193.
		//   If in, the number must be at least 59 and at most 76.
		{
			// NOTE(Oskar):  I really wish parse_int() would give me the rest of the
			// string back but nope - so use Scanner instead.
			hgt := scanner.init(&scanner.Scanner{}, p.fields[.hgt]);
			val, val_ok   := expect_int(hgt);   if !val_ok  do continue loop;
			unit, unit_ok := expect_ident(hgt); if !unit_ok do continue loop;
			switch unit {
			case "cm": if !valid_int_range(val, 150, 193) do continue loop;
			case "in": if !valid_int_range(val, 59, 76)   do continue loop;
			case: continue loop;
			}
		}

		// hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
		{
			hcl := p.fields[.hcl];
			if len(hcl) != 7 do continue loop;
			if hcl[0] != '#' do continue loop;
			for ch in hcl[1:] {
				switch ch {
				case '0'..'9', 'a'..'f': // OK
				case: continue loop;
				}
			}
		}

		// ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
		{
			ecl := p.fields[.ecl];
			switch ecl {
			case "amb", "blu", "brn", "gry", "grn", "hzl", "oth": // OK
			case: continue loop;
			}
		}

		// pid (Passport ID) - a nine-digit number, including leading zeroes.
		{
			pid := p.fields[.pid];
			if len(pid) != 9 do continue loop;
			for ch in pid {
				switch ch {
				case '0' .. '9': // OK
				case: continue loop;
				}
			}
		}

		num_valid += 1;
	}
	return;
}

valid_int_range :: proc(i: int, min, max: int) -> bool {
	return i >= min && i <= max;
}

str_valid_int_range :: proc(str: string, min, max: int) -> bool {
	val, val_ok := strconv.parse_int(str);
	return val_ok && valid_int_range(val, min, max);
}

expect_int :: proc(ps: ^scanner.Scanner) -> (int, bool) {
	tok := scanner.scan(ps);
	if tok == scanner.Int {
		val, val_ok := strconv.parse_int(scanner.token_text(ps));
		return val, val_ok;
	}
	return 0, false;
}

expect_ident :: proc(ps: ^scanner.Scanner) -> (string, bool) {
	tok := scanner.scan(ps);
	if tok == scanner.Ident {
		return scanner.token_text(ps), true;
	}
	return "", false;
}

parse_input :: proc(lines: []string) -> (result: [dynamic]Passport) {
	passport : Maybe(Passport);
	defer delete(lines);
	for line in lines {
		line := strings.trim_space(line);
		if line == "" { // empty line means new passport
			if passport != nil do append(&result, passport.?);
			passport = nil;
			continue;
		}
		passport_copy : Passport = passport.? if passport != nil else Passport{};
		fields : []string = strings.split(line, " ");
		defer delete(fields);
		for f in fields {
			kv : []string = strings.split(f, ":");
			defer delete(kv);
			k := strings.trim_space(kv[0]);
			v := strings.trim_space(kv[1]);
			field_enum, ok := reflect.enum_from_name(Field, k); assert(ok);
			passport_copy.fields_set |= {field_enum};
			passport_copy.fields[field_enum] = v;
		}
		passport = passport_copy;
	}
	if passport != nil do append(&result, passport.?);
	return;
}

Maybe :: union(T: typeid) #maybe {T};
