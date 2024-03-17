const std = @import("std");
const Token = @import("token.zig").Token;

pub const Lexer = struct {
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
            '"' => Token{ .String = try self.getStringLiteral() },
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

    fn getStringLiteral(self: *Lexer) ![]const u8 {
        _ = self.next();
        var list = std.ArrayList(u8).init(self.allocator);
        try list.append(self.Input[self.Position]);
        while (self.tryNext()) |val| {
            try list.append(val);
            if (val == '"') {
                return list.items;
            }
        }
        const err = error.InvalidString;
        return err;
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
        const parsedI32 = try std.fmt.parseInt(u32, ch, 10);
        return Token{ .Num = parsedI32 };
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
            return Token.Func;
        } else if (std.mem.eql(u8, ch, "TRUE") or std.mem.eql(u8, ch, "true")) {
            return Token.True;
        } else {
            return Token{ .Ident = ch };
        }
    }
};
