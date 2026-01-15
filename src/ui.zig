const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const application = @import("application.zig");
const window = @import("window.zig");
const logging = @import("Utils/logging.zig");
const gl = zopengl.bindings;
const zgui = @import("zgui");
const std = @import("std");
const testing = std.testing;

pub var bigFont: zgui.Font = undefined;

pub const UI = struct {
    pub fn init(Window: window.Window) UI {
        zgui.init(application.allocator);
        zgui.backend.init(Window.rawWindow);
        zgui.io.setConfigFlags(.{ .dock_enable = true, .viewport_enable = true });
        return UI{ .Window = Window };
    }

    pub fn deinit(self: *UI) void {
        _ = self;
        zgui.deinit();
        zgui.backend.deinit();
    }

    pub fn startRender(self: *UI) void {
        const fbSize = self.Window.rawWindow.getFramebufferSize();

        zgui.backend.newFrame(@intCast(fbSize[0]), @intCast(fbSize[1]));
        _ = zgui.dockSpaceOverViewport(0, zgui.getMainViewport(), .{ .passthru_central_node = true });
    }

    pub fn applyDarkTheme(self: *UI) void {
        _ = self;
        const style = zgui.getStyle();
        _ = zgui.io.addFontFromFile("M_PLUS_Rounded_1c/MPLUSRounded1c-ExtraBold.ttf", 18);
        bigFont = zgui.io.addFontFromFile("M_PLUS_Rounded_1c/MPLUSRounded1c-ExtraBold.ttf", 48);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.text))] = rgba1(202, 211, 245, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.window_bg))] = rgba1(36, 39, 58, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.border))] = rgba1(36 + 2, 39 + 2, 58 + 2, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.menu_bar_bg))] = rgba1(54, 58, 79, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.child_bg))] = rgba1(24 + 4, 25 + 4, 38 + 4, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.title_bg))] = rgba1(54, 58, 79, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.title_bg_active))] = rgba1(50 + 30, 54 + 30, 74 + 30, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab))] = rgba1(110, 115, 141, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_hovered))] = rgba1(54, 58, 79, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_selected))] = rgba1(91 + 10, 96 + 10, 120 + 10, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_selected_overline))] = rgba1(91 + 10, 96 + 10, 120 + 10, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_dimmed))] = rgba1(110, 115, 141, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_dimmed_selected))] = rgba1(91 + 10, 96 + 10, 120 + 10, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.tab_dimmed_selected_overline))] = rgba1(91 + 10, 96 + 10, 120 + 10, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.resize_grip))] = rgba1(240, 198, 198, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.resize_grip_hovered))] = rgba1(240, 198, 198, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.resize_grip_active))] = rgba1(240 + 10, 198 + 10, 198 + 10, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.docking_preview))] = rgba1(240, 198, 198, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.button))] = rgba1(128, 135, 162, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.button_hovered))] = rgba1(110, 115, 141, 255);
        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.button_active))] = rgba1(91, 96, 120, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.popup_bg))] = rgba1(73, 77, 100, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.header_hovered))] = rgba1(110, 115, 141, 255);

        style.colors[@as(usize, @intFromEnum(zgui.StyleCol.modal_window_dim_bg))] = rgba1(73, 77, 77, 120);

        style.window_rounding = 8;
        style.grab_rounding = 4;
        style.tab_rounding = 4;
        style.window_padding = [2]f32{ 8.0, 8.0 };
    }

    pub fn endRender(self: *UI) void {
        zgui.backend.draw();

        zgui.updatePlatformWindows();
        zgui.renderPlatformWindowsDefault();
        glfw.makeContextCurrent(self.Window.rawWindow);
    }

    Window: window.Window,
};

pub fn rgba1(r: u8, g: u8, b: u8, a: u8) [4]f32 {
    const rf = srgbToLinear(@as(f32, @floatFromInt(r)) / 255.0);
    const gf = srgbToLinear(@as(f32, @floatFromInt(g)) / 255.0);
    const bf = srgbToLinear(@as(f32, @floatFromInt(b)) / 255.0);

    return [4]f32{ rf, gf, bf, @as(f32, @floatFromInt(a)) / 255.0 };
}

fn srgbToLinear(c: f32) f32 {
    if (c <= 0.04045) {
        return c / 12.92;
    } else return std.math.pow(f32, (c + 0.055) / 1.055, 2.4);
}

test "rgb1 255/255" {
    const rgbValue = rgba1(255, 0, 0, 0);

    try testing.expect(rgbValue[0] == 1);
}

test "rgb1 255/250" {
    const rgbValue = rgba1(255, 0, 0, 0);

    try testing.expect(rgbValue[0] == 0.9);
}
