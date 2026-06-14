const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const texture = @import("texture.zig").Texture;
const c = @import("Bindings/c.zig").c;

pub const UniformValue = union(enum) {
    int: i32,
    float: f32,
    vec2: c.vec2,
    vec3: c.vec3,
    vec4: c.vec4,
    mat3: c.mat3,
    mat4: c.mat4,
    texture: texture,

    pub fn upload(self: UniformValue, location: gl.Int, textureSlot: u32) void {
        switch (self) {
            .int => |v| gl.uniform1i(location, v),
            .float => |v| gl.uniform1f(location, v),
            .vec2 => |v| gl.uniform2fv(location, 1, &v[0]),
            .vec3 => |v| gl.uniform3fv(location, 1, &v[0]),
            .vec4 => |v| gl.uniform4fv(location, 1, &v[0]),
            .mat3 => |v| gl.uniformMatrix3fv(location, 1, gl.FALSE, &v[0][0]),
            .mat4 => |v| gl.uniformMatrix4fv(location, 1, gl.FALSE, &v[0][0]),
            .texture => |v| {
                gl.activeTexture(gl.TEXTURE0 + textureSlot);
                v.bind();
                gl.uniform1i(location, @intCast(textureSlot));
            },
        }
    }
};
