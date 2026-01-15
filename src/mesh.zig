const vao = @import("vao.zig");
const vbo = @import("vbo.zig");
const ebo = @import("ebo.zig");
const std = @import("std");
const vertex = @import("vertex.zig");
const camera = @import("camera.zig");
const c = @import("Bindings/c.zig").c;
const texture = @import("texture.zig");
const shader = @import("shader.zig");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const ArrayList = std.ArrayList;

pub const Mesh = struct {
    pub fn init(vertices: ArrayList(vertex.Vertex), indices: ArrayList(gl.Uint), textures: ArrayList(texture.Texture)) Mesh {
        var VAO = vao.VAO.init();

        VAO.bind();

        var VBO = vbo.VBO.init(vertices);
        var EBO = ebo.EBO.init(indices);

        // comments for future me :D
        // Verts
        VAO.linkAttrib(&VBO, 0, 3, gl.FLOAT, @intCast(@sizeOf(vertex.Vertex)), null);
        // Normals
        VAO.linkAttrib(&VBO, 1, 3, gl.FLOAT, @intCast(@sizeOf(vertex.Vertex)), @ptrFromInt(3 * @sizeOf(f32)));
        // UVS
        VAO.linkAttrib(&VBO, 2, 2, gl.FLOAT, @intCast(@sizeOf(vertex.Vertex)), @ptrFromInt(6 * @sizeOf(f32)));
        VAO.unBind();
        VBO.unBind();
        EBO.unBind();

        return Mesh{
            .VAO = VAO,
            .vertices = vertices,
            .indices = indices,
            .textures = textures,
        };
    }

    pub fn destroy(self: *Mesh) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.VAO.destroy();
    }

    pub fn draw(self: *Mesh, Shader: *shader.Shader, Camera: *camera.Camera, modelMatrix: c.mat4) !void {
        Shader.activate();
        self.VAO.bind();
        //_ = modelMatrix;

        var i: u32 = 0;
        while (i < self.textures.items.len) : (i += 1) {
            try self.textures.items[i].texUnit(Shader, "tex0", @intCast(i));
            self.textures.items[i].bind();
        }

        gl.uniform3f(gl.getUniformLocation(Shader.id, "camPos"), Camera.position[0], Camera.position[1], Camera.position[2]);
        Camera.matrix(Shader, "camMatrix");

        //var modelIdentity: c.mat4 = undefined;
        //c.glmc_mat4_identity(&modelIdentity[0]);

        gl.uniformMatrix4fv(gl.getUniformLocation(Shader.id, "modelMatrix"), 1, gl.FALSE, &modelMatrix[0][0]);
        gl.drawElements(gl.TRIANGLES, @intCast(self.indices.items.len), gl.UNSIGNED_INT, null);
    }

    vertices: ArrayList(vertex.Vertex),
    indices: ArrayList(gl.Uint),
    textures: ArrayList(texture.Texture),
    VAO: vao.VAO,
};
