const std = @import("std");

pub fn Error(comptime msg: []const u8, args: anytype) !void {
    std.debug.print("\x1b[0;31m[Error] " ++ msg ++ "\x1b[0m\n", args);
}

pub fn Warn(comptime msg: []const u8, args: anytype) !void {
    std.debug.print("\x1b[0;33m[Warn] " ++ msg ++ "\x1b[0m\n", args);
}

pub fn Info(comptime msg: []const u8, args: anytype) !void {
    std.debug.print("[Info] " ++ msg ++ "\n", args);
}
