const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const application = @import("application.zig");
const logging = @import("Utils/logging.zig");
const zigstbi = @import("zigstbi");
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

        return Window{ .rawWindow = window, .width = width, .height = height };
    }

    pub fn startRender(self: *Window, color: ?[4]f32) void {
        _ = self;
        if (color == null) {
            gl.clearColor(255, 255, 255, 255);
        } else {
            gl.clearColor(color.?[0], color.?[1], color.?[2], color.?[3]);
        }
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }

    /// This just exists to make the engine more readable
    pub fn clear(self: *Window, color: ?[4]f32) void {
        self.startRender(color);
    }

    pub fn update(self: *Window, updateViewport: bool) void {
        const currentSize = self.rawWindow.getSize();

        if (currentSize[0] != self.width or currentSize[1] != self.height) {
            self.width = currentSize[0];
            self.height = currentSize[1];
            if (updateViewport) gl.viewport(0, 0, self.width, self.height);
        }
    }

    pub fn setIcon(self: *Window, imagePath: []const u8) !void {
        var images: [1]glfw.Image = undefined;
        var stbiImg = try zigstbi.load_file(imagePath, 0);
        defer stbiImg.deinit();

        images[0].pixels = stbiImg.bytes.ptr;
        glfw.setWindowIcon(self.rawWindow, &images);
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

    pub fn getSize(self: *Window) WindowSize {
        return WindowSize{ .height = @intCast(self.height), .width = @intCast(self.width) };
    }

    width: c_int,
    height: c_int,
    rawWindow: *glfw.Window,
};

pub const WindowSize = struct { height: i64, width: i64 };
