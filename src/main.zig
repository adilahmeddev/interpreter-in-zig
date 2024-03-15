const std = @import("std");

pub fn main() !void {
    const input = "(); let adil = 5; 23123; bob ! fn else if ";
    std.debug.print("{s}\n", .{input});

    var buffer: [999]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var lexer = Lexer{ .Position = 0, .Input = input, .allocator = allocator };

    const toks = try lexer.lex();
    for (toks.items) |item| {
        switch (item) {
            .Ident, .Num => |val| std.debug.print("{s}\n", .{val}),
            else => std.debug.print("{any}\n", .{item}),
        }
    }
}
const Lexer = struct {
    Position: u32,
    Input: []const u8,
    allocator: std.mem.Allocator,

    pub fn lex(self: *Lexer) !std.ArrayList(Token) {
        var list = std.ArrayList(Token).init(self.allocator);
        if (try self.getToken(self.Input[0])) |t| {
            try list.append(t);
        }

        while (self.tryNext()) |c| {
            if (try self.getToken(c)) |t| {
                try list.append(t);
            }
        }
        return list;
    }
    fn getToken(self: *Lexer, char: u8) !?Token {
        const tok = switch (char) {
            '(' => Token.LParen,
            ')' => Token.RParen,
            '=' => Token.Equal,
            ';' => Token.SemiColon,
            '{' => Token.RBrace,
            '}' => Token.LBrace,
            '[' => Token.LBracket,
            ']' => Token.RBracket,
            '!' => Token.Bang,

            'a'...'z', 'A'...'Z' => try self.getAlphToken(),
            '0'...'9' => try self.getNumToken(),

            ' ' => null,
            else => Token.EOF,
        };
        return tok;
    }
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
    fn getNumToken(self: *Lexer) !Token {
        const ch = try self.getWordWithCheck(isNum);
        return Token{ .Num = ch };
    }

    fn getAlphToken(self: *Lexer) !Token {
        const ch = try (self.getWord());
        if (std.mem.eql(u8, ch, "let") or std.mem.eql(u8, ch, "LET")) {
            return Token.Let;
        } else if (std.mem.eql(u8, ch, "bang") or std.mem.eql(u8, ch, "BANG")) {
            return Token.Bang;
        } else if (std.mem.eql(u8, ch, "if") or std.mem.eql(u8, ch, "IF")) {
            return Token.If;
        } else if (std.mem.eql(u8, ch, "ELSE") or std.mem.eql(u8, ch, "else")) {
            return Token.Else;
        } else if (std.mem.eql(u8, ch, "RETURN") or std.mem.eql(u8, ch, "return")) {
            return Token.Return;
        } else if (std.mem.eql(u8, ch, "FALSE") or std.mem.eql(u8, ch, "false")) {
            return Token.False;
        } else if (std.mem.eql(u8, ch, "FN") or std.mem.eql(u8, ch, "fn")) {
            return Token.func;
        } else if (std.mem.eql(u8, ch, "TRUE") or std.mem.eql(u8, ch, "true")) {
            return Token.True;
        } else {
            return Token{ .Ident = ch };
        }
    }
};
const Token = union(enum) {
    If,
    Else,
    Return,
    False,
    func,
    True,
    LParen,
    RParen,
    Let,
    Ident: []const u8,
    Equal,
    SemiColon,
    Bang,
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
            .Bang => return 12,
            .If => return 13,
            .Else => return 14,
            .Return => return 15,
            .False => return 16,
            .func => return 17,
            .True => return 18,
            .EOF => return 19,
        }
    }
};

const TokenTag = enum { If, Else, Return, False, func, True, LParen, Rparen, Let, Ident, Equal, Bang, SemiColon, Num, LBrace, RBrace, LBracket, RBracket, EOF };
