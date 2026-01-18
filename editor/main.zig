const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const UI = EE3D.ui.UI;
const AssetBrowser = @import("assetbrowser.zig").AssetBrowser;
const Viewport = @import("viewport.zig").Viewport;
const ViewportCamera = @import("viewportcamera.zig").ViewportCamera;
const ProjectManager = @import("projectmanager.zig").ProjectManager;

pub fn main() !void {
    var app = try EE3D.application.Application.init();
    defer app.destroy();

    var window = try EE3D.window.Window.init(990, 540, "Editor");
    defer window.destroy();
    try app.create_context();

    var ui = UI.init(window);
    ui.applyDarkTheme();

    const Allocator = EE3D.application.allocator;

    const path = try std.fs.selfExeDirPathAlloc(Allocator);
    defer Allocator.free(path);

    const texturePath = try std.fs.path.join(Allocator, &[_][]const u8{ path, "Assets", "Rock051_1K-JPG_Color.jpg" });
    defer Allocator.free(texturePath);

    std.debug.print("{s}\n", .{texturePath});

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    var Texture = try EE3D.texture.Texture.init(Allocator, texturePath, gl.TEXTURE_2D, gl.TEXTURE1, gl.RGB, gl.UNSIGNED_BYTE);
    var TextureList = try std.ArrayList(EE3D.texture.Texture).initCapacity(Allocator, 2);
    defer TextureList.deinit(Allocator);

    try TextureList.append(Allocator, Texture);

    //var rotation: f32 = 0.0;
    //var prevTime = app.getTime();

    var Camera = camera.Camera.init(&window, [_]f32{ 0.0, 0.0, 2.0 });

    var TestModel = try EE3D.model.Model.init(Allocator, TextureList, "SP-8952.fbx");
    defer TestModel.deinit();

    var assetBrowser = try AssetBrowser.init(Allocator);
    defer assetBrowser.deinit();

    var projectManager = try ProjectManager.init(Allocator);
    defer projectManager.deinit();

    var viewport = Viewport.init(&window, &projectManager);
    defer viewport.deinit();
    var viewportCamera = ViewportCamera.init(&Camera, &window, viewport);
    defer viewport.deinit();

    gl.enable(gl.DEPTH_TEST);

    while (!window.shouldClose()) {
        const style = EE3D.zgui.getStyle();
        window.clear(style.getColor(.window_bg));
        viewport.startRender();
        window.update(false);
        window.startRender(null);
        Shader.activate();

        const drawBufs = [_]gl.Enum{gl.COLOR_ATTACHMENT0};
        gl.drawBuffers(1, &drawBufs[0]);

        //const currentTime = app.getTime();
        //if (currentTime - prevTime >= 1 / 60) {
        //    rotation += 0.5;
        //    prevTime = currentTime;
        //}

        Camera.updateMatrix(viewport.viewportSize[0], viewport.viewportSize[1], 75.0, 0.1, 100.0);

        try viewportCamera.input(1);
        try TestModel.draw(&Shader, &Camera);

        ui.startRender();

        if (EE3D.zgui.beginMainMenuBar()) {
            if (EE3D.zgui.beginMenu("Edit", true)) {
                if (EE3D.zgui.menuItem("Settings", .{})) {}
                EE3D.zgui.endMenu();
            }
            EE3D.zgui.endMainMenuBar();
        }

        viewport.endRender();

        try viewport.renderUI();
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
