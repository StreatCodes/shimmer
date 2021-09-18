const std = @import("std");

const c = @import("c.zig");
const Shimmer = @import("window.zig").Shimmer;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) {
            @panic("memory leaked");
        }
    }
    const alloc: *std.mem.Allocator = &gpa.allocator;


    var shimmer = try Shimmer.init(alloc, "shimmer");
    try shimmer.run(alloc);

    defer shimmer.deinit();
}