const std = @import("std");
const Token = @import("../lexer/lex.zig").Token;
const TokenTag = @import("../lexer/lex.zig").TokenTag;
const ArrayList = std.ArrayList;
pub const Parser = struct {
    //statements: ArrayList(Statement),
    allocator: std.mem.Allocator,
    tokens: ArrayList(Token),
    position: u32,

    pub fn parse(self: *Parser) !ArrayList(Statement) {
        var statements = ArrayList(Statement).init(self.allocator);

        while (self.position < self.tokens.items.len) {
            std.debug.print("parsing {any}\n", .{self.currToken()});
            try statements.append(try self.parseStatement(self.currToken()));
            self.position = self.position + 1;
        }
        std.debug.print("done parsing\n", .{});
        return statements;
    }
    fn peekToken(self: Parser) ?Token {
        if (self.position < self.tokens.items.len - 1) {
            return self.tokens.items[self.position + 1];
        }
        return null;
    }
    fn parseStatement(self: *Parser, token: Token) !Statement {
        return switch (token) {
            .If => Statement.St,
            .Else => Statement.St,
            .Return => Statement.St,
            .False => Statement.St,
            .Func => Statement.St,
            .True => Statement.St,
            .LParen => Statement.St,
            .RParen => Statement.St,
            .Let => let: {
                const ident: ?[]const u8 = id: {
                    if (self.peekToken()) |tok| {
                        break :id switch (tok) {
                            .Ident => |v| v,
                            else => null,
                        };
                    }
                    break :id null;
                };
                if (ident) |name| {
                    self.position = self.position + 1;
                    const isEquals = isE: {
                        if (self.peekToken()) |sym| {
                            self.position = self.position + 1;
                            break :isE switch (sym) {
                                .Equal => true,
                                else => false,
                            };
                        }
                        break :isE false;
                    };
                    if (isEquals) {
                        self.position = self.position + 1;
                        switch (self.currToken()) {
                            .String => |v| {
                                break :let Statement{ .LetStatement = Node{ .Name = name, .Value = Expression{ .StringLiteral = v } } };
                            },
                            .Num => |v| {
                                break :let Statement{ .LetStatement = Node{ .Name = name, .Value = Expression{ .NumLiteral = v } } };
                            },

                            else => {
                                std.debug.print("{any}\n", .{self.currToken()});
                                break :let error.ExpressionAfterLetIsNotLiteral;
                            },
                        }
                    }
                }

                break :let error.NoIdentifierAfterLet;
            },
            .Ident => Statement.St,
            .Equal => Statement.St,
            .Bang => Statement.St,
            .SemiColon => Statement.St,
            .Num => Statement.St,
            .LBrace => Statement.St,
            .RBrace => Statement.St,
            .LBracket => Statement.St,
            .RBracket => Statement.St,
            .EOF => Statement.St,
            .String => Statement.St,
        };
    }
    fn parseExpression(self: *Parser) Expression {
        switch (self.currToken()) {
            .Num => {},
            .String => {},
        }
    }
    fn currToken(self: Parser) Token {
        return self.tokens.items[self.position];
    }
};
pub const Expression = union(ExpressionTag) {
    StringLiteral: []const u8,
    NumLiteral: u32,
};

pub const ExpressionTag = enum {
    StringLiteral,
    NumLiteral,
};
pub const Statement = union(StatementTag) {
    LetStatement: Node,
    St,
};

pub const StatementTag = enum {
    LetStatement,
    St,
};

pub const Node = struct {
    Name: []const u8,
    Value: Expression,
};
