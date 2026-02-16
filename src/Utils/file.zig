const std = @import("std");
const logging = @import("logging.zig");

// https://ziggit.dev/t/the-zig-way-to-read-a-file/4663/8
// evil code thief

/// Call allocator.free on the output, PLEASE!!!
/// May deprecate soon.
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

pub fn readInt(comptime T: type, file: *std.fs.File) !T {
    var buf: [@sizeOf(T)]u8 = undefined;
    _ = try file.readAll(&buf);
    return std.mem.readInt(T, &buf, .little);
}

pub fn readSlice(file: *std.fs.File, allocator: std.mem.Allocator) ![]u8 {
    const len = try readInt(u32, file);
    if (len > 1024 * 1024) return error.SliceTooLong;

    const buf = try allocator.alloc(u8, len);
    errdefer allocator.free(buf);
    _ = try file.readAll(buf);
    return buf;
}

pub fn writeInt(comptime T: type, file: *std.fs.File, value: T) !void {
    var buf: [@sizeOf(T)]u8 = undefined;
    std.mem.writeInt(T, &buf, value, .little);
    try file.writeAll(&buf);
}

pub fn writeSlice(file: *std.fs.File, slice: []const u8) !void {
    try writeInt(u32, file, @intCast(slice.len));
    try file.writeAll(slice);
}
