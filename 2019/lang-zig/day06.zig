const std = @import("std");
const mem = std.mem;
const input = @embedFile("../input/day06");
const allocator = &std.heap.ArenaAllocator.init(std.heap.page_allocator).allocator;

const Orbiter = struct {
    name: []const u8,
    solar: ?*Orbiter,
    moons: std.ArrayList(*Orbiter),
    cost: u32,

    fn new(name: []const u8) *Orbiter {
        var orbiter = allocator.create(Orbiter) catch unreachable;
        orbiter.name = name;
        orbiter.solar = null;
        orbiter.moons = std.ArrayList(*Orbiter).init(allocator);
        orbiter.cost = 0;
        return orbiter;
    }
};

var orbiters = std.StringHashMap(*Orbiter).init(allocator);
var com: ?*Orbiter = null;

const OrbiterSet = std.AutoHashMap(*Orbiter, void);

pub fn main() !void {
    var input_orbits = mem.separate(input, "\n");
    while (input_orbits.next()) |orbit_input| {
        if (orbit_input.len == 0) continue;

        var object_names = mem.separate(orbit_input, ")");
        var solar_name = object_names.next().?;
        var moon_name = object_names.next().?;

        var solar: *Orbiter = if (orbiters.get(solar_name)) |kv| kv.value else blk: {
            var orbiter = Orbiter.new(solar_name);
            _ = try orbiters.put(solar_name, orbiter);
            break :blk orbiter;
        };
        var moon: *Orbiter = if (orbiters.get(moon_name)) |kv| kv.value else blk: {
            var orbiter = Orbiter.new(moon_name);
            _ = try orbiters.put(moon_name, orbiter);
            break :blk orbiter;
        };

        if (moon.solar == null) {
            std.debug.assert(solar != moon);
            moon.solar = solar;
            try solar.moons.append(moon);
        } else {
            @panic("moon already assigned solar");
        }

        if (mem.eql(u8, solar.name, "COM")) {
            if (com == null) {
                com = solar;
            } else {
                @panic("more than one COM");
            }
        }
    }

    // --- Part 1 ---
    const answer1 = total_orbits();
    std.debug.warn("day06 part1 {}\n", answer1);

    // --- Part 2 ---
    set_orbit_cost(com.?, 0);
    var you = if (orbiters.get("YOU")) |kv| kv.value else unreachable;
    var san = if (orbiters.get("SAN")) |kv| kv.value else unreachable;
    var you_solars: OrbiterSet = try collect_solars(you);
    var common_solar = find_common_solar(san, you_solars).?;
    const cost_you_from_common = you.cost - common_solar.cost;
    const cost_san_from_common = san.cost - common_solar.cost;
    const answer2 = cost_you_from_common + cost_san_from_common - 2;
    std.debug.warn("day06 part2 {}\n", answer2);
}

fn find_common_solar(orbiter: *Orbiter, set: OrbiterSet) ?*Orbiter {
    var solar: ?*Orbiter = orbiter.solar;
    while (solar) |s| {
        if (set.get(s) != null) {
            return s;
        }
        solar = s.solar;
    }
    return null;
}

fn collect_solars(orbiter: *Orbiter) !OrbiterSet {
    var result = OrbiterSet.init(allocator);
    var solar: ?*Orbiter = orbiter.solar;
    while (solar) |s| {
        _ = try result.put(s, {});
        solar = s.solar;
    }
    return result;
}

fn set_orbit_cost(orbiter: *Orbiter, cost: u32) void {
    var it = orbiter.moons.iterator();
    while (it.next()) |moon| {
        set_orbit_cost(moon, 1 + cost);
    }
    orbiter.cost = cost;
}

fn count_orbits(root: *Orbiter) u32 {
    var sum: u32 = 0;
    var orbiter: ?*Orbiter = root.solar;
    while (orbiter != null) {
        sum += 1;
        orbiter = if (orbiter) |o| o.solar else null;
    }
    return sum;
}

fn total_orbits() u32 {
    var sum: u32 = 0;
    var it = orbiters.iterator();
    while (it.next()) |kv| {
        var orbiter = kv.value;
        sum += count_orbits(orbiter);
    }
    return sum;
}
