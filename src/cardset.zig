
const std = @import("std");
const ArrayList = std.ArrayList;

const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Image = rl.Image;
const Card = @import("card.zig").Card;

pub const CardSelection = enum {
    Left, Right
};

pub const CardSelectionError = error {
    OutOfBounds
};

pub const CardSet = struct {
    cardCount: usize = 0,
    selectionIndex: usize = 0,
    cards: ArrayList(Card),

    pub fn init(cards: ArrayList(Card)) CardSet {
        return CardSet {
            .cardCount = cards.items.len,
            .cards = cards
        };
    }

    pub fn initFromFilePaths(filePaths: ArrayList([]const u8), allocator: std.mem.Allocator) CardSet {
        return cardSetFromFilePaths(filePaths, allocator);
    }

    pub fn deinit(self: CardSet) void {
        for (self.cards.items) |*card| {
            card.*.deinit();
        }
        self.cards.deinit();
    }

    pub fn selectNextCard(self: *CardSet, direction: CardSelection) ?Card {
        const offset: i2 = if (direction == CardSelection.Right) 1 else -1;
        const newIndex: i16 = @as(i16, @intCast(self.selectionIndex)) + offset;
        if (0 <= newIndex and newIndex < (self.cardCount - 1)) {
            const replacementIndex: usize = @as(usize, @intCast(newIndex));
            self.selectionIndex = replacementIndex;
        } else {
            std.debug.print("{}", .{CardSelectionError.OutOfBounds});
            return null;
        }

        return self.currentCard();
    }

    pub fn currentCard(self: CardSet) Card {
        return self.cards.items[self.selectionIndex];
    }
};

fn cardSetFromFilePaths(
    filePaths: ArrayList([]const u8),
    allocator: std.mem.Allocator
) CardSet {
    defer filePaths.deinit();

    var cards = ArrayList(Card).init(allocator);
    for (filePaths.items) |path| {
        defer allocator.free(path);

        const concatPath = std.mem.concat(allocator, u8, &[_][]const u8{path, "\x00"}) catch continue;
        defer allocator.free(concatPath);

        const compatPath: [*:0]const u8 = @ptrCast(concatPath.ptr);

        var maybeImage: ?Image = rl.loadImage(compatPath) catch null;
        var imageTexture: ?Texture2D = null;

        if (maybeImage) |*image| {
            imageTexture = rl.loadTextureFromImage(image.*) catch |err| {
                std.debug.print("Unable to load texture from file: '{s}'\n\nException: {}", .{compatPath, err});
                continue;
            };

            std.debug.print("Texture successfully loaded for file: '{s}'\n", .{compatPath});
            defer rl.unloadImage(image.*);
        }

        if (imageTexture) |*texture| {
            std.debug.print("+++ Creating card from file: {s}\n", .{path});
            cards.append(Card.init(texture.*)) catch continue;
        }
    }

    return CardSet.init(cards);
}
