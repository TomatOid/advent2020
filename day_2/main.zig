const std = @import("std");
const maxInt = std.math.maxInt;
const os = std.os;
const fs = std.fs;
const mem = std.mem;
const stdout = std.io.getStdOut().writer();

pub fn parseU64(buf: []const u8, radix: u8) !u64 {
    var x: u64 = 0;

    for (buf) |c| {
        const digit = charToDigit(c);

        if (digit >= radix) {
            return error.InvalidChar;
        }

        // x *= radix
        if (@mulWithOverflow(u64, x, radix, &x)) {
            return error.Overflow;
        }

        // x += digit
        if (@addWithOverflow(u64, x, digit, &x)) {
            return error.Overflow;
        }
    }

    return x;
}

fn charToDigit(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 10,
        else => maxInt(u8),
    };
}

pub fn isPasswordValid(password_str: []const u8) !bool {
    // first, parse the first term
    var i: u64 = 0;
    while (i < password_str.len and password_str[i] >= '0' and password_str[i] <= '9') : (i += 1) {}
    if (password_str[i] != '-') return error.InvalidChar;
    var min_count = try parseU64(password_str[0..i], 10);
    i += 1;

    var j = i;
    while (j < password_str.len and password_str[j] >= '0' and password_str[j] <= '9') : (j += 1) {}
    if (password_str[j] != ' ') return error.InvalidChar;
    var max_count = try parseU64(password_str[i..j], 10);
    i = j + 1;

    if (i + 2 >= password_str.len) return error.Invalid;
    var char = password_str[i];
    i += 1;
    if (!mem.eql(u8, password_str[i .. i + 2], ": ")) return error.InvalidChar;
    i += 2;

    var char_count: u64 = 0;
    while (i < password_str.len) : (i += 1) {
        char_count += @boolToInt(password_str[i] == char);
    }

    try stdout.print("min: {}, max: {}, count: {}\n", .{ min_count, max_count, char_count });
    return char_count >= min_count and char_count <= max_count;
}

pub fn main() !void {
    var cwd = fs.cwd();
    var file = (try cwd.openFile("passwords.txt", .{ .read = true, .write = false })).reader();
    var counter: usize = 0;
    var buffer: [1024]u8 = undefined;
    while (try file.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        counter += @boolToInt(try isPasswordValid(line));
        try std.io.getStdOut().writer().print("{}\n", .{line});
    }
    try std.io.getStdOut().writer().print("{}\n", .{counter});
}
