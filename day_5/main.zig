const std = @import("std");
const fs = std.fs;
const stdout = std.io.getStdOut().writer();

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
    var file_buffer: [12]u8 = undefined;
    var seat_ids: [837]u32 = undefined;
    var seat_counter: usize = 0;
    while (try file.readUntilDelimiterOrEof(file_buffer[0..], '\n')) |line| {
        var seat_id = seatToInt(line);
        if (seat_counter < seat_ids.len) {
            seat_ids[seat_counter] = seat_id;
            seat_counter += 1;
        } else return error.FileTooLong;
    }
    std.sort.sort(u32, seat_ids[0..seat_counter], {}, comptime std.sort.asc(u32));
    var i: usize = 0;
    while (i < seat_counter - 1) : (i += 1) {
        if (seat_ids[i + 1] - seat_ids[i] > 1) {
            try stdout.print("{} {}\n", .{ seat_ids[i], seat_ids[i + 1] });
        }
    }
}
