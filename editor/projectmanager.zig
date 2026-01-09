const EE3D = @import("EE3D");
const std = @import("std");
const gl = EE3D.zopengl.bindings;
const cglm = EE3D.cglm;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;
const nfd = EE3D.nfd;

pub const ProjectManager = struct {
    pub fn init(allocator: std.mem.Allocator) ProjectManager {
        return ProjectManager{ .allocator = allocator };
    }

    pub fn draw(self: *ProjectManager) !void {
        if (zgui.button("Create Project", .{})) {
            const project_path = try nfd.openFolderDialog(null);
            defer if (project_path) |p| nfd.freePath(p);

            if (project_path) |path| {
                const projectPath = try std.fs.path.join(self.allocator, &[_][]const u8{ path, "project.EEProj" });
                defer self.allocator.free(projectPath);
                const projectFile = try std.fs.cwd().createFile(projectPath, .{});
                defer projectFile.close();
                zgui.closeCurrentPopup();
            } else {
                try EE3D.logging.Error("Please select a path", .{});
                zgui.closeCurrentPopup();
            }
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
    }

    allocator: std.mem.Allocator,
};
