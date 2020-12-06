const std = @import("std");

pub fn seatToRowCol(seat_str: []const u8) [2]u32 {
    var seat_num: u32 = 0;
    for (seat_str) |char| {
        seat_num <<= 1;
        seat_num |= @boolToInt(char == 'B' or char == 'R');
    }
    return [2]u32{ seat_num >> 3, seat_num & 0x7 };
}

test "rows / columns" {
    var pos = seatToRowCol("BFFFBBFRRR");
    std.testing.expect(pos[0] == 70 and pos[1] == 7);
    pos = seatToRowCol("FFFBBBFRRR");
    std.testing.expect(pos[0] == 14 and pos[1] == 7);
}

//pub fn main() !void {
