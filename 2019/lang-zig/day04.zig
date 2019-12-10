const std = @import("std");

// puzzle input: 231832-767346
const min_password: [6]u8 = [_]u8{ 2,3,1,8,3,2 };
const max_password: [6]u8 = [_]u8{ 7,6,7,3,4,6 };

var password = min_password;

const AdjacentRule = enum {
    AtLeastTwo,
    ExactlyTwo,
};

fn next_password(rule: AdjacentRule) !void {
    inc_digit(password.len - 1);
    while (! try check_password(rule)) {
        inc_digit(password.len - 1);
    }
}

fn inc_digit(i: usize) void {
    password[i] += 1;
    if (password[i] == 10) {
        if (i > 0) {
            inc_digit(i - 1);
            password[i] = password[i - 1];
        }
        else {
            password[i] = 9;
        }
    }
}

inline fn as_usize(x: [6]u8) usize {
    const x0 = @as(usize, x[0]);
    const x1 = @as(usize, x[1]);
    const x2 = @as(usize, x[2]);
    const x3 = @as(usize, x[3]);
    const x4 = @as(usize, x[4]);
    const x5 = @as(usize, x[5]);

    return x5 + x4*10 + x3*100 + x2*1000 + x1*10000 + x0*100000;
}

fn check_password(adjacent_rule: AdjacentRule) !bool {
    var i: usize = undefined;

    // Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
    i = 0;
    while (i < password.len - 1): (i += 1) {
        if (password[i] > password[i + 1]) {
            return false;
        }
    }

    // Two adjacent digits are the same (like 22 in 122345).
    var adjacent: bool = blk: {
        i = 0;
        if (adjacent_rule == .AtLeastTwo) {
            while (i < password.len - 1): (i += 1) {
                if (password[i] == password[i + 1]) {
                    break :blk true;
                }
            }
        }
        else {
            std.debug.assert(adjacent_rule == .ExactlyTwo);
            while (i < password.len - 1) : (i += 1) {
                var sum: u32 = 1;
                while (i < password.len - 1 and password[i] == password[i + 1]) : (i += 1) {
                    sum += 1;
                }
                if (sum == 2) {
                    break :blk true;
                }
            }
        }
        break :blk false;
    };

    if (!adjacent) {
        return false;
    }

    // The value is within the range given in your puzzle input.
    if (as_usize(password) > as_usize(max_password)) {
        return error.PasswordOutOfRange;
    }

    return true;
}

fn print_password() void {
    for (password) |c| {
        std.debug.warn("{}", c);
    }
    std.debug.warn("\n");
}

pub fn main() !void {
    var answer1: usize = 0;
    var answer2: usize = 0;

    // -- Part1 --
    password = min_password;
    while (true) {
        next_password(AdjacentRule.AtLeastTwo) catch |err| switch (err) {
            error.PasswordOutOfRange => break,
            else => return err,
        };
        //print_password();
        answer1 += 1;
    }

    // -- Part2 --
    password = min_password;
    while (true) {
        next_password(AdjacentRule.ExactlyTwo) catch |err| switch (err) {
            error.PasswordOutOfRange => break,
            else => return err,
        };
        //print_password();
        answer2 += 1;
    }

    std.debug.warn("day04 {} {}\n", answer1, answer2);
}
