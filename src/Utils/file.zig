const std = @import("std");
const logging = @import("logging.zig");

// https://ziggit.dev/t/the-zig-way-to-read-a-file/4663/8
// evil code thief

/// Call allocator.free on the output, PLEASE!!!
pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        try logging.Error("Could not open file at path: {s}, with reason: {s}", .{ path, @errorName(err) });
        return err;
    };
    const stat = try file.stat();
    const size = stat.size;
    defer file.close();

    try logging.Info("Reading at path: {s}", .{path});

    if (size > std.math.maxInt(usize)) {
        try logging.Error("File at path: {s}, Is too large.", .{path});
        return error.FileTooLarge;
    }

    const buf = try allocator.alloc(u8, size);
    _ = try file.read(buf);

    return buf;
}
