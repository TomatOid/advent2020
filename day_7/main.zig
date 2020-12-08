const std = @import("std");
usingnamespace @import("../utils.zig");
const stdout = std.io.getStdOut().writer();

const TreeNode = struct {
    const Node = std.SinglyLinkedList(*TreeNode).Node;
    children: ?*Node = null,
    name: []const u8,
    visited: bool,

    pub fn addChild(self: *TreeNode, child: *TreeNode, allocator: *std.mem.Allocator) !void {
        var child_node = try allocator.create(Node);
        child_node.data = child;
        if (self.children) |sub_planets| {
            sub_planets.insertAfter(child_node);
        } else {
            child_node.next = null;
            self.children = child_node;
        }
    }

    pub fn freeSelf(self: *TreeNode, allocator: *std.mem.Allocator) void {
        var current_node = self.children;
        while (current_node) |value| {
            current_node = value.next;
            allocator.destroy(value);
        }
        allocator.destroy(self);
    }

    pub fn init(self: *TreeNode, name: []const u8) *TreeNode {
        self.children = null;
        self.visited = false;
        return self;
    }

    pub fn countDescendents(self: *TreeNode) usize {
        var count: usize = 0;
        var current_node = self.children;
        while (current_node) |value| {
            current_node = value.next;
            if (value.data.visited) continue;
            count += 1 + value.data.countDescendents();
        }
        self.visited = true;
        return count;
    }
};

pub fn stripIrrelevant(string: []const u8) []const u8 {
    var result = string;
    // possible overflow but I don't care
    if (string[0] >= '0' and string[0] <= '9') result = string[2..];
    if (string[string.len - 1] == 's') result = result[0 .. result.len - 1];
    return result;
}

test "strip" {
    var stripped = stripIrrelevant("shiny gold bags");
    std.testing.expect(std.mem.eql(u8, stripped, "shiny gold bag"));
    stripped = stripIrrelevant("1 shiny gold bag");
    std.testing.expect(std.mem.eql(u8, stripped, "shiny gold bag"));
    stripped = stripIrrelevant("9 shiny yellow bags");
    std.testing.expect(std.mem.eql(u8, stripped, "shiny yellow bag"));
    stripped = stripIrrelevant("shiny gold bag");
    std.testing.expect(std.mem.eql(u8, stripped, "shiny gold bag"));
}

pub fn buildTree(file: []const u8, bags_map: *std.StringHashMap(*TreeNode), allocator: *std.mem.Allocator) !void {
    var line_iterator = getDelimIterator("\n", file);
    while (line_iterator.next()) |line| {
        var parent_child = splitString(" contain ", line) orelse return error.NoContain;
        var parent_string = stripIrrelevant(parent_child[0]);
        var parent: *TreeNode = undefined;
        if (bags_map.get(parent_string)) |parent_value| {
            parent = parent_value;
        } else {
            parent = (try allocator.create(TreeNode)).init(parent_string);
            try bags_map.put(parent_string, parent);
        }
        var comma_iterator = getDelimIterator(", ", parent_child[1][0 .. parent_child[1].len - 1]);
        while (comma_iterator.next()) |child_bag| {
            var child_string = stripIrrelevant(child_bag);
            var child: *TreeNode = undefined;
            if (std.mem.eql(u8, child_string, "no other bags")) break;
            if (bags_map.get(child_string)) |child_value| {
                child = child_value;
            } else {
                child = (try allocator.create(TreeNode)).init(child_string);
                try bags_map.put(child_string, child);
            }
            try child.addChild(parent, allocator);
        }
    }
}

test "build tree" {
    var file =
        \\light red bags contain 1 bright white bag, 2 muted yellow bags.
        \\dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        \\bright white bags contain 1 shiny gold bag.
        \\muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        \\shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        \\dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        \\vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        \\faded blue bags contain no other bags.
        \\dotted black bags contain no other bags.
    ;
    var bags_map = std.StringHashMap(*TreeNode).init(std.testing.allocator);
    defer bags_map.deinit();
    defer {
        var iterator = bags_map.iterator();
        while (iterator.next()) |kv| {
            kv.value.freeSelf(std.testing.allocator);
        }
    }
    try buildTree(file, &bags_map, std.testing.allocator);
    var gold_node = bags_map.get("shiny gold bag") orelse unreachable;
    std.testing.expect(gold_node.countDescendents() == 4);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = &gpa.allocator;

    var cwd = std.fs.cwd();
    var file = try cwd.openFile("rules.txt", .{ .read = true, .write = false });
    var file_buffer: [65536]u8 = undefined;
    var file_length = try file.read(file_buffer[0..]);
    if (file_length >= file_buffer.len) return error.FileTooLarge;

    var bags_map = std.StringHashMap(*TreeNode).init(allocator);
    defer bags_map.deinit();
    defer {
        var iterator = bags_map.iterator();
        while (iterator.next()) |kv| {
            kv.value.freeSelf(allocator);
        }
    }

    try buildTree(file_buffer[0 .. file_length - 1], &bags_map, allocator);
    var gold_node = bags_map.get("shiny gold bag") orelse return error.NoShinyGold;
    try stdout.print("{}\n", .{gold_node.countDescendents()});
}
