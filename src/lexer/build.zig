const std = @import("std");
pub const lexer = @import("lexer.zig");
pub const token = @import("token.zig");

pub fn build(b: *std.Build) void {
    _ = b.createModule(.{ .root_source_file = .{ .path = "lexer.zig" } });
}
