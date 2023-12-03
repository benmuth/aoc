const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

const part_1_sample =
    \\ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\ Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

const part_2_sample =
    \\ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    \\ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    \\ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    \\ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    \\ Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
;

const input_file = "data/input.txt";

pub fn readInput(allocator: std.mem.Allocator, file_name: []const u8) ![]const u8 {
    const data_file = try std.fs.cwd().openFile(file_name, .{});
    defer data_file.close();

    const data_file_stats = try data_file.stat();
    var buffer = try allocator.alloc(u8, data_file_stats.size);
    const bytes_read = try data_file.readAll(buffer);
    assert(bytes_read == data_file_stats.size);

    return buffer;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer assert(gpa.deinit() != std.heap.Check.leak);
    // defer gpa.deinit();

    const data: []const u8 = try readInput(allocator, input_file);
    defer allocator.free(data);

    const part_1_res = try part1(allocator, data);
    print("part 1: {d}\n", .{part_1_res}); // expect: 2348

    const part_2_res = try part2(allocator, data);
    print("part 2: {d}\n", .{part_2_res}); // expect: 76008

    // // data
    // const part_2_res = try part2(data);
    // print("part 2: {d}\n", .{part_2_res});

}

fn part1(allocator: std.mem.Allocator, data: []const u8) !u64 {
    var max_draws = [3]Draw{
        Draw{ .color = cube.red, .count = 12 },
        Draw{ .color = cube.green, .count = 13 },
        Draw{ .color = cube.blue, .count = 14 },
    };

    const games = try parseInput(allocator, data);
    defer {
        for (games.items) |game| {
            game.deinit();
        }
        games.deinit();
    }

    var acc: u64 = 0;
    for (games.items) |game| {
        if (validGameMax(game, max_draws)) {
            acc += game.id;
        }
        // print("id: {d}\n", .{game.id});
    }
    return acc;
}

test "part 1" {
    const allocator = std.testing.allocator;
    const part_1_sample_answer = 8;
    const data = part_1_sample;
    const res = try part1(allocator, data);
    print("res: {d}\n", .{res});
    try std.testing.expectEqual(@as(u64, part_1_sample_answer), res);
}

fn validGameMax(game: Game, max_draws: [3]Draw) bool {
    for (game.sets.items) |set| {
        for (set.draws.items) |draw| {
            switch (draw.color) {
                cube.red => {
                    if (draw.count > max_draws[0].count) {
                        return false;
                    }
                },
                cube.green => {
                    if (draw.count > max_draws[1].count) {
                        return false;
                    }
                },
                cube.blue => {
                    if (draw.count > max_draws[2].count) {
                        return false;
                    }
                },
            }
        }
    }
    return true;
}

fn part2(allocator: std.mem.Allocator, data: []const u8) !u64 {
    const games = try parseInput(allocator, data);
    defer {
        for (games.items) |game| {
            game.deinit();
        }
        games.deinit();
    }

    var acc: u64 = 0;
    for (games.items) |game| {
        var max_red: u64 = 0;
        var max_green: u64 = 0;
        var max_blue: u64 = 0;
        for (game.sets.items) |set| {
            for (set.draws.items) |draw| {
                print("count: {d}\n", .{draw.count});
                switch (draw.color) {
                    cube.red => {
                        max_red = @max(max_red, draw.count);
                    },
                    cube.green => {
                        max_green = @max(max_green, draw.count);
                    },
                    cube.blue => {
                        max_blue = @max(max_blue, draw.count);
                    },
                }
            }
        }
        const power = max_red * max_green * max_blue;
        acc += power;
    }
    return acc;
}

test "part2" {
    const allocator = std.testing.allocator;
    const part_2_sample_answer = 2286;
    const data = part_2_sample;
    const res = try part2(allocator, data);
    print("res: {d}\n", .{res});
    try std.testing.expectEqual(@as(u64, part_2_sample_answer), res);
}

