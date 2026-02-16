const std = @import("std");
const SolarSystem = @import("solarSystem.zig").SolarSystem;
pub const GalaxyMagic: u32 = 0xEE3D01;
pub const GalaxyVersion: u32 = 1;

pub const Galaxy = struct {
    name: []const u8 = "NoName",
    /// Good luck exploring 18,446,744,073,709,551,615 solar systems :P although more like 9,223,372,036,854,776,000
    systemCount: u64,
    systemOffsets: []u64,

    pub fn write(self: *Galaxy, file: *std.fs.File) !void {
        var writeBuf: [8]u8 = undefined;

        std.mem.writeInt(u32, writeBuf[0..4], GalaxyMagic, .little);
        try file.writeAll(writeBuf[0..4]);

        std.mem.writeInt(u32, writeBuf[0..4], GalaxyVersion, .little);
        try file.writeAll(writeBuf[0..4]);

        std.mem.writeInt(u32, writeBuf[0..4], @intCast(self.name.len), .little);
        try file.writeAll(writeBuf[0..4]);
        try file.writeAll(self.name);

        std.mem.writeInt(u64, &writeBuf, self.systemCount, .little);
        try file.writeAll(&writeBuf);
    }

    pub fn read(file: *std.fs.File, allocator: std.mem.Allocator) !Galaxy {
        var buf: [8]u8 = undefined;

        _ = try file.readAll(buf[0..4]);
        if (std.mem.readInt(u32, buf[0..4], .little) != GalaxyMagic)
            return error.InvalidGalaxyFile;

        _ = try file.readAll(buf[0..4]);
        const version = std.mem.readInt(u32, buf[0..4], .little);
        if (version != GalaxyMagic)
            return error.UnsupportedGalaxyVersion;

        _ = try file.readAll(buf[0..4]);
        const nameLen = std.mem.readInt(u32, buf[0..4], .little);

        const name = try allocator.alloc(u8, nameLen);
        errdefer allocator.free(name);
        _ = try file.readAll(name);

        _ = try file.readAll(&buf);
        const systemCount = std.mem.readInt(u64, &buf, .little);

        if (systemCount > 18_446_744_073_709_551_610) {
            return error.SystemCountTooLarge;
        }

        _ = try file.readAll(&buf);
        const systemTableOffset = std.mem.readInt(u64, &buf, .little);

        try file.seekTo(systemTableOffset);

        const offsets = try allocator.alloc(u64, systemCount);
        errdefer allocator.free(offsets);

        for (offsets) |*offset| {
            _ = try file.readAll(&buf);
            offset.* = std.mem.readInt(u64, &buf, .little);
        }

        return Galaxy{
            .name = name,
            .systemCount = systemCount,
            .systemOffsets = offsets,
        };
    }
};
