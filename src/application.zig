const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const application = @import("application.zig");
const std = @import("std");
const logging = @import("utils/logging.zig");

pub var initialized: bool = false;

pub const Application = struct {
    pub fn init() !Application {
        // TODO: I might need to add error handling, but thats a later me issue :D
        try glfw.init();
        initialized = true;
        const allocator = std.heap.page_allocator;

        return Application{ .allocator = allocator };
    }

    pub fn create_context(self: *Application) !void {
        _ = self;
        zopengl.loadCoreProfile(getProcAddress, 4, 0) catch {
            try logging.Error("Failed to load OpenGL Profile", .{});
            return error.FailedToLoadOpenGL;
        };
        try logging.Info("Loaded OpenGL profile", .{});
    }

    pub fn destroy(self: *Application) void {
        _ = self;
        glfw.terminate();
        initialized = false;
    }

    allocator: std.mem.Allocator,
};

pub fn getProcAddress(name: [*:0]const u8) callconv(.c) ?*const anyopaque {
    return glfw.getProcAddress(name);
}
