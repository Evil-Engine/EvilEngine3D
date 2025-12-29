const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const vbo = @import("vbo.zig");
const gl = zopengl.bindings;

pub const VAO = struct {
    pub fn init() VAO {
        var id: gl.Uint = 0;
        gl.genVertexArrays(1, &id);

        return VAO{ .id = id };
    }

    pub fn linkVBO(self: *VAO, VBO: *vbo.VBO, layout: gl.Uint) void {
        _ = self;
        VBO.bind();
        gl.vertexAttribPointer(layout, 3, gl.FLOAT, gl.FALSE, 0, null);
        gl.enableVertexAttribArray(layout);
        VBO.unBind();
    }

    pub fn bind(self: *VAO) void {
        gl.bindVertexArray(self.id);
    }

    pub fn unBind(self: *VAO) void {
        _ = self;
        gl.bindVertexArray(0);
    }

    pub fn destroy(self: *VAO) void {
        gl.deleteVertexArrays(1, &self.id);
    }

    id: gl.Uint,
};
