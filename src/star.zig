const Planet = @import("planet.zig").Planet;

pub const Star = struct {
    name: []const u8,
    mass: f32,
    luminosity: f32,
    planets: []Planet,
};
