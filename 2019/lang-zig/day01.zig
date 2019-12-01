const std = @import("std");
const debug = std.debug;

fn part1(input: []u8) i32 {
    var answer: i32 = 0;

    var n: i32 = 0;
    for (input) |c| {
        switch (c) {
            '0' ... '9' => {
                n *= 10;
                n += @as(i32, c - '0');
            },

            '\n' => {
                answer += std.math.max(0, @divTrunc(n, 3) - 2);
                n = 0;
            },

            else => unreachable,
        }
    }

    return answer;
}

fn part2(input: []u8) i32 {
    var answer: i32 = 0;

    var n: i32 = 0;
    for (input) |c| {
        switch (c) {
            '0' ... '9' => {
                n *= 10;
                n += @as(i32, c - '0');
            },

            '\n' => {
                var mass = n;
                while (true) {
                    const fuel = std.math.max(0, @divTrunc(mass, 3) - 2);
                    if (fuel == 0) break;
                    answer += fuel;
                    mass = fuel;
                }
                n = 0;
            },

            else => unreachable,
        }
    }

    return answer;
}

var memory: [0x1000]u8 = undefined;

pub fn main() !void {
    const path = "input/day01";

    var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(memory[0..]);
    var allocator = &fixed_buffer_allocator.allocator;

    var input = try read_entire_file(path, allocator);
    defer allocator.free(input);

    var answer1 = part1(input);
    var answer2 = part2(input);

    debug.warn("day01 {} {}\n", answer1, answer2);
}

fn read_entire_file(path: []const u8, allocator: *std.mem.Allocator) ![]u8 {
    const file = try std.fs.File.openRead(path);
    defer file.close();

    const stat = try file.stat();

    var buf = try allocator.alloc(u8, stat.size);
    errdefer allocator.free(buf);

    var nread = try file.read(buf);
    debug.assert(nread == buf.len);

    return buf;
}
