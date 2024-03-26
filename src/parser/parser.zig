const std = @import("std");
const Token = @import("../lexer/lex.zig").Token;
const TokenTag = @import("../lexer/lex.zig").TokenTag;
const ArrayList = std.ArrayList;
pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: ArrayList(Token),
    position: u32,

    pub fn parse(self: *Parser) !ArrayList(Statement) {
        var statements = ArrayList(Statement).init(self.allocator);

        while (self.position < self.tokens.items.len) {
            std.debug.print("parsing {any}\n", .{self.currToken()});
            const statement = try self.parseStatement(self.currToken());
            if (statement) |stmt| {
                try statements.append(stmt);
            }
            self.nextToken();
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

    fn parseStatement(self: *Parser, token: Token) !?Statement {
        if (token == .Let) {
            return try self.parseLetStatement();
        }
        if (token == .Ident) {
            return self.parseIdentityStatement();
        }
        if (token == .Num) {
            return Statement{ .ExpressionStatement = try self.parseNumExpression() };
        }
        if (token == .String) {
            return Statement{ .ExpressionStatement = try self.parseStringExpression() };
        }
    }

    fn parseNumExpression(self: *Parser) !Expression {
        return switch (self.currToken()) {
            .Num => |v| Expression{ .NumLiteral = v },
            else => {
                return error.TokenTypeNotIdentity;
            },
        };
    }
    fn parseStringExpression(self: *Parser) !Expression {
        return switch (self.currToken()) {
            .String => |v| Expression{ .StringLiteral = v },
            else => {
                return error.TokenTypeNotIdentity;
            },
        };
    }
    fn parseIdentityExpression(self: *Parser) !Expression {
        return switch (self.currToken()) {
            .Ident => |v| Expression{ .IdentityExpression = v },
            else => {
                return error.TokenTypeNotIdentity;
            },
        };
    }

    fn parseIdentityStatement(self: *Parser) !Statement {
        if (self.parseIdentityExpression()) |expression| {
            return switch (expression) {
                .IdentityExpression => |val| Statement{ .ExpressionStatement = Expression{ .IdentityExpression = val } },
                else => error.ExpressionTypeNotIdentity,
            };
        } else |err| {
            return err;
        }
    }

    fn nextToken(self: *Parser) void {
        self.position = self.position + 1;
    }
    fn parseLetStatement(self: *Parser) !Statement {
        if (!std.mem.eql(u8, @tagName(self.currToken()), "Let")) {
            return error.DoesNotStartWithlet;
        }
        self.nextToken();
        const name = try self.parseIdentityExpression();
        self.nextToken();
        const isEquals = switch (self.currToken()) {
            .Equal => true,
            else => false,
        };

        if (isEquals) {
            self.nextToken();
            return Statement{ .LetStatement = LetStatement{ .Name = name.IdentityExpression, .Value = try self.parseExpression() } };
        } else {
            return error.NoEqualsAfterIdentityInLetExpression;
        }
    }

    fn parseExpression(self: *Parser) !Expression {
        switch (self.currToken()) {
            .String => |v| {
                return Expression{ .StringLiteral = v };
            },
            .Num => |v| {
                return Expression{ .NumLiteral = v };
            },

            else => {
                return error.ExpressionAfterLetIsNotLiteral;
            },
        }
    }
    fn currToken(self: *Parser) Token {
        return self.tokens.items[self.position];
    }
};
pub const Expression = union(ExpressionTag) {
    StringLiteral: []const u8,
    NumLiteral: u32,
    IdentityExpression: []const u8,
};

pub const ExpressionTag = enum {
    StringLiteral,
    NumLiteral,
    IdentityExpression,
};
pub const Statement = union(StatementTag) {
    LetStatement: LetStatement,
    ExpressionStatement: ExpressionTag,
    St,
};

pub const StatementTag = enum {
    LetStatement,
    ExpressionStatement,
    St,
};

pub const Node = struct {};

pub const LetStatement = struct {
    Name: []const u8,
    Value: Expression,
};

pub const Precedence = enum {
    EQUALS,
    LESSGREATER,
    SUM,
    PRODUCT,
    PREFIX,
    CALL,
};
