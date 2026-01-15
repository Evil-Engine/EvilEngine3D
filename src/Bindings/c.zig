pub const c = @cImport({
    @cDefine("CGLM_STATIC", "1");
    @cDefine("CGLM_ALL_UNALIGNED", "1");
    @cInclude("cglm/call.h");

    @cInclude("assimp/cimport.h");
    @cInclude("assimp/scene.h");
    @cInclude("assimp/postprocess.h");
});
