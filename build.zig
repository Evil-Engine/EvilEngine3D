const std = @import("std");
const x86 = @import("std").Target.x86;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("editor/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("EE3D", lib_mod);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "EE3D",
        .root_module = lib_mod,
    });
    // Dependencies

    const zglfw = b.dependency("zglfw", .{});
    lib.root_module.addImport("zglfw", zglfw.module("root"));

    if (target.result.os.tag != .emscripten) {
        lib.linkLibrary(zglfw.artifact("glfw"));
    }

    const zopengl = b.dependency("zopengl", .{});
    lib.root_module.addImport("zopengl", zopengl.module("root"));

    const zigstbi = b.dependency("ZigSTBI", .{});
    lib.root_module.addImport("zigstbi", zigstbi.module("zigstbi"));

    const zgui = b.dependency("zgui", .{
        .shared = false,
        .with_implot = false,
        .backend = .glfw_opengl3,
        .target = target,
    });
    lib.root_module.addImport("zgui", zgui.module("root"));

    const assimp = b.dependency("ZigAssimp", .{ .formats = "FBX,Obj,B3D,Blend,glTF,glTF2" });

    const cglm_build = @import("vendor/cglm/build.zig");
    const cglm_lib = cglm_build.createLib(b, target, optimize);

    lib.linkLibrary(cglm_lib);
    lib.linkLibrary(assimp.artifact("assimp"));
    lib.linkLibrary(zgui.artifact("imgui"));

    lib_mod.addIncludePath(b.path("vendor/cglm/include/"));

    lib_mod.addIncludePath(assimp.path("include"));

    const exe = b.addExecutable(.{
        .name = "EE3D_Editor",
        .root_module = exe_mod,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
