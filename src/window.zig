const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const application = @import("application.zig");
const logging = @import("utils/logging.zig");
const gl = zopengl.bindings;

pub const Window = struct {
    pub fn init(width: i32, height: i32, title: [:0]const u8) !Window {
        if (!application.initialized) {
            try logging.Error("Tried to create a window while the application was not initialized.", .{});
            return error.NotInitialized;
        }

        glfw.windowHint(.context_version_major, 4);
        glfw.windowHint(.context_version_minor, 0);
        glfw.windowHint(.opengl_profile, .opengl_core_profile);
        const window = try glfw.createWindow(@intCast(width), @intCast(height), title, null);
        glfw.makeContextCurrent(window);

        glfw.swapInterval(1);

        return Window{ .rawWindow = window };
    }

    pub fn startRender(self: *Window) void {
        _ = self;
        gl.clearColor(0.07, 0.13, 0.17, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);
    }

    pub fn endRender(self: *Window) void {
        self.rawWindow.swapBuffers();
        glfw.pollEvents();
    }

    pub fn destroy(self: *Window) void {
        glfw.destroyWindow(self.rawWindow);
    }

    pub fn shouldClose(self: *Window) bool {
        return self.rawWindow.shouldClose();
    }

    rawWindow: *glfw.Window,
};
