const glfw = @import("zglfw");
const logging = @import("Utils/logging.zig");
const zopengl = @import("zopengl");
const std = @import("std");
const gl = zopengl.bindings;

pub const FrameBuffer = struct {
    pub fn init(width: u64, height: u64) FrameBuffer {
        var fbo: gl.Uint = 0;
        var rbo: gl.Uint = 0;
        var texture: gl.Uint = 0;
        gl.genFramebuffers(1, &fbo);
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);

        gl.genTextures(1, &texture);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, @intCast(width), @intCast(height), 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture, 0);

        gl.genRenderbuffers(1, &rbo);
        gl.bindRenderbuffer(gl.RENDERBUFFER, rbo);
        gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, @intCast(width), @intCast(height));
        gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, rbo);

        if (gl.checkFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE) {
            try logging.Warn("EE3D Framebuffer not complete.", .{});
        }

        gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
        gl.bindTexture(gl.TEXTURE_2D, 0);
        gl.bindRenderbuffer(gl.RENDERBUFFER, 0);

        return FrameBuffer{
            .fbo = fbo,
            .rbo = rbo,
            .texture = texture,
        };
    }
    pub fn deinit(self: *FrameBuffer) void {
        gl.deleteFramebuffers(1, &self.fbo);
        gl.deleteTextures(1, &self.texture);
        gl.deleteRenderbuffers(1, &self.rbo);
    }
    pub fn resizeFrameBuffer(self: *FrameBuffer, width: u64, height: u64) void {
        gl.bindFramebuffer(gl.FRAMEBUFFER, self.fbo);
        gl.bindTexture(gl.TEXTURE_2D, self.texture);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, @intCast(width), @intCast(height), 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, self.texture, 0);

        gl.bindRenderbuffer(gl.RENDERBUFFER, self.rbo);
        gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, @intCast(width), @intCast(height));
        gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_STENCIL_ATTACHMENT, gl.RENDERBUFFER, self.rbo);
        gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
    }
    pub fn bind(self: *FrameBuffer) void {
        gl.bindFramebuffer(gl.FRAMEBUFFER, self.fbo);
    }
    pub fn unBind(self: *FrameBuffer) void {
        _ = self;
        gl.bindFramebuffer(gl.FRAMEBUFFER, 0);
    }
    fbo: gl.Uint,
    rbo: gl.Uint,
    texture: gl.Uint,
};
