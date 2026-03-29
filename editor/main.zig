const EE3D = @import("EE3D");
const gl = EE3D.zopengl.bindings;
const std = @import("std");
const camera = EE3D.camera;
const cglm = EE3D.cglm;
const UI = EE3D.ui.UI;
const AssetBrowser = @import("UI/assetbrowser.zig").AssetBrowser;
const Viewport = @import("UI/viewport.zig").Viewport;
const ViewportCamera = @import("viewportcamera.zig").ViewportCamera;
const ProjectManager = @import("projectmanager.zig").ProjectManager;
const FirstTime = @import("UI/firsttime.zig").FirstTime;
const Hierarchy = @import("UI/hierarchy.zig").Hierarchy;

pub fn main() !void {
    var app = try EE3D.application.Application.init();
    defer app.destroy();

    var window = try EE3D.window.Window.init(990, 540, "EE3D Editor");
    defer window.destroy();
    try app.create_context();

    const Allocator = EE3D.application.allocator;
    const path = try std.fs.selfExeDirPathAlloc(Allocator);
    defer Allocator.free(path);

    const windowIconPath = try std.fs.path.join(Allocator, &[_][]const u8{ path, "Assets", "EvilEngine-Transparent.png" });
    defer Allocator.free(windowIconPath);

    try window.setIcon(windowIconPath);

    var ui = UI.init(window);
    ui.applyDarkTheme();

    var Shader = try EE3D.shader.Shader.init(Allocator, "default.vert", "default.frag");

    const textureBasePath = try std.fs.path.join(Allocator, &[_][]const u8{ path, "Assets", "SP-8952_Base_AlbedoTransparency.png" });
    defer Allocator.free(textureBasePath);
    var BaseTexture = try EE3D.texture.Texture.init(Allocator, textureBasePath, gl.TEXTURE_2D, gl.TEXTURE1, gl.RGB, gl.UNSIGNED_BYTE);

    const textureBarrelPath = try std.fs.path.join(Allocator, &[_][]const u8{ path, "Assets", "SP-8952_Barrel_AlbedoTransparency.png" });
    defer Allocator.free(textureBarrelPath);
    var BarrelTexture = try EE3D.texture.Texture.init(Allocator, textureBarrelPath, gl.TEXTURE_2D, gl.TEXTURE1, gl.RGB, gl.UNSIGNED_BYTE);

    const textureConductorPath = try std.fs.path.join(Allocator, &[_][]const u8{ path, "Assets", "SP-8952_Conductor_AlbedoTransparency.png" });
    defer Allocator.free(textureConductorPath);
    var ConductorTexture = try EE3D.texture.Texture.init(Allocator, textureConductorPath, gl.TEXTURE_2D, gl.TEXTURE1, gl.RGB, gl.UNSIGNED_BYTE);

    var MaterialList = try std.ArrayList(EE3D.material.Material).initCapacity(Allocator, 2);
    defer MaterialList.deinit(Allocator);

    try MaterialList.append(Allocator, EE3D.material.Material.init(BarrelTexture));
    try MaterialList.append(Allocator, EE3D.material.Material.init(BaseTexture));
    try MaterialList.append(Allocator, EE3D.material.Material.init(ConductorTexture));

    //var rotation: f32 = 0.0;
    //var prevTime = app.getTime();

    var Camera = camera.Camera.init(&window, [_]f32{ 0.0, 0.0, 2.0 });

    var TestModel = try EE3D.model.Model.init(Allocator, MaterialList, "SP-8952.fbx");
    defer TestModel.deinit();

    var assetBrowser = try AssetBrowser.init(Allocator);
    defer assetBrowser.deinit();

    var projectManager = try ProjectManager.init(Allocator, &assetBrowser);
    defer projectManager.deinit();

    var viewport = Viewport.init(&window, &projectManager);
    defer viewport.deinit();
    var viewportCamera = ViewportCamera.init(&Camera, &window, viewport);
    defer viewport.deinit();

    var hierarchy = try Hierarchy.init(Allocator);
    defer hierarchy.deinit();

    var firstTime = try FirstTime.init(Allocator);
    defer firstTime.deinit();
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

        if (firstTime.isFirstTime) {
            firstTime.renderUI();
        } else {
            try hierarchy.renderUI();

            try viewport.renderUI();
            try assetBrowser.draw();
        }

        viewport.endRender();
        ui.endRender();
        window.endRender();
    }
    BaseTexture.destroy();
    BarrelTexture.destroy();
    ConductorTexture.destroy();
    Shader.destroy();
}
