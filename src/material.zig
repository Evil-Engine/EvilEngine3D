const std = @import("std");
const texture = @import("texture.zig").Texture;
const UniformValue = @import("uniformvalue.zig").UniformValue;

pub const Material = struct {
    uniforms: std.StringHashMap(UniformValue),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Material {
        return .{
            .uniforms = std.StringHashMap(UniformValue).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn set(self: *Material, name: []const u8, value: UniformValue) !void {
        const result = try self.uniforms.getOrPut(name);
        if (!result.found_existing) {
            result.key_ptr.* = try self.allocator.dupe(u8, name);
        }
        result.value_ptr.* = value;
    }

    pub fn deinit(self: *Material) void {
        var it = self.uniforms.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
        }
        self.uniforms.deinit();
    }
};
