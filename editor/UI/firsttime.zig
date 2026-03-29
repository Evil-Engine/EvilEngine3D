const EE3D = @import("EE3D");
const std = @import("std");
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;
const gl = EE3D.zopengl.bindings;

pub const FirstTime = struct {
    step: u32,
    isFirstTime: bool,
    banner: EE3D.texture.Texture,

    pub fn init(allocator: std.mem.Allocator) !FirstTime {
        const path = try std.fs.selfExeDirPathAlloc(allocator);
        defer allocator.free(path);

        const bannerPath = try std.fs.path.join(allocator, &[_][]const u8{ path, "Assets", "EvilEngine-Banner-Transparent.png" });
        defer allocator.free(bannerPath);
        const banner = try EE3D.texture.Texture.init(allocator, bannerPath, gl.TEXTURE_2D, null, gl.RGBA, gl.UNSIGNED_BYTE);
        return FirstTime{
            .banner = banner,
            .isFirstTime = false,
            .step = 0,
        };
    }

    pub fn deinit(self: *FirstTime) void {
        self.banner.destroy();
    }

    pub fn renderUI(self: *FirstTime) void {
        if (zgui.begin("First Time", .{ .flags = .{} })) {
            const banner_id: EE3D.zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(self.banner.id)));
            const width = zgui.getContentRegionAvail()[0];
            zgui.setCursorPosX((width / 2) - 180);
            zgui.image(.{ .tex_id = banner_id, .tex_data = null }, .{ .w = 360, .h = 180, .uv0 = .{ 0.0, 1.0 }, .uv1 = .{ 1.0, 0.0 } });
            if (self.step == 0) {}

            zgui.pushStyleColor4f(.{ .c = EE3D.ui.rgba1(231, 130, 132, 255), .idx = .text });
            UI.centeredText("You can always change these in Edit > Settings", true, false);
            zgui.popStyleColor(.{ .count = 1 });
        }
        zgui.end();
    }
};
