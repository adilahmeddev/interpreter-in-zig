const std = @import("std");
const lxr = @import("lexer/lex.zig");
const Lexer = lxr.lexer.Lexer;
const TokenTag = lxr.token.TokenTag;
pub fn main() !void {
    const input = "(); let adil = 5; 23123; bob ! fn else if ";
    std.debug.print("{s}\n", .{input});

    var buffer: [999]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var lexer = Lexer{ .Position = 0, .Input = input, .allocator = allocator };

    const toks = try lexer.lex();
    for (toks.items) |item| {
        std.debug.print("{s}\n", .{item.toString()});
    }
}
