const std = @import("std");

const fs = std.fs;
const stdout = std.io.getStdOut().writer();

const Map = struct {
    width: usize,
    height: usize,
    data: []u8,

    pub fn getCharAt(self: Map, x: i64, y: i64) ?u8 {
        if (y >= self.height or y < 0 or x >= self.width or x < 0) {
            return null;
        }
        return self.data[@intCast(usize, x) + @intCast(usize, y) * self.width];
    }

    fn castRay(self: Map, start_x: i64, start_y: i64, dir_x: i64, dir_y: i64) u8 {
        var x = start_x + dir_x;
        var y = start_y + dir_y;
        var result: u8 = '.';
        while (self.getCharAt(x, y)) |char| : ({
            x += dir_x;
            y += dir_y;
        }) {
            if (char != '.') {
                result = char;
                break;
            }
        }
        return result;
    }

    pub fn getAdjacent(self: Map, x: i64, y: i64) [8]u8 {
        var result: [8]u8 = undefined;
        result[0] = self.castRay(x, y, -1, -1);
        result[1] = self.castRay(x, y, 0, -1);
        result[2] = self.castRay(x, y, 1, -1);
        result[3] = self.castRay(x, y, 1, 0);
        result[4] = self.castRay(x, y, 1, 1);
        result[5] = self.castRay(x, y, 0, 1);
        result[6] = self.castRay(x, y, -1, 1);
        result[7] = self.castRay(x, y, -1, 0);
        return result;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = false }){};
    const allocator = &gpa.allocator;
    var cwd = fs.cwd();
    var file = try cwd.openFile("map.txt", .{ .read = true, .write = false });
    var seats: Map = .{
        .width = 0,
        .height = 0,
        .data = try allocator.alloc(u8, (try file.getEndPos()) + 1),
    };
    var seats_backup: Map = .{
        .width = 0,
        .height = 0,
        .data = try allocator.alloc(u8, (try file.getEndPos()) + 1),
    };
    var file_slice: []u8 = seats.data[0..];
    var file_index: usize = 0;
    while (try file.reader().readUntilDelimiterOrEof(file_slice, '\n')) |line| {
        file_index += line.len;
        file_slice = seats.data[file_index..];
        seats.width = line.len;
        seats.height += 1;
    }
    seats_backup.width = seats.width;
    seats_backup.height = seats.height;
    var occupancy: u64 = 0;
    while (true) {
        std.mem.copy(u8, seats_backup.data, seats.data);
        var x: usize = 0;
        occupancy = 0;
        while (x < seats_backup.width) : (x += 1) {
            var y: usize = 0;
            while (y < seats_backup.height) : (y += 1) {
                var ajacent_seats = seats_backup.getAdjacent(@intCast(i64, x), @intCast(i64, y));
                var occupied_count: u4 = 0;
                for (ajacent_seats) |seat| {
                    occupied_count += @boolToInt(seat == '#');
                }
                var this_seat = seats_backup.data[x + y * seats.width];
                //try stdout.print("{}", .{&this_seat});
                if (this_seat == 'L' and occupied_count == 0) seats.data[x + y * seats.width] = '#';
                if (this_seat == '#') {
                    occupancy += 1;
                    if (occupied_count >= 5)
                        seats.data[x + y * seats.width] = 'L';
                }
            }
        }
        if (std.mem.eql(u8, seats_backup.data, seats.data)) break;
    }
    try stdout.print("{}\n", .{occupancy});
}
