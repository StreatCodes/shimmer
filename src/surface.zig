const c = @import("c.zig");
const std = @import("std");
const util = @import("util.zig");
const math = @import("math.zig");

pub const Surface = struct {
    const Self = @This();
    var vao: u32 = undefined;
    var vbo: u32 = undefined;

    pub fn init(allocator: *std.mem.Allocator, rect: math.Rect) !Self {
        const vertices = [_]f32{
            rect.x, rect.y,
            rect.w, rect.y,
            rect.x, rect.h,
            rect.w, rect.h,
        };

        //init vao
        c.glGenVertexArrays(1, &vao);
        c.glBindVertexArray(vao);

        c.glGenBuffers(1, &vbo);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_DYNAMIC_DRAW);

        //describe data layout
        c.glVertexAttribPointer(0, 2, c.GL_FLOAT, c.GL_FALSE, 2 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        c.glBindVertexArray(0);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);

        return Self{};
    }

    pub fn draw(self: *Self) void {
        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLE_STRIP, 0, 4);
        c.glBindVertexArray(0);
    }

    pub fn update(self: *Self, rect: math.Rect) void {
        const vertices = [_]f32{
            rect.x, rect.y,
            rect.w, rect.y,
            rect.x, rect.h,
            rect.w, rect.h,
        };

        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferSubData(c.GL_ARRAY_BUFFER, 0, vertices.len * @sizeOf(f32), &vertices);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
    }
};