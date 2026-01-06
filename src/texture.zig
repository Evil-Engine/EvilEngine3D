const zopengl = @import("zopengl");
const application = @import("application.zig");
const shader = @import("shader.zig");
const gl = zopengl.bindings;
const std = @import("std");
const zigstbi = @import("zigstbi");

pub const Texture = struct {
    pub fn init(allocator: std.mem.Allocator, image: []const u8, texType: gl.Enum, slot: gl.Enum, format: gl.Enum, pixelType: gl.Enum) !Texture {
        var id: gl.Uint = 0;

        zigstbi.set_flip_vertically_on_load(true);

        const imageNullTermed = try allocator.dupeZ(u8, image);
        defer allocator.free(imageNullTermed);
        var stbImage = try zigstbi.load_file(image, 0);
        defer stbImage.deinit();

        gl.genTextures(1, &id);
        gl.activeTexture(slot);
        gl.bindTexture(texType, id);

        gl.texParameteri(texType, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR);
        gl.texParameteri(texType, gl.TEXTURE_MAG_FILTER, gl.NEAREST);

        gl.texParameteri(texType, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.texParameteri(texType, gl.TEXTURE_WRAP_T, gl.REPEAT);

        gl.texImage2D(texType, 0, gl.RGBA, @intCast(stbImage.width), @intCast(stbImage.height), 0, format, pixelType, stbImage.bytes.ptr);

        gl.generateMipmap(texType);

        gl.bindTexture(texType, 0);

        return Texture{ .texType = texType, .allocator = allocator, .id = id };
    }

    pub fn texUnit(self: *Texture, Shader: *shader.Shader, uniform: []const u8, unit: gl.Int) !void {
        const uniformZ = try self.allocator.dupeZ(u8, uniform);
        defer self.allocator.free(uniformZ);
        const texUni = gl.getUniformLocation(Shader.id, uniformZ.ptr);
        Shader.activate();
        gl.uniform1i(texUni, unit);
    }

    pub fn bind(self: *Texture) void {
        gl.bindTexture(self.texType, self.id);
    }

    pub fn unBind(self: *Texture) void {
        gl.bindTexture(self.texType, 0);
    }

    pub fn destroy(self: *Texture) void {
        gl.deleteTextures(1, &self.id);
    }

    texType: gl.Enum,
    allocator: std.mem.Allocator,
    id: gl.Uint,
};
