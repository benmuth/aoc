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
    print("part 1: {d}\n", .{part_1_res}); // expect: 509,115

    const part_2_res = try part2(allocator, input_file);
    print("part 2: {d}\n", .{part_2_res}); // expect: 75,220,503

}

fn part1(allocator: std.mem.Allocator, input: []const u8) !u64 {
    print("input:\n {s}\n", .{input});

    var lines = std.mem.splitScalar(u8, input, '\n');
    var prev: []const u8 = "";
    var acc: u64 = 0;
    while (lines.next()) |curr| {
        // print("current line: {s}\n", .{curr});
        var next = lines.peek() orelse "";
        acc += try sumPartNumbers(allocator, prev, curr, next);
        prev = curr;
    }
    return acc;
}

// const sample_input =
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
// const sample_input =
//     \\....
//     \\.*..
//     \\..27
// ;

const sample_input =
    \\467..114..
    \\...*......
    \\..35..633.
    \\......#.32
    \\617*.....*
    \\.....+..2.
    \\..592.....
    \\......755.
    \\...$.*....
    \\.664.598..
;

// const part_1_expected_test_result: u64 = 4361;
const part_1_expected_test_result: u64 = 27;

// test "part 1" {
//     const allocator = std.testing.allocator;
//     try std.testing.expectEqual(part_1_expected_test_result, try part1(allocator, sample_input));
// }

fn getNumberSpansForLine(allocator: std.mem.Allocator, line: []const u8) !std.ArrayList(Span) {
    // this doesn't need to be a separate pass. once a span is found, just parse it and add it immediately
    var spans = std.ArrayList(Span).init(allocator);
    var start: ?u64 = null;
    var end: ?u64 = null;
    for (line, 0..line.len) |c, i| {
        if (std.ascii.isDigit(c)) {
            if (start == null) {
                std.debug.assert(end == null);
                start = i;
                if (!std.ascii.isDigit(line[i + 1])) {
                    end = i;
                }
            } else {
                end = i;
                std.debug.assert(end.? > start.?);
                if (i == line.len - 1) {
                    const span = Span{ .start = start.?, .end = end.? };
                    try spans.append(span);
                }
            }
            // print("start: {any}, end: {any}\n", .{ start, end });
        } else if (start != null and end != null) {
            std.debug.assert(end.? >= start.?);
            const span = Span{ .start = start.?, .end = end.? };
            try spans.append(span);
            start = null;
            end = null;
        }
    }
    return spans;
}

