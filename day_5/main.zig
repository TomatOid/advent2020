const std = @import("std");
const fs = std.fs;

pub fn seatToRowCol(seat_str: []const u8) [2]u32 {
    var seat_num: u32 = 0;
    for (seat_str) |char| {
        seat_num <<= 1;
        seat_num |= @boolToInt(char == 'B' or char == 'R');
    }
    return [2]u32{ seat_num >> 3, seat_num & 0x7 };
}

pub fn seatToInt(seat_str: []const u8) u32 {
    var seat_num: u32 = 0;
    for (seat_str) |char| {
        seat_num <<= 1;
        seat_num |= @boolToInt(char == 'B' or char == 'R');
    }
    return seat_num;
}

test "rows / columns" {
    var pos = seatToRowCol("BFFFBBFRRR");
    std.testing.expect(pos[0] == 70 and pos[1] == 7);
    pos = seatToRowCol("FFFBBBFRRR");
    std.testing.expect(pos[0] == 14 and pos[1] == 7);
}

pub fn main() !void {
    var cwd = fs.cwd();
    var file = (try cwd.openFile("passes.txt", .{ .read = true, .write = false })).reader();
    var max_id: u32 = 0;
    var file_buffer: [256]u8 = undefined;
    while (try file.readUntilDelimiterOrEof(file_buffer[0..], '\n')) |line| {
        var seat_id = seatToInt(line);
        if (seat_id > max_id) {
            max_id = seat_id;
        }
    }
    try std.io.getStdOut().writer().print("{}\n", .{max_id});
}
