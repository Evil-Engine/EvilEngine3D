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

    // Vertices coordinates
    const vertices: [20]f32 = [_]f32{
        -0.5, -0.5, 0.0, 0.0, 0.0,
        -0.5,  0.5, 0.0, 0.0, 1.0,
         0.5,  0.5, 0.0, 1.0, 1.0,
         0.5, -0.5, 0.0, 1.0, 0.0 
    };


    // Indices for vertices order
    var indices = [_]gl.Uint{
        0, 2, 1,
        0, 3, 2,
    };
    // zig fmt: on

    const Allocator = app.allocator;
    const path = try std.fs.selfExeDirPathAlloc(Allocator);
    defer Allocator.free(path);

    const texturePath = try std.mem.concat(Allocator, u8, &[_][]const u8{ path, "\\Will-it-hurt.png" });
    defer Allocator.free(texturePath);

    std.debug.print("{s}\n", .{texturePath});

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    var Texture = try EE3D.texture.Texture.init(Allocator, texturePath, gl.TEXTURE_2D, gl.TEXTURE0, gl.RGBA, gl.UNSIGNED_BYTE);
    try Texture.texUnit(&Shader, "tex0", 0);

    var VAO = EE3D.vao.VAO.init();
    VAO.bind();
    var VBO = EE3D.vbo.VBO.init(&vertices, @sizeOf([20]f32));
    var EBO = EE3D.ebo.EBO.init(indices[0..], @sizeOf([6]c_uint));

    VAO.linkVBO(&VBO, 0);

    VAO.linkAttrib(&VBO, 0, 3, gl.FLOAT, 5 * @sizeOf(f32), null);
    VAO.linkAttrib(&VBO, 1, 2, gl.FLOAT, 5 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));

    VAO.unBind();
    VBO.unBind();
    EBO.unBind();

    while (!window.shouldClose()) {
        window.startRender();
        Shader.activate();
        Texture.bind();
        VAO.bind();
        gl.drawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, null);
        window.endRender();
    }

    VAO.destroy();
    VBO.destroy();
    EBO.destroy();
    Texture.destroy();
    Shader.destroy();
}
