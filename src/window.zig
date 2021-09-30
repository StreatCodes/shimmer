const c = @import("c.zig");
const std = @import("std");
const util = @import("util.zig");
const Surface = @import("surface.zig").Surface;
const math = @import("math.zig");

fn close_window_callback(window: ?*c.GLFWwindow) callconv(.C) void {
        std.debug.print("close window cb\n", .{});
    c.glfwSetWindowShouldClose(window, c.GLFW_TRUE);
}

pub const Window = struct {
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
        c.glViewport(0, 0, x, y);
        w.window_w = x;
        w.window_h = y;
        
    }

    fn gl_error_callback(source: c.GLenum, err_type: c.GLenum, id: c.GLuint, severity: c.GLenum,
        length: c.GLsizei, message: [*c]const c.GLchar, userParam: ?*const c_void) callconv(.C) void {
        //ignore notify
        if(severity != 0x826b) {
            std.debug.print("GL Error callback:\n{s}\n", .{message});
            std.debug.print("ID: {d}\nSeverity: 0x{x}\nType: 0x{x}\n", .{id, severity, err_type});
        }
    }

    pub fn init(allocator: *std.mem.Allocator, name: [*c]const u8) !Self {
        if (c.glfwInit() != c.GLFW_TRUE) {
            std.debug.panic("Could not initialize glfw", .{});
        }

        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
        c.glfwWindowHint(c.GLFW_DOUBLEBUFFER, c.GLFW_TRUE);

        const window_width = 1280;
        const window_height = 1080;

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

        //TODO only debug
        c.glEnable(c.GL_DEBUG_OUTPUT);
        c.glDebugMessageCallback(gl_error_callback, null);

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

        var surface = try Surface.init(
            allocator,
            math.Rect{
                .x = 0,
                .y = 0,
                .w = @intToFloat(f32, self.window_w),
                .h = @intToFloat(f32, self.window_h)
            }
        );

        while (c.glfwWindowShouldClose(self.window) == 0) {
            c.glfwPollEvents();
            c.glClear(c.GL_COLOR_BUFFER_BIT);

            c.glUniform2f(mouse_cords_uni, self.mouse_x, self.mouse_y);
            c.glUniform2i(window_size_uni, self.window_w, self.window_h);
            
            surface.update(math.Rect{
                .x = 5,
                .y = 5,
                .w = 512,
                .h = 512
            });
            surface.draw();

            c.glfwSwapBuffers(self.window);
        }
    }

    pub fn deinit(self: *Self) void {
        c.glfwDestroyWindow(self.window);
    }
};