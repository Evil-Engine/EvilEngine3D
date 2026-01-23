const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;

pub const AssetBrowser = struct {
    pub fn init(allocator: std.mem.Allocator) !AssetBrowser {
        var icons = std.AutoHashMap(AssetType, Texture).init(allocator);
        try registerIcon(allocator, &icons, .GenericFile, "Generic-Icon.png");
        try registerIcon(allocator, &icons, .Folder, "Folder-Icon.png");
        try registerIcon(allocator, &icons, .Script, "Script-Icon.png");
        try registerIcon(allocator, &icons, .Mesh, "Mesh-Icon.png");

        return AssetBrowser{ .allocator = allocator, .icons = icons };
    }

    /// Btw iconName should be like "Script-Icon.png"
    fn registerIcon(allocator: std.mem.Allocator, iconHashMap: *std.AutoHashMap(AssetType, Texture), iconType: AssetType, iconName: []const u8) !void {
        const path = try std.fs.selfExeDirPathAlloc(allocator);
        defer allocator.free(path);

        const iconPath = try std.fs.path.join(allocator, &[_][]const u8{ path, "Assets", iconName });
        defer allocator.free(iconPath);

        const icon = try Texture.init(allocator, iconPath, gl.TEXTURE_2D, null, gl.RGBA, gl.UNSIGNED_BYTE);
        try iconHashMap.put(iconType, icon);
    }

    pub fn deinit(self: *AssetBrowser) void {
        var iterator = self.icons.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.destroy();
        }

        self.icons.deinit();
    }

    pub fn draw(self: *AssetBrowser) !void {
        if (EE3D.zgui.begin("Assets", .{})) {
            const availSpaceX = EE3D.zgui.getContentRegionAvail()[0];
            const icon_size = 100 + 3;
            const columns: i32 = @max(1, @as(i32, @intFromFloat(availSpaceX / icon_size)));

            _ = self;
            //var i: u8 = 0;
            if (EE3D.zgui.beginTable("AssetGrid", .{ .column = columns, .flags = .{ .resizable = true, .no_borders_in_body = true, .no_host_extend_x = true, .sizing = .stretch_same } })) {
                //while (i < 255) : (i += 1) {
                //    _ = EE3D.zgui.tableNextColumn();
                //    EE3D.zgui.beginGroup();
                //    const icon = if (i == 0) self.icons.get(.Mesh).? else if (i == 1) self.icons.get(.Script).? else self.icons.get(.Folder).?;
                //    const tex_id: EE3D.zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(icon.id)));
                //    const folderId = try std.fmt.allocPrint(self.allocator, "Folder{d}", .{i});
                //    const folderIdC = try self.allocator.dupeZ(u8, folderId);
                //    defer {
                //        self.allocator.free(folderIdC);
                //        self.allocator.free(folderId);
                //    }
                //
                //    _ = EE3D.zgui.imageButton(
                //        folderIdC,
                //        .{
                //            .tex_data = null,
                //            .tex_id = tex_id,
                //        },
                //        .{
                //            .w = 100,
                //            .h = 100,
                //            .uv0 = [_]f32{ 0, 1 },
                //            .uv1 = [_]f32{ 1, 0 },
                //        },
                //    );
                //
                //    EE3D.zgui.text("Folder Name", .{});
                //    EE3D.zgui.endGroup();
                //}
                EE3D.zgui.endTable();
            }
        }

        EE3D.zgui.end();
    }

    allocator: std.mem.Allocator,
    icons: std.AutoHashMap(AssetType, Texture),
};

pub const AssetBrowserEntry = struct {
    name: []const u8,
    assetType: AssetType,
};

pub const AssetType = enum {
    Folder,
    Image,
    Mesh,
    Audio,
    Script,
    GenericFile,
};
