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
        try registerIcon(allocator, &icons, .Audio, "Audio-Icon.png");

        const entries = try std.ArrayList(AssetBrowserEntry).initCapacity(allocator, 1);
        const currentPath = try allocator.dupe(u8, ".");
        const projectRoot = try allocator.dupe(u8, ".");

        return AssetBrowser{ .allocator = allocator, .projectRoot = projectRoot, .currentPath = currentPath, .entries = entries, .icons = icons };
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

    fn detectAssetType(name: []const u8) AssetType {
        const ext = std.fs.path.extension(name);

        if (std.mem.eql(u8, ext, ".png") or std.mem.eql(u8, ext, ".jpg") or std.mem.eql(u8, ext, ".tif") or std.mem.eql(u8, ext, ".bmp")) return .Image;
        if (std.mem.eql(u8, ext, ".obj") or std.mem.eql(u8, ext, ".fbx") or std.mem.eql(u8, ext, ".b3d") or std.mem.eql(u8, ext, ".gltf")) return .Mesh;
        if (std.mem.eql(u8, ext, ".wav") or std.mem.eql(u8, ext, ".ogg") or std.mem.eql(u8, ext, ".mp3")) return .Audio;
        if (std.mem.eql(u8, ext, ".zig")) return .Script;

        return .GenericFile;
    }

    fn drawBreadcrumbs(self: *AssetBrowser) !void {
        if (EE3D.zgui.smallButton("Assets")) {
            if (!std.mem.eql(u8, self.projectRoot, self.currentPath))
                try self.changeDir(self.projectRoot);
            return;
        }

        if (std.mem.eql(u8, self.currentPath, self.projectRoot)) {
            EE3D.zgui.newLine();
            return;
        }

        EE3D.zgui.sameLine(.{});
        EE3D.zgui.text(">", .{});
        EE3D.zgui.sameLine(.{});

        const relative = self.currentPath[self.projectRoot.len + 1 ..];

        var it = std.mem.splitScalar(u8, relative, std.fs.path.sep);

        var partial = try std.ArrayList(u8).initCapacity(self.allocator, 32);
        defer partial.deinit(self.allocator);

        try partial.appendSlice(self.allocator, self.projectRoot);

        while (it.next()) |segment| {
            try partial.append(self.allocator, std.fs.path.sep);
            try partial.appendSlice(self.allocator, segment);

            const label = try self.allocator.dupeZ(u8, segment);
            defer self.allocator.free(label);

            if (EE3D.zgui.smallButton(label)) {
                const newPath = try self.allocator.dupe(u8, partial.items);
                defer self.allocator.free(newPath);
                if (!std.mem.eql(u8, newPath, self.currentPath))
                    try self.changeDir(newPath);
                return;
            }

            if (it.peek() != null) {
                EE3D.zgui.sameLine(.{});
                EE3D.zgui.text(">", .{});
                EE3D.zgui.sameLine(.{});
            }
        }

        EE3D.zgui.newLine();
    }

    pub fn changeProjectRoot(self: *AssetBrowser, path: []const u8) !void {
        self.allocator.free(self.projectRoot);
        const root = try self.allocator.dupe(u8, path);
        self.projectRoot = root;
    }

    pub fn changeDir(self: *AssetBrowser, path: []const u8) !void {
        for (self.entries.items) |entry| {
            self.allocator.free(entry.name);
        }
        self.entries.clearRetainingCapacity();

        self.allocator.free(self.currentPath);
        self.currentPath = try self.allocator.dupe(u8, path);

        var dir = try std.fs.openDirAbsolute(path, .{ .iterate = true });
        defer dir.close();

        var it = dir.iterate();
        while (try it.next()) |entry| {
            const nameCopy = try self.allocator.dupe(u8, entry.name);

            const assetType: AssetType = switch (entry.kind) {
                .directory => AssetType.Folder,
                .file => detectAssetType(entry.name),
                else => AssetType.GenericFile,
            };

            const entryPath = try std.fs.path.join(self.allocator, &[_][]const u8{ path, entry.name });
            const entryPathCopy = try self.allocator.dupe(u8, entryPath);

            try self.entries.append(self.allocator, .{ .name = nameCopy, .path = entryPathCopy, .assetType = assetType });
        }
    }

    pub fn deinit(self: *AssetBrowser) void {
        var iterator = self.icons.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.destroy();
        }

        self.allocator.free(self.currentPath);
        self.allocator.free(self.projectRoot);

        for (self.entries.items) |entry| {
            self.allocator.free(entry.name);
            self.allocator.free(entry.path);
        }
        self.entries.deinit(self.allocator);

        self.icons.deinit();
    }

    pub fn draw(self: *AssetBrowser) !void {
        if (EE3D.zgui.begin("Assets", .{})) {
            try drawBreadcrumbs(self);
            const availSpaceX = EE3D.zgui.getContentRegionAvail()[0];
            const icon_size = 100 + 3;
            const columns: i32 = @max(1, @as(i32, @intFromFloat(availSpaceX / icon_size)));

            var i: u32 = 0;
            if (EE3D.zgui.beginTable("AssetGrid", .{ .column = columns, .flags = .{ .resizable = true, .no_borders_in_body = true, .no_host_extend_x = true, .sizing = .stretch_same } })) {
                if (self.entries.items.len > 0) {
                    while (i < self.entries.items.len) : (i += 1) {
                        _ = EE3D.zgui.tableNextColumn();
                        EE3D.zgui.beginGroup();
                        const icon = self.icons.get(self.entries.items[i].assetType);
                        const tex_id: EE3D.zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(icon.?.id)));
                        const assetEntryId = try std.fmt.allocPrint(self.allocator, "AssetEntry.{d}", .{i});
                        const assetEntryIdC = try self.allocator.dupeZ(u8, assetEntryId);
                        defer {
                            self.allocator.free(assetEntryIdC);
                            self.allocator.free(assetEntryId);
                        }

                        if (EE3D.zgui.imageButton(
                            assetEntryIdC,
                            .{
                                .tex_data = null,
                                .tex_id = tex_id,
                            },
                            .{
                                .w = 100,
                                .h = 100,
                                .uv0 = [_]f32{ 0, 1 },
                                .uv1 = [_]f32{ 1, 0 },
                            },
                        )) {
                            if (self.entries.items[i].assetType == .Folder) {
                                try changeDir(self, self.entries.items[i].path);
                                EE3D.zgui.endGroup();
                                break;
                            }
                        }

                        EE3D.zgui.text("{s}", .{self.entries.items[i].name});

                        EE3D.zgui.endGroup();
                    }
                }
                EE3D.zgui.endTable();
            }
        }

        EE3D.zgui.end();
    }

    allocator: std.mem.Allocator,
    icons: std.AutoHashMap(AssetType, Texture),
    currentPath: []u8,
    projectRoot: []u8,
    entries: std.ArrayList(AssetBrowserEntry),
};

pub const AssetBrowserEntry = struct {
    name: []const u8,
    path: []const u8,
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
