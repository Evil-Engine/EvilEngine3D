const EE3D = @import("EE3D");
const Texture = EE3D.texture.Texture;
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;

pub const Hierarchy = struct {
    pub fn init(allocator: std.mem.Allocator) !Hierarchy {
        const icons = std.AutoHashMap(HierarchyItemType, Texture).init(allocator);

        return Hierarchy{
            .allocator = allocator,
            .icons = icons,
        };
    }

    pub fn registerIcon(allocator: std.mem.Allocator, iconHashMap: *std.AutoHashMap(HierarchyItemType, Texture), iconType: HierarchyItemType, iconName: []const u8) !void {
        const path = try std.fs.selfExeDirPathAlloc(allocator);
        defer allocator.free(path);

        const iconPath = try std.fs.path.join(allocator, &[_][]const u8{ path, "Assets", iconName });
        defer allocator.free(iconPath);

        const icon = try Texture.init(allocator, iconPath, gl.TEXTURE_2D, null, gl.RGBA, gl.UNSIGNED_BYTE);
        try iconHashMap.put(iconType, icon);
    }

    pub fn deinit(self: *Hierarchy) void {
        var iterator = self.icons.iterator();

        while (iterator.next()) |entry| {
            entry.value_ptr.destroy();
        }

        self.icons.deinit();
    }

    pub fn renderUI(self: *Hierarchy) !void {
        _ = self;
        if (zgui.begin("Hierarchy", .{ .flags = .{} })) {}
        zgui.end();
    }

    fn renderHierarchyItem(self: *Hierarchy, entry: HierarchyEntry) !bool {
        const texture = self.icons.get(entry.hierarchyitemType);

        if (texture == null) {
            try EE3D.logging.Error("Icon not registered", .{});
            return error.IconNotRegistered;
        }

        const tex_id: zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(texture.?.id)));

        zgui.image(.{ .tex_id = tex_id, .tex_data = null }, .{ .w = 25, .h = 25 });
        zgui.sameLine(.{});

        // this might become an issue later, just note to self :P
        const cName = try self.allocator.dupeZ(u8, entry.name);
        defer self.allocator.free(cName);

        return zgui.treeNode(cName);
    }
    allocator: std.mem.Allocator,
    icons: std.AutoHashMap(HierarchyItemType, Texture),
};

pub const HierarchyEntry = struct {
    name: []const u8,
    hierarchyitemType: HierarchyItemType,
};

pub const HierarchyItemType = enum {
    Planet,
    Galaxy,
    Star,
    Mesh,
};
