const std = @import("std");
const zopengl = @import("zopengl");
const Shader = @import("shader.zig");
const Window = @import("window.zig");
const gl = zopengl.bindings;
const cglm = @import("Bindings/c.zig").c;
pub const glfw = @import("zglfw");

pub const Camera = struct {
    pub fn init(window: *Window.Window, position: cglm.vec3) Camera {
        const camMatrix: cglm.mat4 = undefined;
        return Camera{ .orientation = [_]f32{ 0.0, 0.0, -1.0 }, .camMatrix = camMatrix, .window = window, .up = [_]f32{ 0.0, 1.0, 0.0 }, .position = position };
    }

    pub fn updateMatrix(self: *Camera, fovDeg: f32, nearPlane: f32, farPlane: f32) void {
        var view: cglm.mat4 = undefined;
        var projection: cglm.mat4 = undefined;

        cglm.glmc_mat4_identity(&view);
        cglm.glmc_mat4_identity(&projection);

        var center: cglm.vec3 = undefined;

        cglm.glm_vec3_add(&self.position[0], &self.orientation[0], &center);

        cglm.glmc_lookat(&self.position[0], &center[0], &self.up[0], &view);
        cglm.glmc_perspective(cglm.glm_rad(fovDeg), @as(f32, @floatFromInt(@divFloor(self.window.width, self.window.height))), nearPlane, farPlane, &projection[0]);

        cglm.glmc_mat4_mul(&projection[0], &view[0], &self.camMatrix[0]);
    }

    pub fn matrix(self: *Camera, shader: *Shader.Shader, uniform: []const u8) void {
        gl.uniformMatrix4fv(gl.getUniformLocation(shader.id, uniform.ptr), 1, gl.FALSE, &self.camMatrix[0][0]);
    }

    window: *Window.Window,
    position: cglm.vec3,
    orientation: cglm.vec3,
    up: cglm.vec3,
    camMatrix: cglm.mat4,
};
