const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn countArrangements(first: u32, middle: []const u32) u64 {
    if (middle.len == 0) return 1;
    // to combine, or not combine, that is the question
    // let's do both and add the results
    var total: u64 = 0;
    if (first + middle[0] <= 3) {
        total += countArrangements(first + middle[0], middle[1..]);
    }
    return total + countArrangements(middle[0], middle[1..]);
}

//test "count arrangements" {
//    var joltages = [_]u32{ 16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4 };

pub fn main() !void {
    var joltages = [_]u32{ 153, 17, 45, 57, 16, 147, 39, 121, 75, 70, 85, 134, 128, 115, 51, 139, 44, 65, 119, 168, 122, 72, 105, 31, 103, 89, 154, 114, 55, 25, 48, 38, 132, 157, 84, 71, 113, 143, 83, 64, 109, 129, 120, 100, 151, 79, 125, 22, 161, 167, 19, 26, 118, 142, 4, 158, 11, 35, 56, 18, 40, 7, 150, 99, 54, 152, 60, 27, 164, 78, 47, 82, 63, 46, 91, 32, 135, 3, 108, 10, 159, 127, 69, 110, 126, 133, 28, 15, 104, 138, 160, 98, 90, 144, 1, 2, 92, 41, 86, 66, 95, 12 };
    //var joltages = [_]u32{ 16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4 };
    std.sort.sort(u32, joltages[0..], {}, comptime std.sort.asc(u32));
    var joltage_differences = [_]u32{ 0, 0, 0, 1 };
    var joltage_deltas: [joltages.len + 1]u32 = undefined;
    if (joltages[0] > 3) return error.AdaptorsNotCompatible;
    joltage_differences[joltages[0]] += 1;
    joltage_deltas[0] = joltages[0];
    for (joltages[1..]) |_, i| {
        var delta = joltages[i + 1] - joltages[i];
        if (delta >= joltage_differences.len) return error.AdaptorsNotCompatible;
        joltage_differences[delta] += 1;
        joltage_deltas[i + 1] = delta;
    }
    joltage_deltas[joltage_deltas.len - 1] = 3;
    try stdout.print("{}\n", .{joltage_differences[1] * joltage_differences[3]});
    // part 2
    var i: usize = 0;
    var running_product: u64 = 1;
    var last_index: usize = 0;
    while (i < joltage_deltas.len - 1) : (i += 1) {
        if (joltage_deltas[i] == 3 and joltage_deltas[i + 1] != 3) {
            last_index = i;
        } else if (joltage_deltas[i] != 3 and joltage_deltas[i + 1] == 3) {
            try stdout.print("{}\n", .{running_product});
            running_product *= countArrangements(3, joltage_deltas[last_index .. i + 1]);
        }
    }
    try stdout.print("{}\n", .{running_product});
}
