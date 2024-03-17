const std = @import("std");

pub const Token = union(TokenTag) {
    If,
    Else,
    Return,
    False,
    Func,
    True,
    LParen,
    RParen,
    Let,
    Ident: []const u8,
    Equal,
    Bang,
    SemiColon,
    Num: u32,
    LBrace,
    RBrace,
    LBracket,
    RBracket,
    EOF,
    String: []const u8,

    fn tag(self: Token) usize {
        switch (self) {
            .If => return 1,
            .Else => return 2,
            .Return => return 3,
            .False => return 4,
            .Func => return 5,
            .True => return 6,
            .LParen => return 7,
            .RParen => return 8,
            .Let => return 9,
            .Ident => return 10,
            .Equal => return 11,
            .Bang => return 12,
            .SemiColon => return 13,
            .Num => return 14,
            .LBrace => return 15,
            .RBrace => return 16,
            .LBracket => return 17,
            .RBracket => return 18,
            .EOF => return 19,
            .String => return 20,
        }
    }

    pub fn toString(self: Token, allocator: std.mem.Allocator) []const u8 {
        return switch (self) {
            .If => "if",
            .Else => "else",
            .Return => "return",
            .False => "false",
            .Func => "fn",
            .True => "true",
            .LParen => "(",
            .RParen => ")",
            .Let => "let",
            .Ident => |v| v,
            .Equal => "=",
            .Bang => "!",
            .SemiColon => ";",
            .Num => |v| if (std.fmt.allocPrint(allocator, "{d}", .{v})) |val| {
                return val;
            } else |_| {
                return "";
            },
            .LBrace => "{",
            .RBrace => "}",
            .LBracket => "[",
            .RBracket => "]",
            .EOF => "",
            .String => |v| v,
        };
    }
};

pub const TokenTag = enum {
    If,
    Else,
    Return,
    False,
    Func,
    True,
    LParen,
    RParen,
    Let,
    Ident,
    Equal,
    Bang,
    SemiColon,
    Num,
    LBrace,
    RBrace,
    LBracket,
    RBracket,
    EOF,
    String,
};
