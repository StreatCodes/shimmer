const std = @import("std");

const c = @import("c.zig");
const Window = @import("window.zig").Window;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) {
            @panic("memory leaked");
        }
    }
    const alloc: *std.mem.Allocator = &gpa.allocator;


    var shimmer = try Window.init(alloc, "shimmer");
    _ = c.glfwSetWindowUserPointer(shimmer.window, &shimmer); //TODO move me

    try shimmer.run(alloc);

    defer shimmer.deinit();
}