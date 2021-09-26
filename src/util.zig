const c = @import("c.zig");
const std = @import("std");

pub fn read_file(allocator: *std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(
        path,
        .{ .read = true },
    );
    defer file.close();

    const stat = try file.stat();
    var buffer = try allocator.alloc(u8, stat.size);

    _ = try file.readAll(buffer);
    return buffer;
}

pub fn compile_shader(allocator: *std.mem.Allocator, shader_src_path: []const u8, shader_type: c.GLenum) !u32 {
    const src = try read_file(allocator, shader_src_path);
    defer allocator.free(src);

    const shader = c.glCreateShader(shader_type);
    c.glShaderSource(shader, 1, &src.ptr, null);
    c.glCompileShader(shader);

    var success: i32 = 0;
    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);

    if(success != c.GL_TRUE) {
        const buffer = try allocator.alloc(u8, 2048);
        var len: i32 = 0;
        // defer allocator.free(buffer);
        c.glGetShaderInfoLog(shader, @intCast(c_int, buffer.len), &len, buffer.ptr);
        std.debug.panic("Failed to compile shader: {s}\n", .{buffer[0..@intCast(usize, len)]});
    }

    return shader;
}
