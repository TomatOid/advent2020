const std = @import("std");

const Map = struct {
    width: usize,
    height: usize,
    data: []const u8,

    pub fn getCharAt(self: Map, x: usize, y: usize) ?u8 {
        if (y >= self.height) {
            return null;
        }
        return self.data[x % self.width + y * self.width];
    }
};

test "map" {
    var map: Map = .{ .width = 11, .height = 11, .data = undefined };
    map.data = "..##.......#...#...#...#....#..#...#.#...#.#.#...##..#...#.##......#.#.#....#.#........##.##...#...#...##....#.#..#...#.#";
    var y: usize = 0;
    var trees_count: usize = 0;
    while (map.getCharAt(3 * y, y)) |obsticle| : (y += 1) {
        trees_count += @boolToInt(obsticle == '#');
    }
    std.debug.assert(trees_count == 7);
}
