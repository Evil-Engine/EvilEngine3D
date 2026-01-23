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
        var magic_bytes: [4]u8 = undefined;
        const magic_read = try file.readAll(&magic_bytes);
        if (magic_read != 4) return error.ReadFailed;
        const magic = std.mem.readInt(u32, &magic_bytes, .little);
        if (magic != ProjectMagic) {
            return error.InvalidProjectFile;
        }

        var nameLenBytes: [4]u8 = undefined;
        _ = try file.readAll(&nameLenBytes);
        const nameLen = std.mem.readInt(u32, &nameLenBytes, .little);

        const name = try allocator.alloc(u8, nameLen);
        errdefer allocator.free(name);
        _ = try file.readAll(name);

        var pathLenBytes: [4]u8 = undefined;
        _ = try file.readAll(&pathLenBytes);
        const pathLen = std.mem.readInt(u32, &pathLenBytes, .little);

        const path = try allocator.alloc(u8, pathLen);
        errdefer allocator.free(path);
        _ = try file.readAll(path);

        return Project{
            .name = name,
            .path = path,
        };
    }
};
