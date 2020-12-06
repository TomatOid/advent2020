const std = @import("std");
usingnamespace @import("../utils.zig");
const stdout = std.io.getStdOut().writer();

pub fn bitCount(number: u64) u64 {
    var n = number;
    var count: u64 = 0;
    while (n > 0) : (n >>= 1) {
        count += @boolToInt((n | 1) == 1);
    }
    return count;
}

pub fn countQuestions(file_buffer: []const u8, file_length: usize) !u64 {
    var group_iterator = getDelimIterator("\n\n", file_buffer[0 .. file_length - 1]);
    var total: u64 = 0;
    while (group_iterator.next()) |group| {
        var person_iterator = getDelimIterator("\n", group);
        var letters_used: u64 = 0;
        while (person_iterator.next()) |person| {
            try stdout.print("{}\n", .{person});
            for (person) |letter| {
                try stdout.print("{}\n", .{letter});
                letters_used |= @as(u64, 1) << @intCast(u6, letter - 'a');
            }
            total += bitCount(letters_used);
        }
    }
    return total;
}

pub fn main() !void {
    var cwd = std.fs.cwd();
    var file = try cwd.openFile("questions.txt", .{ .read = true, .write = false });
    var file_buffer: [65536]u8 = undefined;
    var file_length = try file.read(file_buffer[0..]);
    var total = try countQuestions(file_buffer, file_length);
    try stdout.print("{}\n", .{total});
}

test "count" {
    var test_str =
        \\abc
        \\
        \\a
        \\b
        \\c
        \\
        \\ab
        \\ac
        \\
        \\a
        \\a
        \\a
        \\a
        \\b
    ;
    var total = try countQuestions(test_str, test_str.len + 1);
    std.testing.expect(total == 11);
}
