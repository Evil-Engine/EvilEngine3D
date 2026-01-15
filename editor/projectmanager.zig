const EE3D = @import("EE3D");
const std = @import("std");
const json = std.json;
const ProjectData = @import("projectdata.zig");
const gl = EE3D.zopengl.bindings;
const cglm = EE3D.cglm;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;
const nfd = EE3D.nfd;

pub const ProjectManager = struct {
    pub fn init(allocator: std.mem.Allocator) !ProjectManager {
        const projName: [:0]u8 = try allocator.allocSentinel(u8, 64, 0);
        @memset(projName, 0);
        return ProjectManager{ .allocator = allocator, .currentMenuState = .Main, .currentState = ProjectManagerState{ .currentCreateProjectName = projName } };
    }

    pub fn deinit(self: *ProjectManager) void {
        if (self.currentState.selectedCreateProjectPath) |path| {
            self.allocator.free(path);
        }
        if (self.currentProject) |proj| {
            self.allocator.free(proj.name);
        }
        self.allocator.free(self.currentState.currentCreateProjectName);
    }

    pub fn draw(self: *ProjectManager) !void {
        switch (self.currentMenuState) {
            .Main => {
                if (zgui.button("Create Project", .{})) {
                    self.currentMenuState = .CreateProject;
                }
                if (zgui.button("Open Project", .{})) {
                    const project_path = try nfd.openFileDialog("EEProj", null);
                    defer if (project_path) |p| nfd.freePath(p);

                    if (project_path) |path| {
                        _ = path;
                        zgui.closeCurrentPopup();
                    } else {
                        try EE3D.logging.Error("Please select a path", .{});
                        zgui.closeCurrentPopup();
                    }
                }
                if (zgui.button("Close", .{})) {
                    zgui.closeCurrentPopup();
                }
            },
            .CreateProject => {
                if (self.currentState.selectedCreateProjectPath) |p| {
                    zgui.text("Selected Path: {s}", .{p});
                } else {
                    zgui.text("Please select a path.", .{});
                }
                if (zgui.button("Select Project Path", .{})) {
                    const project_path = try nfd.openFolderDialog(null);
                    defer if (project_path) |p| nfd.freePath(p);
                    if (project_path) |p| {
                        const projectPathDuped = try self.allocator.dupe(u8, p);
                        self.currentState.selectedCreateProjectPath = projectPathDuped;

                        const newName = std.fs.path.basename(projectPathDuped);
                        const copyLen: usize = newName.len;
                        std.mem.copyForwards(u8, self.currentState.currentCreateProjectName[0..copyLen], newName);
                        self.currentState.currentCreateProjectName[copyLen] = 0;
                    } else {
                        try EE3D.logging.Error("Please select a path", .{});
                        self.currentState.currentCreateProjectError = "Path is invalid";
                        self.currentState.selectedCreateProjectPath = null;
                    }
                }
                _ = zgui.inputText("Project Name", .{
                    .buf = self.currentState.currentCreateProjectName,
                });

                zgui.pushStyleColor4f(.{ .c = EE3D.ui.rgba1(231, 130, 132, 255), .idx = .text });
                zgui.text("{s}", .{self.currentState.currentCreateProjectError});
                zgui.popStyleColor(.{ .count = 1 });
                if (zgui.button("Create", .{})) {
                    if (self.currentState.selectedCreateProjectPath == null) {
                        self.currentState.currentCreateProjectError = "Select a path before trying to create a project";
                    } else {
                        try createDefaultProjectAtCurrentPath(self);
                    }
                }

                if (zgui.button("Back", .{})) {
                    self.currentMenuState = .Main;
                }
            },
        }
    }

    /// God will not forgive me for this function :P
    fn createDefaultProjectAtCurrentPath(self: *ProjectManager) !void {
        var buffer: [4096]u8 = undefined;
        var writer: std.Io.Writer = .fixed(&buffer);

        const nameLen = std.mem.indexOf(u8, self.currentState.currentCreateProjectName, &[_]u8{0}) orelse self.currentState.currentCreateProjectName.len;
        const nameSlice = self.currentState.currentCreateProjectName[0..nameLen];

        const copiedName: []u8 = try self.allocator.alloc(u8, nameSlice.len);

        // this is here because of the double deinit issue thingy
        std.mem.copyForwards(u8, copiedName, nameSlice);

        const newProj = ProjectData.ProjectData{ .name = copiedName, .path = self.currentState.selectedCreateProjectPath.? };

        try json.Stringify.value(newProj, .{ .whitespace = .indent_3 }, &writer);

        const projFilePath = try std.fs.path.join(self.allocator, &[_][]const u8{ self.currentState.selectedCreateProjectPath.?, "project.EEProj" });
        defer self.allocator.free(projFilePath);

        const projFile = try std.fs.cwd().createFile(projFilePath, .{});
        defer projFile.close();

        try projFile.writeAll(writer.buffered());

        self.currentProject = newProj;

        const assetsDirPath = try std.fs.path.join(self.allocator, &[_][]const u8{ self.currentState.selectedCreateProjectPath.?, "Assets" });
        defer self.allocator.free(assetsDirPath);

        std.fs.cwd().makeDir(assetsDirPath) catch |err| {
            switch (err) {
                std.posix.MakeDirError.PathAlreadyExists, std.posix.MakeDirError.AccessDenied => {
                    try EE3D.logging.Error("Failed to make dir at: {s} because: {s}", .{ assetsDirPath, @errorName(err) });
                },
                else => {
                    try EE3D.logging.Error("Failed to make dir at: {s} because: {s}, And is considered unhandleable by the engine.", .{ assetsDirPath, @errorName(err) });
                    return error.UnhandleableError;
                },
            }
        };
    }

    allocator: std.mem.Allocator,
    currentMenuState: ProjectManagerMenuState,
    currentState: ProjectManagerState,
    currentProject: ?ProjectData.ProjectData = null,
};

pub const ProjectManagerMenuState = enum(u32) {
    Main = 0,
    CreateProject,
};

pub const ProjectManagerState = struct {
    selectedCreateProjectPath: ?[]const u8 = null,
    currentCreateProjectError: []const u8 = "",
    currentCreateProjectName: [:0]u8 = undefined,
};
