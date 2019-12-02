const std = @import("std");
const input = @embedFile("../input/day02");

const Program = struct {
    data: [200]u64,
    size: u64,

    fn init() Program {
        return Program{
            .data = undefined,
            .size = 0,
        };
    }

    fn load(self: *Program, noun: u64, verb: u64) void {
        std.debug.assert(self.size == 0);

        var tokens = std.mem.tokenize(input, ",\n");
        while (tokens.next()) |token| {
            const number = std.fmt.parseInt(u64, token, 10) catch unreachable;
            self.data[self.size] = number;
            self.size += 1;
        }

        self.data[1] = noun;
        self.data[2] = verb;
    }

    fn run(self: *Program) u64 {
        var ip: u32 = 0;
        loop: while (ip < self.size): (ip += 4) {
            var opcode = self.data[ip];
            if (opcode == 99) break :loop;

            var param1 = self.data[ip+1];
            var param2 = self.data[ip+2];
            var param3 = self.data[ip+3];
            switch (opcode) {
                1 => self.data[param3] = self.data[param1] + self.data[param2],
                2 => self.data[param3] = self.data[param1] * self.data[param2],
                else => unreachable,
            }
        }
        return self.data[0];
    }
};

fn part1() u64 {
    var program = Program.init();
    program.load(12, 2);
    return program.run();
}

fn part2() u64 {
    var noun: u64 = 0;
    while (noun < 100): (noun += 1) {
        var verb: u64 = 0;
        while (verb < 100): (verb += 1) {
            var program = Program.init();
            program.load(noun, verb);
            var result = program.run();
            if (result == 19690720) {
                return 100*noun + verb;
            }
        }
    }
    unreachable;
}

pub fn main() void {
    var answer1 = part1();
    var answer2 = part2();
    std.debug.warn("day02 {} {}\n", answer1, answer2);
}
