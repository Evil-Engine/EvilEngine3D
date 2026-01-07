const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const UI = EE3D.ui.UI;
const AssetBrowser = @import("assetbrowser.zig").AssetBrowser;

pub fn main() !void {
    var app = try EE3D.application.Application.init();
    defer app.destroy();

    var window = try EE3D.window.Window.init(990, 540, "Example");
    defer window.destroy();
    try app.create_context();

    var ui = UI.init(window);
    ui.applyDarkTheme();

    const Allocator = EE3D.application.allocator;

    const path = try std.fs.selfExeDirPathAlloc(Allocator);
    defer Allocator.free(path);

    const texturePath = try std.mem.concat(Allocator, u8, &[_][]const u8{ path, "\\Will-it-hurt.png" });
    defer Allocator.free(texturePath);

    std.debug.print("{s}\n", .{texturePath});

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    var Texture = try EE3D.texture.Texture.init(Allocator, texturePath, gl.TEXTURE_2D, gl.TEXTURE1, gl.RGBA, gl.UNSIGNED_BYTE);
    var TextureList = try std.ArrayList(EE3D.texture.Texture).initCapacity(Allocator, 2);
    defer TextureList.deinit(Allocator);

    try TextureList.append(Allocator, Texture);

    //var rotation: f32 = 0.0;
    //var prevTime = app.getTime();

    var Camera = camera.Camera.init(&window, [_]f32{ 0.0, 0.0, 2.0 });

    var TestModel = try EE3D.model.Model.init(Allocator, TextureList, "SP-8952.fbx");
    defer TestModel.deinit();

    const windowSize = window.getSize();

    var viewportBuffer: EE3D.FrameBuffer.FrameBuffer = EE3D.FrameBuffer.FrameBuffer.init(@intCast(windowSize.width), @intCast(windowSize.height));
    defer viewportBuffer.deinit();

    var assetBrowser = try AssetBrowser.init(Allocator);
    defer assetBrowser.deinit();

    gl.enable(gl.DEPTH_TEST);

    while (!window.shouldClose()) {
        window.startRender();
        viewportBuffer.bind();
        window.update(false);
        window.startRender();
        Shader.activate();

        const drawBufs = [_]gl.Enum{gl.COLOR_ATTACHMENT0};
        gl.drawBuffers(1, &drawBufs[0]);

        //const currentTime = app.getTime();
        //if (currentTime - prevTime >= 1 / 60) {
        //    rotation += 0.5;
        //    prevTime = currentTime;
        //}

        try Camera.inputs(&window);

        Camera.updateMatrix(75.0, 0.1, 100.0);

        try TestModel.draw(&Shader, &Camera);
        viewportBuffer.unBind();

        ui.startRender();

        if (EE3D.zgui.begin("Viewport", .{ .flags = .{ ._padding = 0 } })) {
            const width = EE3D.zgui.getContentRegionAvail()[0];
            const height = EE3D.zgui.getContentRegionAvail()[1];

            gl.viewport(0, 0, @intFromFloat(width), @intFromFloat(height));

            const tex_id: EE3D.zgui.TextureIdent = @enumFromInt(@as(u64, @intCast(viewportBuffer.texture)));
            gl.activeTexture(gl.TEXTURE0);
            gl.bindTexture(gl.TEXTURE_2D, viewportBuffer.texture);
            viewportBuffer.resizeFrameBuffer(@intFromFloat(width), @intFromFloat(height));
            EE3D.zgui.image(.{ .tex_data = null, .tex_id = tex_id }, .{ .w = width, .h = height, .uv0 = [_]f32{ 0, 1 }, .uv1 = [_]f32{ 1, 0 } });
        }
        EE3D.zgui.end();
        if (EE3D.zgui.begin("Hierarchy", .{})) {
            if (EE3D.zgui.button("Test", .{})) {
                std.debug.print("Test\n", .{});
            }
        }
        EE3D.zgui.end();
        try assetBrowser.draw();

        ui.endRender();
        window.endRender();
    }
    Texture.destroy();
    Shader.destroy();
}
