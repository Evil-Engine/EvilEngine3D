const std = @import("std");
const EE3D = @import("EE3D");
pub const ProjectMagic: u32 = 0xEE3D02;

pub const Project = struct {
    name: []const u8 = "NoName",
    path: []const u8 = "NoPath",

    pub fn write(self: *Project, file: *std.fs.File) !void {
        var magicBytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &magicBytes, ProjectMagic, .little);
        try file.writeAll(&magicBytes);

        var nameLenBytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &nameLenBytes, @intCast(self.name.len), .little);
        try file.writeAll(&nameLenBytes);

        try file.writeAll(self.name);

        var pathLenBytes: [4]u8 = undefined;
        std.mem.writeInt(u32, &pathLenBytes, @intCast(self.path.len), .little);
        try file.writeAll(&pathLenBytes);

        try file.writeAll(self.path);
    }

    pub fn read(file: *std.fs.File, allocator: std.mem.Allocator) !Project {
        var buffer: [4096]u8 = undefined;
        var reader = file.reader(&buffer).interface;

        var magic_bytes: [4]u8 = undefined;
        try reader.readSliceAll(&magic_bytes);
        const magic = std.mem.readInt(u32, &magic_bytes, .little);
        std.debug.print("Magic: 0x{X}\n", .{magic});
        if (magic != ProjectMagic) {
            return error.InvalidProjectValue;
        }

        var nameLenBytes: [4]u8 = undefined;
        try reader.readSliceAll(&nameLenBytes);
        const nameLen = std.mem.readInt(u32, &nameLenBytes, .little);

        const name = try reader.readAlloc(allocator, nameLen);
        errdefer allocator.free(name);

        var pathLenBytes: [4]u8 = undefined;
        try reader.readSliceAll(&pathLenBytes);
        const pathLen = std.mem.readInt(u32, &pathLenBytes, .little);

        const path = try reader.readAlloc(allocator, pathLen);
        errdefer allocator.free(path);

        return Project{
            .name = name,
            .path = path,
        };
    }
};
