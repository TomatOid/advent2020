const std = @import("std");
const fs = std.fs;
const stdout = std.io.getStdOut().writer();

const Map = struct {
    width: usize,
    height: usize,
    data: []u8,

    pub fn getCharAt(self: Map, x: usize, y: usize) ?u8 {
        if (y >= self.height) {
            return null;
        }
        return self.data[x % self.width + y * self.width];
    }
};

pub fn countTrees(mountain: Map, delta_x: usize, delta_y: usize) usize {
    var trees_count: usize = 0;
    var y: usize = 0;
    var x: usize = 0;
    while (mountain.getCharAt(x, y)) |obsticle| : (y += delta_y) {
        trees_count += @boolToInt(obsticle == '#');
        x += delta_x;
    }
    return trees_count;
}

test "map" {
    const map_string = "..##.......#...#...#...#....#..#...#.#...#.#.#...##..#...#.##......#.#.#....#.#........##.##...#...#...##....#.#..#...#.#";
    var map_buffer: [map_string.len]u8 = undefined;
    std.mem.copy(u8, map_buffer[0..], map_string);
    var map: Map = .{ .width = 11, .height = 11, .data = map_buffer[0..] };
    std.debug.assert(countTrees(map, 3, 1) == 7);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = false }){};
    const allocator = &gpa.allocator;
    var cwd = fs.cwd();
    var file = try cwd.openFile("map.txt", .{ .read = true, .write = false });
    var mountain: Map = .{
        .width = 0,
        .height = 0,
        .data = try allocator.alloc(u8, (try file.getEndPos()) + 1),
    };
    var file_slice: []u8 = mountain.data[0..];
    var file_index: usize = 0;
    while (try file.reader().readUntilDelimiterOrEof(file_slice, '\n')) |line| {
        file_index += line.len;
        file_slice = mountain.data[file_index..];
        mountain.width = line.len;
        mountain.height += 1;
    }
    var product: usize = 1;
    product *= countTrees(mountain, 1, 1);
    product *= countTrees(mountain, 3, 1);
    product *= countTrees(mountain, 5, 1);
    product *= countTrees(mountain, 7, 1);
    product *= countTrees(mountain, 1, 2);
    try stdout.print("{}\n", .{product});
}
