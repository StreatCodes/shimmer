const c = @import("c.zig");
const std = @import("std");
const util = @import("util.zig");

fn close_window_callback(window: ?*c.GLFWwindow) callconv(.C) void {
    c.glfwSetWindowShouldClose(window, c.GLFW_TRUE);
}

pub const Shimmer = struct {
    const Self = @This();

    window: *c.GLFWwindow,
    mouse_x: f32,
    mouse_y: f32,
    window_w: i32,
    window_h: i32,

    fn cursor_position_callback(window: ?*c.GLFWwindow, x: f64, y: f64) callconv(.C) void {
        const w = @ptrCast(*Self, @alignCast(@alignOf(Self), c.glfwGetWindowUserPointer(window)));
        w.mouse_x = @floatCast(f32, x);
        w.mouse_y = @floatCast(f32, y);
    }

    fn frame_size_callback(window: ?*c.GLFWwindow, x: i32, y: i32) callconv(.C) void {
        const w = @ptrCast(*Self, @alignCast(@alignOf(Self), c.glfwGetWindowUserPointer(window)));
        w.window_w = x;
        w.window_h = y;
    }

    pub fn init(allocator: *std.mem.Allocator, name: [*c]const u8) !Self {
        if (c.glfwInit() != c.GLFW_TRUE) {
            std.debug.panic("Could not initialize glfw", .{});
        }

        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

        const window_width = 1280;
        const window_height = 720;

        const window = c.glfwCreateWindow(window_width, window_height,
            name,
            null,
            null,
        ) orelse return error.FailedToCreateWindow;
        c.glfwMakeContextCurrent(window);

        _ = c.glfwSetWindowCloseCallback(window, close_window_callback);
        _ = c.glfwSetFramebufferSizeCallback(window, frame_size_callback);
        _ = c.glfwSetCursorPosCallback(window, cursor_position_callback);

        c.glViewport(0, 0, window_width, window_height);
        c.glClearColor(0.2, 0.3, 0.3, 1.0);

        return Self {
            .window = window,
            .mouse_x = 0.0,
            .mouse_y = 0.0,
            .window_w = window_width,
            .window_h = window_height
        };
    }

    pub fn run(self: *Self, allocator: *std.mem.Allocator) !void {
        //Shader init
        const vertex_shader = try util.compile_shader(allocator, "res/vert.glsl", c.GL_VERTEX_SHADER);
        const fragment_shader = try util.compile_shader(allocator, "res/frag.glsl", c.GL_FRAGMENT_SHADER);
        defer c.glDeleteShader(vertex_shader);
        defer c.glDeleteShader(fragment_shader);

        const shader_prog = c.glCreateProgram();
        c.glAttachShader(shader_prog, vertex_shader);
        c.glAttachShader(shader_prog, fragment_shader);
        c.glLinkProgram(shader_prog);
        c.glUseProgram(shader_prog);
        //TODO delete prog?

        const mouse_cords_uni = c.glGetUniformLocation(shader_prog, "mouse_cords");
        const window_size_uni = c.glGetUniformLocation(shader_prog, "window_size");

        //Buffer init
        // const vertices = [_]f32{
        //     10.0, 20.0,
        //     40.0, 20.0,
        //     10.0, 40.0,
        //     40.0, 40.0,
        // };
        const vertices = [_]f32{
            0, 0,
            @intToFloat(f32, self.window_w), 0,
            0, @intToFloat(f32, self.window_h),
            @intToFloat(f32, self.window_w), @intToFloat(f32, self.window_h),
        };

        //init vao
        var vao: u32 = 0;
        c.glGenVertexArrays(1, &vao);
        c.glBindVertexArray(vao);

        var vbo: u32 = 0;
        c.glGenBuffers(1, &vbo);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);

        c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);

        //describe data layout
        c.glVertexAttribPointer(0, 2, c.GL_FLOAT, c.GL_FALSE, 2 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        while (c.glfwWindowShouldClose(self.window) == 0) {
            c.glfwPollEvents();
            c.glClear(c.GL_COLOR_BUFFER_BIT);

            c.glUniform2f(mouse_cords_uni, self.mouse_x, self.mouse_y);
            c.glUniform2i(window_size_uni, self.window_w, self.window_h);

            c.glBindVertexArray(vao);
            c.glDrawArrays(c.GL_TRIANGLE_STRIP, 0, 4);

            c.glfwSwapBuffers(self.window);
        }
    }

    pub fn deinit(self: *Self) void {
        c.glfwDestroyWindow(self.window);
    }
};