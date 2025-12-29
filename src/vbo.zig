const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const VBO = struct {
    pub fn init(vertices: []const gl.Float, size: gl.Sizeiptr) VBO {
        var vbo: gl.Uint = 0;
        gl.genBuffers(1, &vbo);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.bufferData(gl.ARRAY_BUFFER, size, vertices.ptr, gl.STATIC_DRAW);

        return VBO{ .id = vbo };
    }

    pub fn bind(self: *VBO) void {
        gl.bindBuffer(gl.ARRAY_BUFFER, self.id);
    }

    pub fn unBind(self: *VBO) void {
        _ = self;
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    }

    pub fn destroy(self: *VBO) void {
        gl.deleteBuffers(1, &self.id);
    }

    id: gl.Uint,
};
