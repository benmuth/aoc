const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const part_1_sample =
    \\ 1abc2
    \\ pqr3stu8vwx
    \\ a1b2c3d4e5f
    \\ treb7uchet
;

const part_2_sample =
    \\ two1nine
    \\ eightwothree
    \\ abcone2threexyz
    \\ xtwone3four
    \\ 4nineeightseven2
    \\ zoneight234
    \\ 7pqrstsixteen
;

const part_1_input = "data/input.txt";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer assert(gpa.deinit() != std.heap.Check.leak);

    const data: []const u8 = try readInput(allocator, part_1_input);
    defer allocator.free(data);

    const part_1_res = try part1(data);
    print("part 1: {d}\n", .{part_1_res});

    // data
    const part_2_res = try part2();
    print("part 2: {d}\n", .{part_2_res});
}

pub fn readInput(allocator: std.mem.Allocator, file_name: []const u8) ![]const u8 {
    const data_file = try std.fs.cwd().openFile(file_name, .{});
    defer data_file.close();

    const data_file_stats = try data_file.stat();
    var buffer = try allocator.alloc(u8, data_file_stats.size);
    const bytes_read = try data_file.readAll(buffer);
    assert(bytes_read == data_file_stats.size);

    // print("{s}", .{buffer});
    // print("bytes read: {any}\n", .{bytes_read});
    return buffer;
}

fn part1(data: []const u8) !u64 {
    var first_digit: u32 = 1000;
    var last_digit: u32 = 1000;
    var acc: u32 = 0;
    for (0..data.len, data) |i, c| {
        if (std.ascii.isDigit(c)) {
            if (first_digit > 9) {
                // assert(last_digit == undefined);
                first_digit = strToDigit(c);
                // print("first digit: {d}\n", .{first_digit});
            } else {
                last_digit = strToDigit(c);
                // print("last digit: {d}\n", .{last_digit});
            }
        }
        if (c == '\n' or i == (data.len - 1)) {
            if (last_digit > 9) {
                last_digit = first_digit;
            }
            const calibration_value = intConcat(first_digit, last_digit);
            // print("concatted: {d}\n", .{calibration_value});

            acc += calibration_value;

            first_digit = 1000;
            last_digit = 1000;
        }
    }
    return acc;
}

fn intConcat(int1: u32, int2: u32) u32 {
    return (10 * int1) + int2;
}

pub fn strToDigit(c: u8) u32 {
    return c - '0';
}

test "part 1" {
    const data = part_1_sample;
    const res = try part1(data);
    try std.testing.expectEqual(@as(u64, 142), res);
}

// data: []const u8
fn part2() !u64 {
    // var first_digit: u32 = 1000;
    // var last_digit: u32 = 1000;
    for (digit_words) |dw| {
        print("{s}\n", .{dw});
    }
    var acc: u64 = 0;
    // for (0..data.len, data) |i, c| {
    //     if (std.ascii.isDigit(c)) {
    //         if (first_digit > 9) {
    //             // assert(last_digit == undefined);
    //             first_digit = strToDigit(c);
    //             // print("first digit: {d}\n", .{first_digit});
    //         } else {
    //             last_digit = strToDigit(c);
    //             // print("last digit: {d}\n", .{last_digit});
    //         }
    //     }
    //     if (c == '\n' or i == (data.len - 1)) {
    //         if (last_digit > 9) {
    //             last_digit = first_digit;
    //         }
    //         const calibration_value = intConcat(first_digit, last_digit);
    //         // print("concatted: {d}\n", .{calibration_value});

    //         acc += calibration_value;

    //         first_digit = 1000;
    //         last_digit = 1000;
    //     }
    // }
    return acc;
}

test "part 2" {
    // const data = part_2_sample;

    // data
    const res = try part2();
    try std.testing.expectEqual(@as(u64, 281), res);
}

const digit_words = [_][]const u8{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

/// returns number of characters parsed
fn parseDigitWords(string: []const u8) u8 {
    valid_nums = [9]usize{};
    inline for (1..10) |i| {
        valid_nums = i;
    }
    outer: for (string) |c| {
        for (digit_words) |word| {
            if (c != word[0]) {
                continue;
            }
        }
    }
}
