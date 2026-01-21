const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;

pub const Hierarchy = struct {
    pub fn renderUI(self: *Hierarchy) !void {
        _ = self;
        if (zgui.begin("Hierarchy", .{ .flags = .{} })) {}
        zgui.end();
    }
};
