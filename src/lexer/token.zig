pub const Token = union(enum) {
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

pub const TokenTag = enum { If, Else, Return, False, func, True, LParen, Rparen, Let, Ident, Equal, Bang, SemiColon, Num, LBrace, RBrace, LBracket, RBracket, EOF };
