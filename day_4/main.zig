const std = @import("std");
const fs = std.fs;
const stdout = std.io.getStdOut().writer();
const re = @import("zig-regex/src/regex.zig").Regex;
usingnamespace @import("../utils.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = false }){};
const allocator = &gpa.allocator;

const required_fields = [_][]const u8{ "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid" };
const regex_strings = [_][]const u8{ "([0-9]{2}in)|([0-9]{3}cm)", "#[0123456789abcdef]{6}", "amb|blu|brn|gry|grn|hzl|oth", "[0-9]{9}" };

var fields_regex: [regex_strings.len]re = undefined;

pub fn main() !void {
    inline for (regex_strings) |regex, i| {
        fields_regex[i] = try re.compile(allocator, regex_strings[i]);
    }

    var cwd = fs.cwd();
    var file = try cwd.openFile("passports.txt", .{ .read = true, .write = false });

    var buffer: [65536]u8 = undefined;
    var file_length = try file.read(buffer[0..]);
    if (file_length >= buffer.len) return error.FileTooLarge;
    var valid_passports_count = try countPassports(buffer[0..file_length]);
    try std.io.getStdOut().writer().print("{} valid passports.\n", .{valid_passports_count});
}

pub fn countPassports(file_slice: []const u8) !usize {
    var file_data: []const u8 = file_slice;
    var delims = [_][]const u8{ " ", "\n" };
    var valid_passports_count: usize = 0;
    var high_state: ?[]const u8 = null;
    while (iterateString("\n\n", file_data, &high_state)) |passports| : (file_data = high_state orelse file_data) {
        var passport_data = passports;
        var passport_flags: u64 = 0;
        var mid_state: ?[]const u8 = null;
        while (iterateMultiDelim(delims[0..], passport_data, &mid_state)) |fields| : (passport_data = mid_state orelse passport_data) {
            if (splitString(":", fields)) |kv| {
                var key = kv[0];
                //var value = (splitMultiDelim(delims[0..], kv[1]) orelse [2][]const u8{ kv[1], kv[1] })[0];
                var value = kv[1];
                stdout.print("{}, {}\n", .{ key, value }) catch |err| {};
                for (required_fields) |field, i| {
                    if (std.mem.eql(u8, field, key)) {
                        var is_valid: bool = false;
                        if (i < 3) {
                            var year = parseU64(value, 10) catch |_| break;
                            is_valid = switch (i) {
                                0 => (year >= 1920 and year <= 2002),
                                1 => (year >= 2010 and year <= 2020),
                                2 => (year >= 2020 and year <= 2030),
                                else => false,
                            };
                        } else if (i == 3) {
                            if (try fields_regex[i - 3].match(value)) {
                                var height = parseU64(value[0 .. value.len - 2], 10) catch |_| break;
                                if (value.len == 5) { // cm
                                    is_valid = height >= 150 and height <= 193;
                                } else if (value.len == 4) { // in
                                    is_valid = height >= 59 and height <= 76;
                                }
                            } else break;
                        } else if (i > 3) {
                            if (try fields_regex[i - 3].match(value)) {
                                is_valid = true;
                            } else break;
                        }
                        if (is_valid) {
                            passport_flags |= @as(usize, 1) << @intCast(u6, i);
                            try stdout.print("ok.\n", .{});
                            break;
                        }
                    }
                }
            }
        }
        stdout.print("{}\n", .{passport_flags}) catch |err| {};
        if (passport_flags == (1 << required_fields.len) - 1) valid_passports_count += 1;
    }
    return valid_passports_count;
}

test "passport" {
    inline for (regex_strings) |regex, i| {
        fields_regex[i] = try re.compile(allocator, regex_strings[i]);
    }
    var passports_bad =
        \\eyr:1972 cid:100
        \\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
        \\
        \\iyr:2019
        \\hcl:#602927 eyr:1967 hgt:170cm
        \\ecl:grn pid:012533040 byr:1946
        \\
        \\hcl:dab227 iyr:2012
        \\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
        \\
        \\hgt:59cm ecl:zzz
        \\eyr:2038 hcl:74454a iyr:2023
        \\pid:3556412378 byr:2007
    ;
    try stdout.print("{}\n", .{countPassports(passports_bad)});
    std.testing.expect((try countPassports(passports_bad)) == 0);
    var passports_good =
        \\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        \\hcl:#623a2f
        \\
        \\eyr:2029 ecl:blu cid:129 byr:1989
        \\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
        \\
        \\hcl:#888785
        \\hgt:164cm byr:2001 iyr:2015 cid:88
        \\pid:545766238 ecl:hzl
        \\eyr:2022
        \\
        \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
    ;
    try stdout.print("{}\n", .{countPassports(passports_good)});
    std.testing.expect((try countPassports(passports_good)) == 4);
}
