const cglm = @import("Bindings/c.zig").c;

pub const Vertex = struct {
    position: cglm.vec3 = [_]f32{ 0.0, 0.0, 0.0 },
    normal: cglm.vec3 = [_]f32{ 0.0, 0.0, 0.0 },
    UV: cglm.vec2 = [_]f32{ 0.0, 0.0 },
};
