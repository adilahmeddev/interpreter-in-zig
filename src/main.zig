const std = @import("std");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const input = "(); let adil = 5;";
    std.debug.print("{s}\n", .{input});
    var buffer: [999]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var lexer = Lexer{ .Position = 0, .Input = input, .allocator = allocator };

    const toks = try lexer.lex();
    for (toks.items) |opt_item| {
        if (opt_item) |item| {
            switch (item) {
                .Ident, .Num => |val| std.debug.print("{s}\n", .{val}),
                else => std.debug.print("{any}\n", .{item}),
            }
        }
    }
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}
const Lexer = struct {
    Position: u32,
    Input: []const u8,
    allocator: std.mem.Allocator,

    fn next(self: *Lexer) u8 {
        self.Position = self.Position + 1;
        return self.Input[self.Position];
    }
    fn peek(self: Lexer) u8 {
        return self.Input[self.position + 1];
    }
    fn hasNext(self: Lexer) bool {
        return self.Input.len > self.Position + 1;
    }

    fn endOfWord(self: Lexer) bool {
        const curr = self.Input[self.Position];
        return curr != ' ' and !self.hasNext();
    }
    fn tryNext(self: *Lexer) ?u8 {
        if (!self.endOfWord() and self.hasNext()) {
            return self.next();
        }
        return null;
    }

    fn getWordWithCheck(self: *Lexer, func: fn (x: u8) bool) ![]const u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        try list.append(self.Input[self.Position]);
        while (self.tryNext()) |val| {
            if (val == ' ' or !func(val)) {
                return list.items;
            }
            try list.append(val);
        }
        return list.items;
    }

    fn getWord(self: *Lexer) ![]const u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        try list.append(self.Input[self.Position]);
        while (self.tryNext()) |val| {
            if (val == ' ') {
                return list.items;
            }
            try list.append(val);
        }
        return list.items;
    }

    fn isNum(x: u8) bool {
        return switch (x) {
            '0'...'9' => return true,
            else => return false,
        };
    }
    pub fn lex(self: *Lexer) !std.ArrayList(?Token) {
        var list = std.ArrayList(?Token).init(self.allocator);
        try list.append(switch (self.Input[self.Position]) {
            '(' => Token.LParen,
            ')' => Token.RParen,
            '=' => Token.Equal,
            ';' => Token.SemiColon,
            '{' => Token.RBrace,
            '}' => Token.LBrace,
            '[' => Token.LBracket,
            ']' => Token.RBracket,
            'a'...'z', 'A'...'Z' => zz: {
                const ch = try self.getWord();
                if (std.mem.eql(u8, ch, "let") or std.mem.eql(u8, ch, "LET")) {
                    break :zz Token.Let;
                } else {
                    break :zz Token{ .Ident = ch };
                }
            },
            '0'...'9' => za: {
                const ch = try self.getWordWithCheck(isNum);

                break :za Token{ .Num = ch };
            },
            ' ' => null,
            else => Token.EOF,
        });

        while (self.tryNext()) |c| {
            try list.append(switch (c) {
                '(' => Token.LParen,
                ')' => Token.RParen,
                '=' => Token.Equal,
                ';' => Token.SemiColon,
                '{' => Token.RBrace,
                '}' => Token.LBrace,
                '[' => Token.LBracket,
                ']' => Token.RBracket,
                '0'...'9' => za: {
                    const ch = try self.getWordWithCheck(isNum);

                    break :za Token{ .Num = ch };
                },

                'a'...'z', 'A'...'Z' => zz: {
                    const ch = try self.getWord();
                    if (std.mem.eql(u8, ch, "let") or std.mem.eql(u8, ch, "LET")) {
                        break :zz Token.Let;
                    } else {
                        break :zz Token{ .Ident = ch };
                    }
                },
                ' ' => null,
                else => Token.EOF,
            });
        }
        return list;
    }
};
const Token = union(enum) {
    LParen,
    RParen,
    Let,
    Ident: []const u8,
    Equal,
    SemiColon,
    Num: []const u8,
    LBrace,
    RBrace,
    LBracket,
    RBracket,
    EOF,

    fn tag(self: Token) usize {
        switch (self) {
            .LParen => return 1,
            .RParen => return 2,
            .Let => return 3,
            .Ident => return 4,
            .Equal => return 5,
            .SemiColon => return 6,
            .Num => return 7,
            .LBrace => return 8,
            .RBrace => return 9,
            .LBracket => return 10,
            .RBracket => return 11,
            .EOF => return 12,
        }
    }
};

const TokenTag = enum { LParen, Rparen, Let, Ident, Equal, SemiColon, Num, LBrace, RBrace, LBracket, RBracket, EOF };