fn sumPartNumbers(allocator: std.mem.Allocator, prev: []const u8, curr: []const u8, next: []const u8) !u64 {
    var spans = try getNumberSpansForLine(allocator, curr);
    defer spans.deinit();

    var sum: u64 = 0;
    for (spans.items) |span| {
        // print("span start: {d}, span end: {d}\n", .{ span.start, span.end });
        var check_start = span.start -| 1;
        var check_end = @min(span.end + 2, curr.len - 1);
        // print("attempting to parse: {s}\n", .{curr[span.start .. span.end + 1]});
        const number = try std.fmt.parseInt(u64, curr[span.start .. span.end + 1], 10);
        // print("number: {d}\n", .{number});
        // print("check start: {d}, check end: {d}\n", .{ check_start, check_end });

        var symbol_above: bool = false;
        var symbol_below: bool = false;
        var symbol_adjacent: bool = false;
        for (check_start..check_end) |i| {
            // print("checking idx: {d}\n", .{i});
            symbol_adjacent = !std.ascii.isDigit(curr[i]) and curr[i] != '.';
            if (prev.len > 0) {
                symbol_above = !std.ascii.isDigit(prev[i]) and prev[i] != '.';
            } else {
                // print("on first line!\n", .{});
            }
            if (next.len > 0) {
                symbol_below = !std.ascii.isDigit(next[i]) and next[i] != '.';
            } else {
                // print("on last line!\n", .{});
            }
            // print("{c}: symbol above: {any}, symbol below: {any}\n", .{ curr[i], symbol_above, symbol_below });
            if (symbol_above or symbol_below or symbol_adjacent) {
                break;
            }
        }
        if (symbol_above or symbol_below or symbol_adjacent) {
            // print("part number found: {d}\n", .{number});
            sum += number;
            continue;
        } else {
            // print("part number not found: {d}\n", .{number});
        }
    }
    return sum;
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !u64 {
    // print("input:\n {s}\n", .{input});

    var lines = std.mem.splitScalar(u8, input, '\n');
    var prev: []const u8 = "";
    var acc: u64 = 0;
    while (lines.next()) |curr| {
        print("current line: {s}\n", .{curr});
        var next = lines.peek() orelse "";
        acc += try sumGearRatios(allocator, prev, curr, next);
        prev = curr;
    }
    return acc;
}

fn sumGearRatios(allocator: std.mem.Allocator, prev: []const u8, curr: []const u8, next: []const u8) !u64 {
    var prev_spans = try getNumberSpansForLine(allocator, prev);
    var curr_spans = try getNumberSpansForLine(allocator, curr);
    var next_spans = try getNumberSpansForLine(allocator, next);
    defer prev_spans.deinit();
    defer curr_spans.deinit();
    defer next_spans.deinit();
    var sum: u64 = 0;
    // ......755.
    // ...$.*....
    // .664.598..
    for (curr, 0..curr.len) |c, i| {
        if (c == '*') {
            // print("found * at {d}\n", .{i});
            var adjacent_number_count: u64 = 0;
            var adjacent_numbers: [2]u64 = undefined;

            var check_start = i -| 1;
            var check_end = @min(i + 2, curr.len);
            if (prev.len > 0) {
                // print("prev check span: {s}\n", .{prev[check_start..check_end]});
                for (prev_spans.items) |span| {
                    // print("checking previous span {d}..{d}\n", .{ span.start, span.end });
                    for (check_start..check_end) |j| {
                        // print("looking at {d}\n", .{j});
                        if (span.start <= j and j <= span.end) {
                            // print("converting span: {s}\n", .{})
                            print("adjacent number found on prev line: {s}\n", .{prev[span.start .. span.end + 1]});
                            const number = try std.fmt.parseInt(u64, prev[span.start .. span.end + 1], 10);
                            if (adjacent_number_count <= 1) {
                                adjacent_numbers[adjacent_number_count] = number;
                            }
                            adjacent_number_count += 1;
                            // print("")
                            break;
                        }
                    }
                }
            }

            for (curr_spans.items) |span| {
                // print("checking current span {d}..{d}\n", .{ span.start, span.end });
                for (check_start..check_end) |j| {
                    // print("looking at {d}\n", .{j});
                    if (span.start <= j and j <= span.end) {
                        // print("converting span: {s}\n", .{})
                        print("adjacent number found on curr line: {s}\n", .{curr[span.start .. span.end + 1]});
                        const number = try std.fmt.parseInt(u64, curr[span.start .. span.end + 1], 10);
                        if (adjacent_number_count <= 1) {
                            adjacent_numbers[adjacent_number_count] = number;
                        }
                        adjacent_number_count += 1;
                        // print("")
                        break;
                    }
                }
            }

            if (next.len > 0) {
                // print("next check span: {s}\n", .{next[check_start..check_end]});
                for (next_spans.items) |span| {
                    for (check_start..check_end) |j| {
                        if (span.start <= j and j <= span.end) {
                            // print("converting span: {s}\n", .{})
                            print("adjacent number found on next line: {s}\n", .{next[span.start .. span.end + 1]});
                            const number = try std.fmt.parseInt(u64, next[span.start .. span.end + 1], 10);
                            if (adjacent_number_count <= 1) {
                                adjacent_numbers[adjacent_number_count] = number;
                            }
                            adjacent_number_count += 1;
                            break;
                        }
                    }
                }
            }

            if (adjacent_number_count == 2) {
                print("found gear numbers: {d}, {d}\n", .{ adjacent_numbers[0], adjacent_numbers[1] });
                const gear_ratio = adjacent_numbers[0] * adjacent_numbers[1];
                print("gear ratio = {d}\n", .{gear_ratio});
                sum += gear_ratio;
            }
        }
    }
    return sum;
}

// const part_2_expected_test_result: u64 = 467835;
// const part_2_expected_test_result: u64 = 467835;
const part_2_expected_test_result: u64 = 467899;

test "part 2" {
    const allocator = std.testing.allocator;
    try std.testing.expectEqual(part_2_expected_test_result, try part2(allocator, sample_input));
}

const Span = struct {
    start: u64,
    end: u64,
};
