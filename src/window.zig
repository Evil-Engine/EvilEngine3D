const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const application = @import("application.zig");
const logging = @import("utils/logging.zig");
const gl = zopengl.bindings;
const zgui = @import("zgui");

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

        try logging.Info("ZGui Backend initialized\n", .{});
        zgui.init(application.allocator);
        zgui.backend.init(window);

        return Window{ .rawWindow = window };
    }

    pub fn startRender(self: *Window) void {
        gl.clearColor(0.07, 0.13, 0.17, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        const fb_size = self.rawWindow.getFramebufferSize();
        zgui.backend.newFrame(@intCast(fb_size[0]), @intCast(fb_size[1]));
    }

    pub fn endRender(self: *Window) void {
        zgui.backend.draw();
        self.rawWindow.swapBuffers();
        glfw.pollEvents();
    }

    pub fn destroy(self: *Window) void {
        glfw.destroyWindow(self.rawWindow);
        zgui.backend.deinit();
        zgui.deinit();
    }

    pub fn shouldClose(self: *Window) bool {
        return self.rawWindow.shouldClose();
    }

    pub fn getSize(self: *Window) WindowSize {
        var width: c_int = 0;
        var height: c_int = 0;

        glfw.getWindowSize(self.rawWindow, &width, &height);
        return WindowSize{ .height = @intCast(height), .width = @intCast(width) };
    }

    rawWindow: *glfw.Window,
};

pub const WindowSize = struct { height: i64, width: i64 };
