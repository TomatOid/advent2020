const std = @import("std");

// split a string at the first occurance of a delim
pub fn splitString(delim: []const u8, string: []u8) ?[2][]u8 {
    var i: usize = 0;
    while (i < string.len - delim.len) : (i += 1) {
        if (std.mem.eql(u8, delim, string[i .. i + delim.len])) {
            return [2][]u8{ string[0..i], string[i + delim.len ..] };
        }
    }
    return null;
}

test "split" {
    var str = "hello, world";
    var str_mut: [str.len]u8 = undefined;
    std.mem.copy(u8, str_mut[0..], str[0..]);
    var split = splitString(", ", str_mut[0..]) orelse unreachable;
    std.testing.expect(std.mem.eql(u8, split[0], "hello"));
    std.testing.expect(std.mem.eql(u8, split[1], "world"));
}
