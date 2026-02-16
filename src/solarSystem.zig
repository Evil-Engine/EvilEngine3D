const std = @import("std");
const Star = @import("star.zig").Star;
const fileUtil = @import("utils/file.zig");
const SystemMagic: u32 = 0xEE3D03;

pub const SolarSystem = struct {
    name: []const u8,
    stars: []Star,

    pub fn writeSystem(sys: *const SolarSystem, file: *std.fs.File) !void {
        try fileUtil.writeInt(u32, file, SystemMagic);
        try fileUtil.writeInt(u32, file, 1);

        try fileUtil.writeSlice(file, sys.name);
    }
};
