const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const print = debug.warn;

const input = @embedFile("../input/day05");
//const input = "1101,100,-1,4,0";

const DEBUG: bool = false;

pub fn main() void {
    part1();
    part2();
}

pub fn part1() void {
    print("day05 part1:\n", .{});
    var program = Program.init();
    program.load();
    _ = program.run(1);
    print("---\n", .{});
}

pub fn part2() void {
    print("day05 part2:\n", .{});
    var program = Program.init();
    program.load();
    _ = program.run(5);
    print("---\n", .{});
}

const Program = struct {
    data: [678]i64,
    size: usize,
    ip: usize,

    const ParameterMode = enum {
        Position  = 0,
        Immediate = 1,
    };

    fn init() Program {
        return Program{
            .data = undefined,
            .size = 0,
            .ip = 0,
        };
    }

    fn load(self: *Program) void {
        self.size = 0;
        var tokens = std.mem.tokenize(input, ",\n");
        while (tokens.next()) |token| {
            const number = std.fmt.parseInt(i64, token, 10) catch unreachable;
            self.data[self.size] = number;
            self.size += 1;
        }
        self.ip = 0;
    }

    inline fn read_addr(self: *Program, addr: usize) i64 {
        return self.data[addr];
    }

    inline fn read_param(self: *Program, mode: usize, n: usize) i64 {
        const r = self.read_addr(self.ip + n);
        return blk: {
            if (mode == 0) {
                if (r < 0) @panic("invalid address");
                break :blk self.read_addr(@intCast(usize, r));
            }
            else {
                break :blk r;
            }
        };
    }

    inline fn write_iaddr(self: *Program, addr: isize, value: i64) void {
        if (addr < 0) @panic("invalid address");
        self.write_addr(@intCast(u64, addr), value);
    }

    inline fn write_addr(self: *Program, addr: usize, value: i64) void {
        self.data[addr] = value;
    }

    fn run(self: *Program, id: i64) i64 {
        var halt: bool = false;
        while (self.ip < self.size and !halt) {
            var modes_opcode = @intCast(u64, self.data[self.ip]);
            var opcode = modes_opcode % 100; modes_opcode /= 100;

            var mode1 = modes_opcode % 10; modes_opcode /= 10;
            var mode2 = modes_opcode % 10; modes_opcode /= 10;
            var mode3 = modes_opcode % 10; modes_opcode /= 10;

            if (DEBUG) print("{:0<4}: ", .{self.ip});
            switch (opcode) {
                1 => { // add
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    var param3 = self.read_addr(self.ip + 3);
                    assert(mode3 == 0 and param3 >= 0);
                    if (DEBUG) print("add {} {} -> @ {}", .{param1, param2, param3});
                    self.write_iaddr(param3, param1 + param2);
                    self.ip += 4;
                },
                2 => { // mul
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    var param3 = self.read_addr(self.ip + 3);
                    assert(mode3 == 0 and param3 >= 0);
                    if (DEBUG) print("mul {} {} -> @ {}\n", .{param1, param2, param3});
                    self.write_iaddr(param3, param1 * param2);
                    self.ip += 4;
                },
                3 => { // input
                    var param1 = self.read_addr(self.ip + 1);
                    assert(mode1 == 0 and param1 >= 0);
                    if (DEBUG) print("input {} -> @ {}\n", .{id, param1});
                    self.write_iaddr(param1, id);
                    self.ip += 2;
                },
                4 => { // output
                    var param1 = self.read_param(mode1, 1);
                    if (DEBUG) print("output {}", .{param1});
                    print("{}\n", .{param1});
                    self.ip += 2;
                },
                5 => { // jump-if-true
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    if (DEBUG) print("jump-if-true {} {}", .{param1, param2});
                    if (param1 != 0) {
                        assert(param2 >= 0);
                        self.ip = @intCast(u64, param2);
                    } else {
                        self.ip += 3;
                    }
                },
                6 => { // jump-if-false
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    if (DEBUG) print("jump-if-false {} {}", .{param1, param2});
                    if (param1 == 0) {
                        assert(param2 >= 0);
                        self.ip = @intCast(u64, param2);
                    } else {
                        self.ip += 3;
                    }
                },
                7 => { // less-than
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    var param3 = self.read_addr(self.ip + 3);
                    assert(mode3 == 0 and param3 >= 0);
                    if (DEBUG) print("less-than {} {} {}", .{param1, param2, param3});
                    if (param1 < param2) {
                        self.write_iaddr(param3, 1);
                    }
                    else {
                        self.write_iaddr(param3, 0);
                    }
                    self.ip += 4;
                },
                8 => { // equals
                    var param1 = self.read_param(mode1, 1);
                    var param2 = self.read_param(mode2, 2);
                    var param3 = self.read_addr(self.ip + 3);
                    assert(mode3 == 0 and param3 >= 0);
                    if (DEBUG) print("less-than {} {} {}", .{param1, param2, param3});
                    if (param1 == param2) {
                        self.write_iaddr(param3, 1);
                    }
                    else {
                        self.write_iaddr(param3, 0);
                    }
                    self.ip += 4;
                },
                99 => {
                    if (DEBUG) print("halt", .{});
                    halt = true;
                },
                else => {
                    print("opcode not supported: {}\n", .{opcode});
                    unreachable;
                },
            }
            if (DEBUG) print("\n", .{});
        }
        return self.data[0];
    }
};

