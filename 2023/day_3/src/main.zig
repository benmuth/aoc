const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const input_file = @embedFile("data/input.txt");

pub fn main() !void {
    // print("{s}\n", .{input_file});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer assert(gpa.deinit() != std.heap.Check.leak);

    // const partial_input = input_file[0..282];
    const part_1_res = try part1(allocator, input_file);
    // const part_1_res = try part1(allocator, partial_input);
    print("part 1: {d}\n", .{part_1_res}); // expect: 2348

    // const part_2_res = try part2(allocator, data);
    // print("part 2: {d}\n", .{part_2_res}); // expect: 76008

}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    print("input:\n {s}\n", .{input});

    var lines = std.mem.splitScalar(u8, input, '\n');
    var prev: []const u8 = "";
    var acc: u64 = 0;
    while (lines.next()) |curr| {
        print("current line: {s}\n", .{curr});
        var next = lines.peek() orelse "";
        acc += try sumPartNumbers(allocator, prev, curr, next);
        prev = curr;
    }
    return acc;
}

// const part_1_sample_input =
//     \\467..114..
//     \\...*......
//     \\..35..633.
//     \\......#...
//     \\617*......
//     \\.....+.58.
//     \\..592.....
//     \\......755.
//     \\...$.*....
//     \\.664.598..
// ;
// const part_1_sample_input =
//     \\467..114..
//     \\...*......
//     \\..35..633.
//     \\......#...
//     \\617*......
//     \\.....+.58.
//     \\..592.....
//     \\......755.
//     \\...$.*....
//     \\.664.598..
// ;
const part_1_sample_input =
    \\....
    \\.*..
    \\..27
;
// const expected_test_result: u64 = 4361;
const expected_test_result: u64 = 27;

test "parseInput" {
    print("TESTIN!\n", .{});
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(expected_test_result, try part1(allocator, part_1_sample_input));
}

fn sumPartNumbers(allocator: std.mem.Allocator, prev: []const u8, curr: []const u8, next: []const u8) !u64 {
    var spans = std.ArrayList(Span).init(allocator);
    defer spans.deinit();
    var start: ?u64 = null;
    var end: ?u64 = null;

    // can do this in one pass. once a span is found, just parse it and add it immediately
    for (curr, 0..curr.len) |c, i| {
        if (std.ascii.isDigit(c)) {
            if (start == null) {
                std.debug.assert(end == null);
                start = i;
                if (!std.ascii.isDigit(curr[i + 1])) {
                    end = i;
                }
            } else {
                end = i;
                std.debug.assert(end.? > start.?);
                if (i == curr.len - 1) {
                    const span = Span{ .start = start.?, .end = end.? };
                    try spans.append(span);
                }
            }
            print("start: {any}, end: {any}\n", .{ start, end });
        } else if (start != null and end != null) {
            std.debug.assert(end.? >= start.?);
            const span = Span{ .start = start.?, .end = end.? };
            try spans.append(span);
            start = null;
            end = null;
        }
    }

    var sum: u64 = 0;
    for (spans.items) |span| {
        print("span start: {d}, span end: {d}\n", .{ span.start, span.end });
        var check_start = span.start -| 1;
        var check_end = @min(span.end + 2, curr.len - 1);
        print("attempting to parse: {s}\n", .{curr[span.start .. span.end + 1]});
        const number = try std.fmt.parseInt(u64, curr[span.start .. span.end + 1], 10);
        print("number: {d}\n", .{number});
        print("check start: {d}, check end: {d}\n", .{ check_start, check_end });

        var symbol_above: bool = false;
        var symbol_below: bool = false;
        var symbol_adjacent: bool = false;
        for (check_start..check_end) |i| {
            print("checking idx: {d}\n", .{i});
            symbol_adjacent = !std.ascii.isDigit(curr[i]) and curr[i] != '.';
            if (prev.len > 0) {
                symbol_above = !std.ascii.isDigit(prev[i]) and prev[i] != '.';
            } else {
                print("on first line!\n", .{});
            }
            if (next.len > 0) {
                symbol_below = !std.ascii.isDigit(next[i]) and next[i] != '.';
            } else {
                print("on last line!\n", .{});
            }
            print("{c}: symbol above: {any}, symbol below: {any}\n", .{ curr[i], symbol_above, symbol_below });
            if (symbol_above or symbol_below or symbol_adjacent) {
                break;
            }
        }
        if (symbol_above or symbol_below or symbol_adjacent) {
            print("part number found: {d}\n", .{number});
            sum += number;
            continue;
        } else {
            print("part number not found: {d}\n", .{number});
        }
    }
    return sum;
}

const Span = struct {
    start: u64,
    end: u64,
};
