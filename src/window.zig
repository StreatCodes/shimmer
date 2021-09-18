const c = @import("c.zig");
const std = @import("std");
const util = @import("util.zig");

fn close_window_callback(window: ?*c.GLFWwindow) callconv(.C) void {
    c.glfwSetWindowShouldClose(window, c.GLFW_TRUE);
}

fn request_adapter_callback(impl: ?*c.WGPUAdapterImpl, a: ?*c_void) callconv(.C) void {

}

pub const Shimmer = struct {
    const Self = @This();

    window: *c.GLFWwindow,

    pub fn init(allocator: *std.mem.Allocator,  name: [*c]const u8) !Self {
        if (c.glfwInit() != c.GLFW_TRUE) {
            std.debug.panic("Could not initialize glfw", .{});
        }

        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

        const window = c.glfwCreateWindow(1280, 720,
            name,
            null,
            null,
        ) orelse return error.FailedToCreateWindow;
        c.glfwMakeContextCurrent(window);

        _ = c.glfwSetWindowCloseCallback(window, close_window_callback);
        // void framebuffer_size_callback(GLFWwindow* window, int width, int height);
        // glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

        c.glViewport(0, 0, 1280, 720);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);

        return Self {
            .window = window,
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

        //Buffer init
        const vertices = [_]f32{
            10.0, 20.0,
            40.0, 20.0,
            10.0, 40.0,
            40.0, 40.0,
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

            c.glBindVertexArray(vao);
            c.glDrawArrays(c.GL_TRIANGLE_STRIP, 0, 4);

            c.glfwSwapBuffers(self.window);
        }
    }

    pub fn deinit(self: *Self) void {
        c.glfwDestroyWindow(self.window);
    }
};