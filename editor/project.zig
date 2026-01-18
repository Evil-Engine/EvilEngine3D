const std = @import("std");
pub const ProjectMagic: u32 = 0xEE3D02;

pub const Project = struct {
    name: []const u8 = "NoName",
    path: []const u8 = "NoPath",

    pub fn write(self: *Project, writer: *std.Io.Writer) !void {
        try writer.writeInt(u32, ProjectMagic, .little);

        try writer.writeInt(usize, self.name.len, .little);
        try writer.writeAll(self.name);

        try writer.writeInt(usize, self.path.len, .little);
        try writer.writeAll(self.path);

        try writer.flush();
    }

    pub fn read(reader: *std.Io.Reader, allocator: std.mem.Allocator) !Project {
        const magic = try reader.readSliceEndianAlloc(allocator, u32, 1, .little);
        if (magic[0] != ProjectMagic) return error.BadMagic;
    }
};
