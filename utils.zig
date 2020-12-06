const std = @import("std");
const maxInt = std.math.maxInt;

pub fn splitString(delim: []const u8, string: []const u8) ?[2][]const u8 {
    var i: usize = 0;
    while (i < string.len - delim.len) : (i += 1) {
        if (std.mem.eql(u8, delim, string[i .. i + delim.len])) {
            return [2][]const u8{ string[0..i], string[i + delim.len ..] };
        }
    }
    return null;
}

pub fn iterateString(delim: []const u8, string: []const u8, state: *?[]const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < string.len - delim.len) : (i += 1) {
        if (std.mem.eql(u8, delim, string[i .. i + delim.len])) {
            state.* = string[i + delim.len ..];
            return string[0..i];
        }
    }
    if (state.*) |_| {
        state.* = null;
        return string;
    } else return null;
}

pub fn splitMultiDelim(delims: [][]const u8, string: []const u8) ?[2][]const u8 {
    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        delims_loop: for (delims) |delim| {
            if (i + delim.len >= string.len) continue :delims_loop;
            if (std.mem.eql(u8, delim, string[i .. i + delim.len])) {
                return [2][]const u8{ string[0..i], string[i + delim.len ..] };
            }
        }
    }
    return null;
}

pub fn iterateMultiDelim(delims: [][]const u8, string: []const u8, state: *?[]const u8) ?[]const u8 {
    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        delims_loop: for (delims) |delim| {
            if (i + delim.len >= string.len) continue :delims_loop;
            if (std.mem.eql(u8, delim, string[i .. i + delim.len])) {
                state.* = string[i + delim.len ..];
                return string[0..i];
            }
        }
    }
    if (state.*) |_| {
        state.* = null;
        return string;
    } else return null;
}

const StringDelimIterator = struct {
    state: ?[]const u8 = string,
    delim: []const u8,
    pub fn next(self: *@This()) ?[]const u8 {
        if (self.state) |str| {
            if (splitString(self.delim, str)) |pieces| {
                self.state = pieces[1];
                return pieces[0];
            } else {
                self.state = null;
                return str;
            }
        } else return null;
    }
};

pub fn getDelimIterator(delim: []const u8, string: []const u8) StringDelimIterator {
    return .{ .state = string, .delim = delim };
}

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

test "split" {
    var str = "hello, world";
    var str_mut: [str.len]u8 = undefined;
    std.mem.copy(u8, str_mut[0..], str[0..]);
    var split = splitString(", ", str_mut[0..]) orelse unreachable;
    std.testing.expect(std.mem.eql(u8, split[0], "hello"));
    std.testing.expect(std.mem.eql(u8, split[1], "world"));
}
