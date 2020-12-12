const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var joltages = [_]u32{ 153, 17, 45, 57, 16, 147, 39, 121, 75, 70, 85, 134, 128, 115, 51, 139, 44, 65, 119, 168, 122, 72, 105, 31, 103, 89, 154, 114, 55, 25, 48, 38, 132, 157, 84, 71, 113, 143, 83, 64, 109, 129, 120, 100, 151, 79, 125, 22, 161, 167, 19, 26, 118, 142, 4, 158, 11, 35, 56, 18, 40, 7, 150, 99, 54, 152, 60, 27, 164, 78, 47, 82, 63, 46, 91, 32, 135, 3, 108, 10, 159, 127, 69, 110, 126, 133, 28, 15, 104, 138, 160, 98, 90, 144, 1, 2, 92, 41, 86, 66, 95, 12 };
    std.sort.sort(u32, joltages[0..], {}, comptime std.sort.asc(u32));
    var joltage_differences: [4]usize = undefined;
    var i: usize = 0;
    while (i < joltages.len - 1) : (i += 1) {
        var delta = joltages[i + 1] - joltages[i];
        if (delta >= joltage_differences.len) return error.AdaptorsNotCompatible;
        joltage_differences[delta] += 1;
    }
    try stdout.print("{}\n", .{joltage_differences[1] * joltage_differences[3]});
}
