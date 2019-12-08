const std = @import("std");
usingnamespace std.math;

const input = @embedFile("../input/day08");

const IMAGE_WIDTH  = 25;
const IMAGE_HEIGHT = 6;
const IMAGE_SIZE   = IMAGE_WIDTH * IMAGE_HEIGHT;

const ImagePixelColor = enum {
    Black = 0,
    White = 1,
    Transparent = 2,
};

const ImageLayer = struct {
    checksum: usize,
    digits:   []const u8,
};

const DigitsCount = struct {
    n0: usize,
    n1: usize,
    n2: usize,
};
fn count_digits(layer: []const u8) DigitsCount {
    var n0: usize = 0;
    var n1: usize = 0;
    var n2: usize = 0;
    for (layer) |v| {
        switch (v) {
            '0' => n0 += 1,
            '1' => n1 += 1,
            '2' => n2 += 1,
            else => unreachable,
        }
    }
    return DigitsCount{
        .n0 = n0,
        .n1 = n1,
        .n2 = n2,
    };
}

pub fn main() !void {
    // --- Part 1 ---
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();

    const image_num_digits = input.len - 1;
    const image_num_layers = image_num_digits / IMAGE_SIZE;

    var image_layers = try arena_allocator.allocator.alloc(ImageLayer, image_num_layers);

    var min_n0: usize = maxInt(usize);
    var layer_min_n0: usize = undefined;

    var layer_off: usize = 0;
    const layer_len: usize = IMAGE_SIZE;
    for (image_layers) |layer, i| {
        const input_slice = input[layer_off..][0..layer_len];
        const count = count_digits(input_slice);
        if (count.n0 < min_n0) {
            min_n0 = count.n0;
            layer_min_n0 = i;
        }
        image_layers[i].checksum = count.n1 * count.n2;
        image_layers[i].digits = input_slice;
        layer_off += layer_len;
    }

    std.debug.warn("day08 part1 {}\n", image_layers[layer_min_n0].checksum);

    // --- Part 2 ---
    var x : usize = undefined;
    var y : usize = undefined;
    var image_pixels = try arena_allocator.allocator.alloc(ImagePixelColor, IMAGE_SIZE);
    for (image_pixels) |_, i| {
        image_pixels[i] = .Transparent;
    }
    for (image_layers) |_, layer_index| {
        y = 0;
        while (y < IMAGE_HEIGHT) : (y += 1) {
            x = 0;
            while (x < IMAGE_WIDTH) : (x += 1) {
                const i = x + y*IMAGE_WIDTH;
                if (image_pixels[i] == .Transparent) {
                    image_pixels[i] = switch (image_layers[layer_index].digits[i] - '0') {
                        0 => ImagePixelColor.Black,
                        1 => ImagePixelColor.White,
                        2 => ImagePixelColor.Transparent,
                        else => unreachable,
                    };
                }
            }
        }
    }

    const ANSI_BLACK = "\x1b[30m";
    const ANSI_WHITE = "\x1b[97m";
    const ANSI_MAGENTA = "\x1b[35m";
    const ANSI_RESET = "\x1b[0m";

    const print = std.debug.warn;

    std.debug.warn("day08 part2\n");
    y = 0;
    while (y < IMAGE_HEIGHT) : (y += 1) {
        x = 0;
        while (x < IMAGE_WIDTH) : (x += 1) {
            const i = x + y*IMAGE_WIDTH;
            switch (image_pixels[i]) {
                .Black => {
                    print("{}{}{}", ANSI_BLACK, "\u{2588}", ANSI_RESET);
                },
                .White => {
                    print("{}{}{}", ANSI_WHITE, "\u{2588}", ANSI_RESET);
                },
                .Transparent => {
                    print("{}{}{}", ANSI_MAGENTA, "\u{2588}", ANSI_RESET);
                },
                else => unreachable,
            }
        }
        print("\n");
    }
    print("\n");
}
