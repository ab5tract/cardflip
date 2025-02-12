
const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;
const Random = std.Random;

const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Image = rl.Image;
const Card = @import("card.zig").Card;

const screenDimension = @import("constants.zig").ScreenDimension;
const Dim2D = @import("constants.zig").Dim2D;

pub const CardSelection = enum {
    Left, Right, Random
};

pub const CardSelectionError = error {
    OutOfBounds
};

pub const CardSet = struct {
    cardCount: usize = 0,
    historyIndex: usize = 0,
    selectionIndex: usize,
    cards: ArrayList(Card),
    alreadySelected: std.AutoHashMap(usize, bool),
    indexHistory: ArrayList(usize),
    randomizer: Random.Xoshiro256,
    cardDimension: Dim2D,

    pub fn init(cards: ArrayList(Card), cardDimension: Dim2D, allocator: std.mem.Allocator) CardSet {
        const seed: u64 = @intCast(std.time.milliTimestamp());
        var alreadySelected = std.AutoHashMap(usize, bool).init(allocator);

        var randomizer = Random.DefaultPrng.init(seed);
        const selectionIndex = Random.uintLessThan(randomizer.random(), usize, cards.items.len);
        alreadySelected.put(selectionIndex, true) catch {};

        var indexHistory = ArrayList(usize).init(allocator);
        indexHistory.append(selectionIndex) catch {};

        return CardSet {
            .cardCount = cards.items.len,
            .cards = cards,
            .selectionIndex = selectionIndex,
            .alreadySelected = alreadySelected,
            .randomizer = randomizer,
            .indexHistory = indexHistory,
            .cardDimension = cardDimension
        };
    }

    pub fn initFromFilePaths(filePaths: ArrayList([]const u8), cardDimension: Dim2D, allocator: std.mem.Allocator) CardSet {
        return cardSetFromFilePaths(filePaths, cardDimension, allocator);
    }

    pub fn deinit(self: *CardSet) void {
        for (self.cards.items) |*card| {
            card.*.deinit();
        }
        self.cards.deinit();
        self.alreadySelected.deinit();
        self.indexHistory.deinit();
    }

    pub fn updateSelectionIndex(self: *CardSet, newIndex: usize) void {
        self.selectionIndex = newIndex;
        self.alreadySelected.put(newIndex, true) catch {};
        self.indexHistory.append(newIndex) catch {};
        self.historyIndex = self.indexHistory.items.len - 1;
    }

    pub fn currentCard(self: CardSet) ?Card {
        if ((self.cardCount - 1) < self.selectionIndex) return null;
        return self.cards.items[self.selectionIndex];
    }

    pub fn selectNextCard(self: *CardSet, direction: CardSelection) ?Card {
        if (direction == CardSelection.Random) {
            const currentSize: usize = @intCast(self.alreadySelected.count());
            if (currentSize == self.cardCount) {
                std.debug.print("Cannot randomly select anymore (currentSize={})\n", .{currentSize});
                return self.currentCard();
            }
            return self.selectNextCardRandomly();
        } else {
            return self.selectNextCardByDirection(direction);
        }
    }

    pub fn selectNextCardRandomly(self: *CardSet) ?Card {
        var nextIndex = Random.uintLessThan(self.randomizer.random(), usize, self.cardCount);
        std.debug.print("index={} alreadySelected={}\n", .{nextIndex, self.alreadySelected.contains(nextIndex)});

        while (self.alreadySelected.contains(nextIndex)) {
            nextIndex = Random.uintLessThan(self.randomizer.random(), usize, self.cardCount);
        }
        self.updateSelectionIndex(nextIndex);

        return self.currentCard();
    }

    pub fn selectNextCardByDirection(self: *CardSet, direction: CardSelection) ?Card {
        const offset: i2 = if (direction == CardSelection.Right) 1 else -1;
        const newIndex: i16 = @as(i16, @intCast(self.historyIndex)) + offset;

        if (0 <= newIndex and newIndex < self.indexHistory.items.len) {
            self.historyIndex = @as(usize, @intCast(newIndex));
            self.selectionIndex = self.indexHistory.items[self.historyIndex];
        } else {
            std.debug.print("Selection Error={}\n", .{CardSelectionError.OutOfBounds});
            return null;
        }

        return self.currentCard();
    }
};

fn cardSetFromFilePaths(
    filePaths: ArrayList([]const u8),
    cardDimension: Dim2D,
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
            cards.append(Card.init(texture.*, cardDimension)) catch continue;
        }
    }

    return CardSet.init(cards, cardDimension, allocator);
}
