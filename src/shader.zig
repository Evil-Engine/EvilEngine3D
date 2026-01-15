const file = @import("Utils/file.zig");
const logging = @import("Utils/logging.zig");
const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const Shader = struct {
    pub fn init(allocator: std.mem.Allocator, vertexFile: []const u8, fragmentFile: []const u8) !Shader {
        const vertCode = try file.readFile(allocator, vertexFile);
        defer allocator.free(vertCode);
        const fragCode = try file.readFile(allocator, fragmentFile);
        defer allocator.free(fragCode);

        const vertCodePtr: [*c]const u8 = vertCode.ptr;
        const vertLen: gl.Int = @intCast(vertCode.len);

        const fragCodePtr: [*c]const u8 = fragCode.ptr;
        const fragLen: gl.Int = @intCast(fragCode.len);

        const vertexShader: gl.Uint = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vertexShader, 1, &vertCodePtr, &vertLen);
        gl.compileShader(vertexShader);
        try checkForCompileErrors(vertexShader, .VERTEX);

        const fragmentShader: gl.Uint = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragmentShader, 1, &fragCodePtr, &fragLen);
        gl.compileShader(fragmentShader);
        try checkForCompileErrors(fragmentShader, .FRAGMENT);

        const id = gl.createProgram();
        gl.attachShader(id, vertexShader);
        gl.attachShader(id, fragmentShader);

        gl.linkProgram(id);
        try checkForCompileErrors(id, .PROGRAM);

        gl.deleteShader(vertexShader);
        gl.deleteShader(fragmentShader);

        return Shader{ .id = id };
    }

    pub fn activate(self: *Shader) void {
        gl.useProgram(self.id);
    }

    pub fn destroy(self: *Shader) void {
        gl.deleteProgram(self.id);
    }

    id: gl.Uint,
};

fn checkForCompileErrors(shader: gl.Uint, shaderType: ShaderType) !void {
    var successfulCompile: gl.Int = gl.FALSE;
    var log: [1024]u8 = undefined;
    if (shaderType != .PROGRAM) {
        gl.getShaderiv(shader, gl.COMPILE_STATUS, &successfulCompile);
        if (successfulCompile == gl.FALSE) {
            gl.getShaderInfoLog(shader, 1024, null, &log);
            try logging.Error("EE3D Shader compile error for type: {d},\n\nInfo:\n{s}\n", .{ @intFromEnum(shaderType), log });
        }
    } else {
        gl.getProgramiv(shader, gl.LINK_STATUS, &successfulCompile);
        if (successfulCompile == gl.FALSE) {
            gl.getProgramInfoLog(shader, 1024, null, &log);
            try logging.Error("EE3D Shader link error for type: {d},\n\nInfo:\n{s}\n", .{ @intFromEnum(shaderType), log });
        }
    }
}

const ShaderType = enum(u32) { FRAGMENT = 1, VERTEX = 2, PROGRAM = 3 };
