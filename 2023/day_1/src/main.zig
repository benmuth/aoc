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
    print("part 1: {d}\n", .{part_1_res}); // correct answer: 54597

    // data
    const part_2_res = try part2(data);
    print("part 2: {d}\n", .{part_2_res}); // correct answer: 54504
}

pub fn readInput(allocator: std.mem.Allocator, file_name: []const u8) ![]const u8 {
    const data_file = try std.fs.cwd().openFile(file_name, .{});
    defer data_file.close();

    const data_file_stats = try data_file.stat();
    var buffer = try allocator.alloc(u8, data_file_stats.size);
    const bytes_read = try data_file.readAll(buffer);
    assert(bytes_read == data_file_stats.size);

    return buffer;
}

fn part1(data: []const u8) !u64 {
    // use optionals here (?) instead of out of bounds number
    var first_digit: u32 = 1000;
    var last_digit: u32 = 1000;
    var acc: u32 = 0;
    for (0..data.len, data) |i, c| {
        if (std.ascii.isDigit(c)) {
            if (first_digit > 9) {
                first_digit = strToDigit(c);
            } else {
                last_digit = strToDigit(c);
            }
        }
        // can use std.mem.splitScalar here to split by newline
        if (c == '\n' or i == (data.len - 1)) {
            if (last_digit > 9) {
                last_digit = first_digit;
            }

            const calibration_value = intConcat(first_digit, last_digit);
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

fn part2(data: []const u8) !u64 {
    var acc: u64 = 0;
    var iter = std.mem.splitScalar(u8, data, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        var first_digit: ?u32 = null;
        var last_digit: ?u32 = null;
        for (0..line.len) |i| {
            var digit = try parseDigitWords(line[i..]) orelse continue;
            if (first_digit == null) {
                first_digit = digit;
            }
            last_digit = digit;
        }
        const calibration_value = intConcat(first_digit, last_digit);
        acc += calibration_value;
    }
    return acc;
}

test "part 2" {
    const data = part_2_sample;

    const res = try part2(data);
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

/// returns the parsed number if any, or else null
fn parseDigitWords(string: []const u8) !?u32 {
    return std.fmt.charToDigit(string[0], 10) catch {
        for (digit_words, 1..10) |word, i| {
            if (string.len < word.len) {
                continue;
            }
            if (std.mem.eql(u8, string[0..word.len], word)) {
                return @truncate(i);
            }
        }
        return null;
    };
}

test "parse digit word" {
    const test_string = "oneight";

    for (0..test_string.len) |i| {
        _ = try parseDigitWords(test_string[i..test_string.len]) orelse continue;
    }
}
