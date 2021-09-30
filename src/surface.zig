const c = @import("c.zig");
const std = @import("std");
const util = @import("util.zig");
const math = @import("math.zig");

pub const Surface = struct {
    const Self = @This();
    var vao: u32 = undefined;
    var vbo: u32 = undefined;
    var texture: u32 = undefined;

    pub fn init(allocator: *std.mem.Allocator, rect: math.Rect) !Self {
        const vertices = [_]f32{
            rect.x, rect.y, 0.0, 1.0,
            rect.w, rect.y, 1.0, 1.0,
            rect.x, rect.h, 0.0, 0.0,
            rect.w, rect.h, 1.0, 0.0
        };

        //init vao
        c.glGenVertexArrays(1, &vao);
        c.glBindVertexArray(vao);

        c.glGenBuffers(1, &vbo);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_DYNAMIC_DRAW);

        //describe data layout
        c.glVertexAttribPointer(0, 2, c.GL_FLOAT, c.GL_FALSE, 4 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);
        c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 4 * @sizeOf(f32), @intToPtr(?*c.GLvoid, 2 * @sizeOf(f32)));
        c.glEnableVertexAttribArray(1);

        //create bitmap rainbow
        var bitmap = try allocator.alloc(u8, 512 * 512);
        for(bitmap) |*v, i| {
            v.* = @intCast(u8, i % 240);
        }

        c.glGenTextures(1, &texture);
        c.glBindTexture(c.GL_TEXTURE_2D, texture);

        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
        c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
        
        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RED, 512, 512, 0, c.GL_RED, c.GL_UNSIGNED_BYTE, bitmap.ptr);

        c.glBindVertexArray(0);

        return Self{};
    }

    pub fn draw(self: *Self) void {
        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLE_STRIP, 0, 4);
        c.glBindVertexArray(0);
    }

    pub fn update(self: *Self, rect: math.Rect) void {
        const vertices = [_]f32{
            rect.x, rect.y, 0.0, 1.0,
            rect.w, rect.y, 1.0, 1.0,
            rect.x, rect.h, 0.0, 0.0,
            rect.w, rect.h, 1.0, 0.0
        };

        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
        c.glBufferSubData(c.GL_ARRAY_BUFFER, 0, vertices.len * @sizeOf(f32), &vertices);
    }
};