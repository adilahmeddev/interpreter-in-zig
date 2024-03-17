const std = @import("std");
const lxr = @import("lexer/lex.zig");
const Parser = @import("parser/parser.zig").Parser;
const Lexer = lxr.Lexer;
const TokenTag = @import("lexer").TokenTag;
pub fn main() !void {
    const input = "let adil = 5; 23123; bob; \"hi\" ! fn else if ";
    std.debug.print("{s}\n", .{input});

    var buffer: [99999]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var lexer = Lexer{ .Position = 0, .Input = input, .allocator = allocator };

    const toks = try lexer.lex();
    var parser = Parser{
        .tokens = toks,
        .allocator = allocator,
        .position = 0,
    };

    const statements = try parser.parse();

    for (statements.items) |item| {
        std.debug.print("{any}\n", .{item});
    }
}
