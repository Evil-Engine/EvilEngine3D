const std = @import("std");
pub const GalaxyMagic: u32 = 0xEE3D01;

/// A Galaxy in EE3D is a file that holds SolarSystems, A game can have 1 Galaxy max.
/// Future versions plan to group Galaxys in a Universe which will become the highest level instead.
const Galaxy = packed struct {
    /// Erm dont change this :P
    version: u32 = 1,

    pub fn write(self: *Galaxy, writer: std.io.Writer) !void {
        try writer.writeInt(u32, GalaxyMagic, .little);
        try writer.writeInt(u32, self.version, .little);
    }

    pub fn read(reader: std.io.Reader) !Galaxy {
        var magic: u32 = undefined;
        try reader.readSliceEndian(u32, &magic, .little);

        if (magic != GalaxyMagic) return error.BadMagic;

        var version: u32 = undefined;
        try reader.readSliceEndian(u32, &version, .little);

        return Galaxy{
            .version = version,
        };
    }
};
