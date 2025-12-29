const file = @import("utils/file.zig");
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

        const fragmentShader: gl.Uint = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fragmentShader, 1, &fragCodePtr, &fragLen);
        gl.compileShader(fragmentShader);

        const id = gl.createProgram();
        gl.attachShader(id, vertexShader);
        gl.attachShader(id, fragmentShader);

        gl.linkProgram(id);

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
