const EE3D = @import("EE3D");
const Texture = EE3D.texture.Texture;
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;

pub const Hierarchy = struct {
    pub fn init(allocator: std.mem.Allocator) !Hierarchy {
        var icons = std.AutoHashMap(HierarchyItemType, Texture).init(allocator);
        try registerIcon(allocator, &icons, .Galaxy, "Galaxy-Icon.png");
        try registerIcon(allocator, &icons, .Star, "Star-Icon.png");
        try registerIcon(allocator, &icons, .Planet, "Planet-Icon.png");
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
        if (zgui.begin("Hierarchy", .{ .flags = .{} })) {
            if (try renderHierarchyItem(self, .{
                .hierarchyitemType = .Galaxy,
                .name = "Milky Way",
            })) {
                if (try renderHierarchyItem(self, .{
                    .hierarchyitemType = .Star,
                    .name = "Sol",
                })) {
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Mercury",
                    })) {
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Venus",
                    })) {
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Earth",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Luna (Moon)",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Mars",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Phobos",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Deimos",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Ceres",
                    })) {
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Jupiter",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Io",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Europa",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Ganymede",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Calisto",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Saturn",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Mimas",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Enceladus",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Tethys",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Dione",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Rhea",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Titan",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Uranus",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Miranda",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Ariel",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Umbriel",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Titania",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Oberon",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Neptune",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Triton",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Pluto",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Charon",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Styx",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Nix",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Kerberos",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Hydra",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Haumea",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Namaka",
                        })) {
                            zgui.treePop();
                        }
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Hi'iaka",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Makemake",
                    })) {
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Quaoar",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Weywot",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Orcus",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Vanith",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Eris",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Dysnomia",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Gonggong",
                    })) {
                        if (try renderHierarchyItem(self, .{
                            .hierarchyitemType = .Planet,
                            .name = "Xiangliu",
                        })) {
                            zgui.treePop();
                        }
                        zgui.treePop();
                    }
                    if (try renderHierarchyItem(self, .{
                        .hierarchyitemType = .Planet,
                        .name = "Sedna",
                    })) {
                        zgui.treePop();
                    }
                    zgui.treePop();
                }
                zgui.treePop();
            }
        }
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
