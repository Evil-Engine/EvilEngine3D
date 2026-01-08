const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const ProjectManager = @import("projectmanager.zig").ProjectManager;
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const FrameBuffer = EE3D.FrameBuffer.FrameBuffer;
const Window = EE3D.window.Window;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;

pub var isHovered: bool = false;

/// Same as isSelected
pub var isFocused: bool = false;

pub const Viewport = struct {
    pub fn init(window: *Window, projectManager: *ProjectManager) Viewport {
        const windowSize = window.getSize();
        const viewportSize = [2]f32{ @floatFromInt(window.getSize().width), @floatFromInt(window.getSize().height) };
        const viewportBuffer: FrameBuffer = FrameBuffer.init(@intCast(windowSize.width), @intCast(windowSize.height));

        return Viewport{
            .window = window,
            .viewportBuffer = viewportBuffer,
            .viewportSize = viewportSize,
            .viewportPos = [2]f32{ 0.0, 0.0 },
            .projectManager = projectManager,
        };
    }

    pub fn deinit(self: *Viewport) void {
        self.viewportBuffer.deinit();
    }

    pub fn startRender(self: *Viewport) void {
        self.viewportBuffer.bind();
    }

    pub fn endRender(self: *Viewport) void {
        self.viewportBuffer.unBind();
    }

    pub fn renderUI(self: *Viewport) !void {
        if (zgui.begin("Viewport", .{ .flags = .{ ._padding = 0 } })) {
            const width = zgui.getContentRegionAvail()[0];
            const height = zgui.getContentRegionAvail()[1];
            self.viewportPos = zgui.getItemRectMin();
            self.viewportSize = [2]f32{ width, height };
            const warningText = "No project loaded.";

            zgui.pushFont(EE3D.ui.bigFont, 48);
            const textSize = zgui.calcTextSize(warningText, .{});

            const posX = (width * 0.5 - textSize[0] * 0.5) - 12;
            const posY = (height * 0.5 - textSize[1] * 0.5) - 12;

            zgui.setCursorPos(.{ posX, posY });
            zgui.text(warningText, .{});

            const buttonText = "Project Manager";
            const buttonTextSize = zgui.calcTextSize(buttonText, .{});

            const buttonPaddingX = 20;
            const buttonWidth = buttonTextSize[0] + buttonPaddingX * 2;
            //const buttonHeight = buttonTextSize[1] * 2;

            const buttonPosX = width * 0.5 - buttonWidth * 0.5;
            const buttonPosY = posY + buttonTextSize[1] + 24;

            zgui.setCursorPos([_]f32{ buttonPosX, buttonPosY });
            if (zgui.button("Project Manager", .{})) {
                zgui.openPopup("Project Manager", .{});
            }
            zgui.popFont();

            if (zgui.beginPopupModal("Project Manager", .{})) {
                try self.projectManager.draw();
                zgui.endPopup();
            }

            //gl.viewport(0, 0, @intFromFloat(width), @intFromFloat(height));
            //
            //const tex_id: zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(self.viewportBuffer.texture)));
            //gl.activeTexture(gl.TEXTURE0);
            //gl.bindTexture(gl.TEXTURE_2D, self.viewportBuffer.texture);
            //self.viewportBuffer.resizeFrameBuffer(@intFromFloat(width), @intFromFloat(height));
            //zgui.image(.{ .tex_data = null, .tex_id = tex_id }, .{ .w = width, .h = height, .uv0 = [_]f32{ 0, 1 }, .uv1 = [_]f32{ 1, 0 } });
            //isFocused = zgui.isItemFocused();
            //isHovered = zgui.isItemHovered(.{});
        }
        zgui.end();
    }

    window: *Window,
    viewportSize: [2]f32,
    viewportPos: [2]f32,
    viewportBuffer: FrameBuffer,
    projectManager: *ProjectManager,
};
