const std = @import("std");
const vertex = @import("vertex.zig");
const camera = @import("camera.zig");
const texture = @import("texture.zig");
const shader = @import("shader.zig");
const mesh = @import("mesh.zig");
const logging = @import("Utils/logging.zig");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;
const ArrayList = std.ArrayList;
const c = @import("Bindings/c.zig").c;

pub const Model = struct {
    pub fn init(allocator: std.mem.Allocator, textures: ArrayList(texture.Texture), path: []const u8) !Model {
        const c_path = try allocator.dupeZ(u8, path);
        defer allocator.free(c_path);

        const scene = c.aiImportFile(
            c_path.ptr,
            c.aiProcess_Triangulate,
        );
        if (scene == null) {
            try logging.Error("Assimp Error: {s}\n", .{c.aiGetErrorString()});
            return error.AssimpFailedToLoadModel;
        }
        const meshes = try ArrayList(mesh.Mesh).initCapacity(allocator, 1);
        const matrices = try ArrayList(c.mat4).initCapacity(allocator, 1);
        var identity: c.mat4 = undefined;
        c.glmc_mat4_identity(&identity[0]);

        var model = Model{
            .allocator = allocator,
            .scene = scene,
            .meshes = meshes,
            .matrices = matrices,
            .textures = textures,
        };

        try model.traverseNode(scene.*.mRootNode, identity);

        return model;
    }

    pub fn deinit(self: *Model) void {
        self.meshes.deinit(self.allocator);
        self.matrices.deinit(self.allocator);
        c.aiReleaseImport(self.scene);
    }

    /// Converts assimp meshes into Evil Engine 3D meshes
    fn meshFromAssimp(self: *Model, aiMesh: *const c.struct_aiMesh) !mesh.Mesh {
        var vertices = try std.ArrayList(vertex.Vertex).initCapacity(self.allocator, aiMesh.mNumVertices + 1);

        // 3 is the min amount of indices and is just a theory, A GAME ENGINE THEORY!!!
        var indices = try std.ArrayList(gl.Uint).initCapacity(self.allocator, 3);

        var i: u32 = 0;
        while (i < aiMesh.mNumVertices) : (i += 1) {
            const v: c.struct_aiVector3D = aiMesh.mVertices[i];
            const n: c.struct_aiVector3D = if (aiMesh.mNormals != null) aiMesh.mNormals[i] else c.struct_aiVector3D{ .x = 0, .y = 0, .z = 0 };
            const uv: c.struct_aiVector3D = if (aiMesh.mTextureCoords[0] != null) aiMesh.mTextureCoords[0][i] else c.struct_aiVector3D{ .x = 0, .y = 0, .z = 0 };

            try vertices.append(self.allocator, vertex.Vertex{
                .position = .{ v.x, v.y, v.z },
                .normal = .{ n.x, n.y, n.z },
                .UV = .{ uv.x, uv.y },
            });
        }

        i = 0;
        while (i < aiMesh.mNumFaces) : (i += 1) {
            const face = aiMesh.mFaces[i];
            var j: u32 = 0;
            while (j < face.mNumIndices) : (j += 1) {
                try indices.append(self.allocator, face.mIndices[j]);
            }
        }

        return mesh.Mesh.init(vertices, indices, self.textures);
    }

    /// PC CRASHER 2000
    fn traverseNode(self: *Model, node: *const c.struct_aiNode, parentMatrix: c.mat4) !void {
        var localMatrix: c.mat4 = undefined;
        assimpMatrixToCGLM(node.mTransformation, &localMatrix);
        var scale: c.vec3 = [_]f32{ 0.1, 0.1, 0.1 };
        var scaleMatrix: c.mat4 = undefined;

        c.glmc_scale_make(&scaleMatrix[0], &scale);

        var worldMatrix: c.mat4 = undefined;
        var scaledLocalMatrix: c.mat4 = undefined;
        var parentMatrixMutable = parentMatrix;

        c.glmc_mat4_mul(&scaleMatrix[0], &localMatrix[0], &scaledLocalMatrix[0]);

        c.glmc_mat4_mul(&parentMatrixMutable[0], &scaledLocalMatrix[0], &worldMatrix[0]);

        var i: u32 = 0;
        while (i < node.mNumMeshes) : (i += 1) {
            const assimpMesh = self.scene.mMeshes[node.mMeshes[i]];
            const m = try self.meshFromAssimp(assimpMesh);
            try self.meshes.append(self.allocator, m);
            try self.matrices.append(self.allocator, worldMatrix);
        }

        i = 0;
        while (i < node.mNumChildren) : (i += 1) {
            try self.traverseNode(node.mChildren[i], worldMatrix);
        }
    }

    pub fn draw(self: *Model, Shader: *shader.Shader, Camera: *camera.Camera) !void {
        var i: u32 = 0;
        while (i < self.meshes.items.len) : (i += 1) {
            try self.meshes.items[i].draw(Shader, Camera, self.matrices.items[i]);
        }
    }

    scene: *const c.struct_aiScene,
    meshes: ArrayList(mesh.Mesh),
    matrices: ArrayList(c.mat4),
    textures: ArrayList(texture.Texture),
    allocator: std.mem.Allocator,
};

// GUYS I 100% DID NOT GENERATE THIS WITH CHATGPT ;)
fn assimpMatrixToCGLM(aiM: c.struct_aiMatrix4x4, out: *c.mat4) void {
    out[0][0] = aiM.a1;
    out[1][0] = aiM.a2;
    out[2][0] = aiM.a3;
    out[3][0] = aiM.a4;
    out[0][1] = aiM.b1;
    out[1][1] = aiM.b2;
    out[2][1] = aiM.b3;
    out[3][1] = aiM.b4;
    out[0][2] = aiM.c1;
    out[1][2] = aiM.c2;
    out[2][2] = aiM.c3;
    out[3][2] = aiM.c4;
    out[0][3] = aiM.d1;
    out[1][3] = aiM.d2;
    out[2][3] = aiM.d3;
    out[3][3] = aiM.d4;
}
