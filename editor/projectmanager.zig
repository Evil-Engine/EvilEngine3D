const EE3D = @import("EE3D");
const std = @import("std");
const gl = EE3D.zopengl.bindings;
const cglm = EE3D.cglm;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;
const nfd = EE3D.nfd;

pub const ProjectManager = struct {
    pub fn init() ProjectManager {
        return ProjectManager{};
    }

    pub fn draw(self: *ProjectManager) !void {
        _ = self;
        if (zgui.button("Create Project", .{})) {
            const project_path = try nfd.saveFileDialog("EEProj", null);
            defer if (project_path) |p| nfd.freePath(p);
        }
        if (zgui.button("Open Project", .{})) {
            const project_path = try nfd.openFileDialog("EEProj", null);
            defer if (project_path) |p| nfd.freePath(p);
        }
        if (zgui.button("Close", .{})) {
            zgui.closeCurrentPopup();
        }
    }
};
