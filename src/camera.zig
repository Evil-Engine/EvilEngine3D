const std = @import("std");
const zopengl = @import("zopengl");
const Shader = @import("shader.zig");
const Window = @import("window.zig");
const gl = zopengl.bindings;
const cglm = @import("Bindings/c.zig").c;
pub const glfw = @import("zglfw");

pub const Camera = struct {
    pub fn init(width: i64, height: i64, position: cglm.vec3) Camera {
        const camMatrix: cglm.mat4 = undefined;
        return Camera{ .speed = 0.1, .orientation = [_]f32{ 0.0, 0.0, -1.0 }, .camMatrix = camMatrix, .firstClick = true, .up = [_]f32{ 0.0, 1.0, 0.0 }, .sensitivity = 100.0, .width = width, .height = height, .position = position };
    }

    pub fn updateMatrix(self: *Camera, fovDeg: f32, nearPlane: f32, farPlane: f32) void {
        var view: cglm.mat4 = undefined;
        var projection: cglm.mat4 = undefined;

        cglm.glmc_mat4_identity(&view);
        cglm.glmc_mat4_identity(&projection);

        var center: cglm.vec3 = undefined;

        cglm.glm_vec3_add(&self.position[0], &self.orientation[0], &center);

        cglm.glmc_lookat(&self.position[0], &center[0], &self.up[0], &view);
        cglm.glmc_perspective(cglm.glm_rad(fovDeg), @as(f32, @floatFromInt(@divFloor(self.width, self.height))), nearPlane, farPlane, &projection[0]);

        cglm.glmc_mat4_mul(&projection[0], &view[0], &self.camMatrix[0]);
    }

    pub fn matrix(self: *Camera, shader: *Shader.Shader, uniform: []const u8) void {
        gl.uniformMatrix4fv(gl.getUniformLocation(shader.id, uniform.ptr), 1, gl.FALSE, &self.camMatrix[0][0]);
    }

    pub fn inputs(self: *Camera, window: *Window.Window) !void {
        var right: cglm.vec3 = undefined;
        var tmp: cglm.vec3 = undefined;

        cglm.glmc_vec3_cross(&self.orientation[0], &self.up[0], &right[0]);
        cglm.glmc_vec3_normalize(&right[0]);

        if (glfw.getKey(window.rawWindow, glfw.Key.w) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&self.orientation[0], self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }
        if (glfw.getKey(window.rawWindow, glfw.Key.a) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&right[0], -self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }
        if (glfw.getKey(window.rawWindow, glfw.Key.s) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&self.orientation[0], -self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }
        if (glfw.getKey(window.rawWindow, glfw.Key.d) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&right[0], self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }

        if (glfw.getKey(window.rawWindow, glfw.Key.space) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&self.up[0], self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }

        if (glfw.getKey(window.rawWindow, glfw.Key.left_control) == glfw.Action.press) {
            cglm.glmc_vec3_scale(&self.up[0], -self.speed, &tmp[0]);
            cglm.glmc_vec3_add(&self.position[0], &tmp[0], &self.position[0]);
        }

        if (glfw.getKey(window.rawWindow, glfw.Key.left_shift) == glfw.Action.press) {
            self.speed = 0.4;
        } else {
            self.speed = 0.1;
        }

        if (glfw.getMouseButton(window.rawWindow, glfw.MouseButton.left) == glfw.Action.press) {
            try glfw.setInputMode(window.rawWindow, glfw.InputMode.cursor, glfw.Cursor.Mode.hidden);

            if (self.firstClick) {
                glfw.setCursorPos(window.rawWindow, @floatFromInt(@divFloor(self.width, 2)), @floatFromInt(@divFloor(self.height, 2)));
                self.firstClick = false;
            }

            var mouseX: f64 = 0.0;
            var mouseY: f64 = 0.0;
            glfw.getCursorPos(window.rawWindow, &mouseX, &mouseY);

            const centerX = @as(f64, @floatFromInt(self.width)) / 2.0;
            const centerY = @as(f64, @floatFromInt(self.height)) / 2.0;

            const deltaX = mouseX - centerX;
            const deltaY = centerY - mouseY;

            const rotX = @as(f32, @floatCast(deltaY)) * self.sensitivity * 0.001;
            const rotY = @as(f32, @floatCast(deltaX)) * self.sensitivity * 0.001;

            cglm.glmc_vec3_cross(&self.orientation[0], &self.up[0], &right[0]);
            cglm.glmc_vec3_normalize(&right[0]);

            cglm.glmc_vec3_rotate(
                &self.orientation[0],
                cglm.glm_rad(rotX),
                &right[0],
            );

            if (cglm.glmc_vec3_angle(&self.orientation[0], &self.up[0]) <= cglm.glm_rad(5.0) or
                cglm.glmc_vec3_angle(&self.orientation[0], &self.up[0]) >= cglm.glm_rad(175.0))
            {
                cglm.glmc_vec3_rotate(
                    &self.orientation[0],
                    cglm.glm_rad(-rotX),
                    &right[0],
                );
            }

            cglm.glmc_vec3_rotate(
                &self.orientation[0],
                cglm.glm_rad(-rotY),
                &self.up[0],
            );

            cglm.glmc_vec3_normalize(&self.orientation[0]);

            glfw.setCursorPos(
                window.rawWindow,
                @floatFromInt(@divFloor(self.width, 2)),
                @floatFromInt(@divFloor(self.height, 2)),
            );
        } else if (glfw.getMouseButton(window.rawWindow, glfw.MouseButton.left) == glfw.Action.release) {
            try glfw.setInputMode(window.rawWindow, glfw.InputMode.cursor, glfw.Cursor.Mode.normal);
            self.firstClick = true;
        }
    }

    width: i64,
    height: i64,
    speed: f32,
    sensitivity: f32,
    position: cglm.vec3,
    orientation: cglm.vec3,
    up: cglm.vec3,
    firstClick: bool,
    camMatrix: cglm.mat4,
};
