const std = @import("std");
const texture = @import("texture.zig").Texture;

pub const Material = struct {
    diffuse: texture,

    pub fn init(diffuse: texture) Material {
        return Material{ .diffuse = diffuse };
    }
};