// fn validGameMin(game: Game, min_draws: [3]Draw) bool {
//     for (game.sets.items) |set| {
//         for (set.draws.items) |draw| {
//             switch (draw.color) {
//                 cube.red => {
//                     if (draw.count > min_draws[0].count) {
//                         return false;
//                     }
//                 },
//                 cube.green => {
//                     if (draw.count > min_draws[1].count) {
//                         return false;
//                     }
//                 },
//                 cube.blue => {
//                     if (draw.count > min_draws[2].count) {
//                         return false;
//                     }
//                 },
//             }
//         }
//     }
//     return true;
// }

fn parseInput(allocator: std.mem.Allocator, raw_data: []const u8) !std.ArrayList(Game) {
    const data = std.mem.trim(u8, raw_data, &std.ascii.whitespace);
    var games = std.ArrayList(Game).init(allocator);
    var lines = std.mem.splitScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const game = try Game.init(allocator, line);
        try games.append(game);
    }
    return games;
}

test "parse_input" {
    const allocator = std.testing.allocator;
    const data = part_1_sample;

    const games = try parseInput(allocator, data);
    defer {
        for (games.items) |game| {
            game.deinit();
        }
        games.deinit();
    }
    // print("games: {any}\n", .{games});
    // for (games.items) |game| {
    //     print("id: {d}\n", .{game.id});
    // }
}

const Game = struct {
    allocator: std.mem.Allocator,
    id: u64,
    sets: std.ArrayList(Set),

    fn init(allocator: std.mem.Allocator, raw_input: []const u8) !Game {
        const input = std.mem.trim(u8, raw_input, &std.ascii.whitespace);
        var parts = std.mem.splitScalar(u8, input, ':');
        var tmp = std.mem.splitScalar(u8, parts.first(), ' ');
        _ = tmp.first();
        const id_string = tmp.next().?;
        // print("id string: {s}\n", .{id_string});
        const id = try std.fmt.parseInt(u64, id_string, 10);

        var set_list = std.ArrayList(Set).init(allocator);
        var set_strings = std.mem.splitScalar(u8, parts.next().?, ';');
        while (set_strings.next()) |string| {
            const set = try Set.init(allocator, string);
            try set_list.append(set);
        }
        return Game{ .allocator = allocator, .id = id, .sets = set_list };
    }

    fn deinit(self: Game) void {
        for (self.sets.items) |set| {
            set.deinit();
        }
        self.sets.deinit();
    }
};

const ParseError = error{
    InvalidInput,
};

const Set = struct {
    allocator: std.mem.Allocator,
    draws: std.ArrayList(Draw),

    // input should be in form '1 blue, 2 green'
    fn init(allocator: std.mem.Allocator, input: []const u8) !Set {
        // print("input: {s}\n", .{input});
        var draw_list = std.ArrayList(Draw).init(allocator);
        var draw_strings = std.mem.splitScalar(u8, input, ',');

        while (draw_strings.next()) |draw_string| {
            // print("draw: {s}\n", .{draw_string});
            // draw_string is in the form '1 blue'
            const trimmed_string = std.mem.trim(u8, draw_string, " ");
            // print("trimmed: {s}\n", .{trimmed_string});
            var tokens = std.mem.splitScalar(u8, trimmed_string, ' ');
            const count = try std.fmt.parseInt(u64, tokens.first(), 10);
            const color_string = tokens.next().?;

            var cube_color = cube.red;
            switch (color_string[0]) {
                'r' => {
                    cube_color = cube.red;
                },
                'g' => {
                    cube_color = cube.green;
                },
                'b' => {
                    cube_color = cube.blue;
                },
                else => {},
            }
            var draw = Draw{ .count = count, .color = cube_color };
            try draw_list.append(draw);
        }
        return Set{ .allocator = allocator, .draws = draw_list };
    }

    fn deinit(self: Set) void {
        self.draws.deinit();
        // self.allocator.free(self.draws);
    }
};

test "set" {
    var allocator = std.testing.allocator;
    const input = " 3 green, 4 blue, 1 red";
    const set = try Set.init(allocator, input);
    defer set.deinit();

    const first_draw = set.draws.items[0];
    try std.testing.expectEqual(first_draw.count, 3);
    // for (set.draws.items) |draw| {
    // print("{d} {any}\n", .{ draw.count, draw.color });

    // }
}

const Draw = struct {
    count: u64,
    color: cube,
};

const cube = enum { red, green, blue };
