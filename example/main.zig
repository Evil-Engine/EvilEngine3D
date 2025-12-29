const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");

pub fn main() !void {
    var app = try EE3D.application.Application.init();
    defer app.destroy();

    var window = try EE3D.window.Window.init(990, 540, "Example");
    defer window.destroy();
    try app.create_context();

    // zig fmt: off
    const sqrt3: f32 = @sqrt(3.0);

    // Vertices coordinates
    const vertices: [18]f32 = [_]f32{
        -0.5,  -0.5 * sqrt3 / 3.0, 0.0,
         0.5,  -0.5 * sqrt3 / 3.0, 0.0,
         0.0,   0.5 * sqrt3 * 2.0 / 3.0, 0.0,
        -0.25,  0.5 * sqrt3 / 6.0, 0.0,
         0.25,  0.5 * sqrt3 / 6.0, 0.0,
         0.0,  -0.5 * sqrt3 / 3.0, 0.0,
    };

    // Indices for vertices order
    var indices = [_]gl.Uint{
        0, 3, 5,
        3, 2, 4,
        5, 4, 1,
    };
    // zig fmt: on

    const Allocator = std.heap.page_allocator;

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    var VAO = EE3D.vao.VAO.init();
    VAO.bind();
    var VBO = EE3D.vbo.VBO.init(&vertices, @sizeOf([18]f32));
    var EBO = EE3D.ebo.EBO.init(indices[0..], @sizeOf([9]c_uint));

    VAO.linkVBO(&VBO, 0);

    VAO.unBind();
    VBO.unBind();
    EBO.unBind();

    while (!window.shouldClose()) {
        window.startRender();
        Shader.activate();
        VAO.bind();
        gl.drawElements(gl.TRIANGLES, 9, gl.UNSIGNED_INT, null);
        window.endRender();
    }

    VAO.destroy();
    VBO.destroy();
    EBO.destroy();
    Shader.destroy();
}
