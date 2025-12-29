const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const EBO = struct {
    pub fn init(indices: []gl.Uint, size: gl.Sizeiptr) EBO {
        var id: gl.Uint = 0;
        gl.genBuffers(1, &id);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, id);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, size, indices.ptr, gl.STATIC_DRAW);

        return EBO{ .id = id };
    }

    pub fn bind(self: *EBO) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unBind(self: *EBO) void {
        _ = self;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn destroy(self: *EBO) void {
        gl.deleteBuffers(1, &self.id);
    }

    id: gl.Uint,
};
