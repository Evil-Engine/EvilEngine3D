const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const camera = EE3D.camera;
const cglm = EE3D.cglm;

pub fn main() !void {
    var app = try EE3D.application.Application.init();
    defer app.destroy();

    var window = try EE3D.window.Window.init(990, 540, "Example");
    defer window.destroy();
    try app.create_context();

    // zig fmt: off

    // Vertices coordinates
    const vertices = [_]EE3D.vertex{
        EE3D.vertex{
            .position = [_]f32{-0.5, -0.5, 0.0},
            .UV =  [_]f32{0.0, 0.0},
        },
        EE3D.vertex{
            .position = [_]f32{-0.5, 0.5, 0.0},
            .UV =  [_]f32{0.0, 1.0},
        },
        EE3D.vertex{
            .position = [_]f32{0.5, 0.5, 0.0},
            .UV =  [_]f32{1.0, 1.0},
        },
        EE3D.vertex{
            .position = [_]f32{0.5, -0.5, 0.0},
            .UV =  [_]f32{1.0, 0.0},
        },
    };


    // Indices for vertices order
    const indices = [_]gl.Uint{
        0, 2, 1,
        0, 3, 2,
    };
    // zig fmt: on

    const Allocator = EE3D.application.allocator;
    var vertexList = try std.ArrayList(EE3D.vertex).initCapacity(Allocator, vertices.len + 1);
    defer vertexList.deinit(Allocator);

    var indicesList = try std.ArrayList(gl.Uint).initCapacity(Allocator, indices.len + 1);
    defer indicesList.deinit(Allocator);

    for (vertices) |v| {
        try vertexList.append(Allocator, v);
    }

    for (indices) |i| {
        try indicesList.append(Allocator, i);
    }

    const path = try std.fs.selfExeDirPathAlloc(Allocator);
    defer Allocator.free(path);

    const texturePath = try std.mem.concat(Allocator, u8, &[_][]const u8{ path, "\\Will-it-hurt.png" });
    defer Allocator.free(texturePath);

    std.debug.print("{s}\n", .{texturePath});

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    var Texture = try EE3D.texture.Texture.init(Allocator, texturePath, gl.TEXTURE_2D, gl.TEXTURE0, gl.RGBA, gl.UNSIGNED_BYTE);
    var TextureList = try std.ArrayList(EE3D.texture.Texture).initCapacity(Allocator, 2);
    defer TextureList.deinit(Allocator);

    try TextureList.append(Allocator, Texture);

    //var rotation: f32 = 0.0;
    //var prevTime = app.getTime();

    const windowSize = window.getSize();

    var Camera = camera.Camera.init(windowSize.width, windowSize.height, [_]f32{ 0.0, 0.0, 2.0 });

    var TestModel = try EE3D.model.Model.init(Allocator, TextureList, "SP-8952.fbx");
    defer TestModel.deinit();

    gl.enable(gl.DEPTH_TEST);

    while (!window.shouldClose()) {
        window.startRender();
        Shader.activate();

        //const currentTime = app.getTime();
        //if (currentTime - prevTime >= 1 / 60) {
        //    rotation += 0.5;
        //    prevTime = currentTime;
        //}

        try Camera.inputs(&window);

        Camera.updateMatrix(75.0, 0.1, 100.0);

        try TestModel.draw(&Shader, &Camera);

        window.endRender();
    }
    Texture.destroy();
    Shader.destroy();
}
