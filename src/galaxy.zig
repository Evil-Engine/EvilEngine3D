const std = @import("std");
const SolarSystem = @import("solarSystem.zig").SolarSystem;
pub const GalaxyMagic: u32 = 0xEE3D01;

pub const Galaxy = struct {
    name: []const u8 = "NoName",
    systems: []SolarSystem,

    pub fn write(self: *Galaxy, file: *std.fs.File) !void {
        var magicBytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &magicBytes, GalaxyMagic, .little);
        try file.writeAll(&magicBytes);

        var nameLenBytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &nameLenBytes, @intCast(self.name.len), .little);
        try file.writeAll(&nameLenBytes);

        try file.writeAll(self.name);
    }

    pub fn read(file: *std.fs.File, allocator: std.mem.Allocator) !Galaxy {
        var magic_bytes: [4]u8 = undefined;
        const magic_read = try file.readAll(&magic_bytes);
        if (magic_read != 4) return error.ReadFailed;
        const magic = std.mem.readInt(u32, &magic_bytes, .little);
        if (magic != GalaxyMagic) {
            return error.InvalidProjectFile;
        }

        var nameLenBytes: [4]u8 = undefined;
        _ = try file.readAll(&nameLenBytes);
        const nameLen = std.mem.readInt(u32, &nameLenBytes, .little);

        const name = try allocator.alloc(u8, nameLen);
        errdefer allocator.free(name);
        _ = try file.readAll(name);

        return Galaxy{
            .name = name,
        };
    }
};
