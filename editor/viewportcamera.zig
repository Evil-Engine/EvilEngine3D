const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const Viewport = @import("viewport.zig");
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const glfw = EE3D.glfw;
const FrameBuffer = EE3D.FrameBuffer.FrameBuffer;
const Window = EE3D.window.Window;
const Texture = EE3D.texture.Texture;
const UI = EE3D.ui.UI;
const zgui = EE3D.zgui;

pub const ViewportCamera = struct {
    pub fn init(Camera: *camera.Camera, window: *Window, viewport: Viewport.Viewport) ViewportCamera {
        return ViewportCamera{
            .Camera = Camera,
            .window = window,
            .viewport = viewport,
        };
    }

    pub fn input(self: *ViewportCamera, deltaTime: f32) !void {
        if (!Viewport.isHovered and !self.moving) {
            return;
        }
        if (glfw.getMouseButton(self.window.rawWindow, glfw.MouseButton.left) != glfw.Action.press) {
            self.firstClick = true;
            try glfw.setInputMode(self.window.rawWindow, glfw.InputMode.cursor, glfw.Cursor.Mode.normal);
            self.moving = false;
            return;
        }
        self.moving = true;

        // so i dont have to type self.Camera everytime
        var cam = self.Camera;
        var right: cglm.vec3 = undefined;
        cglm.glmc_vec3_cross(&cam.orientation[0], &cam.up[0], &right[0]);
        cglm.glmc_vec3_normalize(&right[0]);

        var move: cglm.vec3 = [_]f32{ 0, 0, 0 };

        if (glfw.getKey(self.window.rawWindow, glfw.Key.w) == glfw.Action.press) {
            cglm.glmc_vec3_add(&move, &cam.orientation[0], &move);
        }
        if (glfw.getKey(self.window.rawWindow, glfw.Key.s) == glfw.Action.press) {
            cglm.glmc_vec3_sub(&move, &cam.orientation[0], &move);
        }
        if (glfw.getKey(self.window.rawWindow, glfw.Key.d) == glfw.Action.press) {
            cglm.glmc_vec3_add(&move, &right[0], &move);
        }
        if (glfw.getKey(self.window.rawWindow, glfw.Key.a) == glfw.Action.press) {
            cglm.glmc_vec3_sub(&move, &right[0], &move);
        }
        if (glfw.getKey(self.window.rawWindow, glfw.Key.space) == glfw.Action.press) {
            cglm.glmc_vec3_add(&move, &cam.up[0], &move);
        }
        if (glfw.getKey(self.window.rawWindow, glfw.Key.left_control) == glfw.Action.press) {
            cglm.glmc_vec3_sub(&move, &cam.up[0], &move);
        }

        const norm = cglm.glmc_vec3_norm(&move);
        if (norm > 0) {
            cglm.glmc_vec3_normalize(&move);
            cglm.glmc_vec3_scale(&move, self.speed * deltaTime, &move);
            cglm.glmc_vec3_add(&cam.position[0], &move[0], &cam.position[0]);
        }

        try glfw.setInputMode(self.window.rawWindow, glfw.InputMode.cursor, glfw.Cursor.Mode.disabled);

        var mouseX: f64 = 0.0;
        var mouseY: f64 = 0.0;
        glfw.getCursorPos(self.window.rawWindow, &mouseX, &mouseY);

        const centerX = @as(f64, @floatCast(self.viewport.viewportPos[0] + self.viewport.viewportSize[0])) / 2.0;
        const centerY = @as(f64, @floatCast(self.viewport.viewportPos[1] + self.viewport.viewportSize[1])) / 2.0;
        if (self.firstClick == true) {
            self.firstClick = false;
            self.prevMouseX = mouseX;
            self.prevMouseY = mouseY;
            glfw.setCursorPos(self.window.rawWindow, centerX, centerY);
            return;
        }

        const deltaX = mouseX - centerX;
        const deltaY = centerY - mouseY;
        self.prevMouseX = mouseX;
        self.prevMouseY = mouseY;

        const rotY = @as(f32, @floatCast(deltaX)) * self.sensitivity * 0.001;
        const rotX = @as(f32, @floatCast(deltaY)) * self.sensitivity * 0.001;

        cglm.glmc_vec3_rotate(&cam.orientation[0], cglm.glm_rad(rotX), &right[0]);

        const pitch = cglm.glmc_vec3_angle(&cam.orientation[0], &cam.up[0]);

        if (pitch <= cglm.glm_rad(5.0) or pitch >= cglm.glm_rad(175.0)) {
            cglm.glmc_vec3_rotate(&cam.orientation[0], cglm.glm_rad(-rotX), &right[0]);
        }

        cglm.glmc_vec3_rotate(&cam.orientation[0], cglm.glm_rad(-rotY), &cam.up[0]);
        cglm.glmc_vec3_normalize(&cam.orientation[0]);
        glfw.setCursorPos(self.window.rawWindow, centerX, centerY);
        self.prevMouseX = centerX;
        self.prevMouseY = centerY;
    }

    speed: f32 = 0.1,
    sensitivity: f32 = 100.0,
    firstClick: bool = true,
    moving: bool = false,
    prevMouseX: f64 = 0.0,
    prevMouseY: f64 = 0.0,
    Camera: *camera.Camera,
    window: *Window,
    viewport: Viewport.Viewport,
};
