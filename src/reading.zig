
const std = @import("std");
const ArrayList = std.ArrayList;

const rl  = @import("raylib");
const Rectangle = rl.Rectangle;
const Color = rl.Color;

const constants = @import("constants.zig");
const Dim2D = constants.Dim2D;
const Card = @import("card.zig").Card;
const CardSet = @import("cardset.zig").CardSet;

const ReadingSlot = @import("readingslot.zig").ReadingSlot;

pub const Reading = struct {
    slotIndexes: std.StringHashMap(usize),
    slots: ArrayList(ReadingSlot),
    cardSet: CardSet,
    nextFlippedIndex: usize = 0,
    flipOrder: ArrayList(u8),
    allocator: std.mem.Allocator,

    pub fn init(cardSet: CardSet, allocator: std.mem.Allocator) Reading {
        var slots = ArrayList(ReadingSlot).init(allocator);
        slots.append(ReadingSlot.init("Inner Reality", 1)) catch {};
        slots.append(ReadingSlot.init("Topic", 1)) catch {};
        slots.append(ReadingSlot.init("Outer Reality", 1)) catch {};

        const slotIndexes = fillSlots(slots, @constCast(&cardSet), allocator);
        var flipOrder = ArrayList(u8).init(allocator);
        flipOrder.append(2) catch {};
        flipOrder.append(1) catch {};
        flipOrder.append(3) catch {};

        return Reading {
            .slotIndexes = slotIndexes,
            .slots = slots,
            .cardSet = cardSet,
            .flipOrder = flipOrder,
            .allocator = allocator
        };
    }

    pub fn deinit(self: *Reading) void {
        self.slotIndexes.deinit();
        self.slots.deinit();
        self.flipOrder.deinit();
        self.cardSet.deinit();
    }

    pub fn render(reading: Reading) void {
        var slotCount: f32 = 0;
        var slots = reading.slotIndexes;
        for (reading.slots.items) |*slot| {
            const cardIndex = slots.get(slot.*.name) orelse continue;
            const card = reading.cardSet.cards.items[cardIndex];

            if (slot.*.drawn) {
                rl.drawTexturePro(
                    card.imageTexture,
                    card.sourceShape(),
                    card.renderShape(slotCount),
                    rl.Vector2.zero(),
                    0,
                    Color.white
                );
            } else {
                rl.drawRectangleRec(card.renderShape(slotCount), Color.magenta);
            }

            slotCount += 1;
        }
    }

    pub fn drawNextCard(reading: *Reading) void {
        if (reading.nextFlippedIndex < reading.slots.items.len) {
            const flipIndex = reading.flipOrder.items[reading.nextFlippedIndex] - 1;
            var flipThis = &reading.slots.items[flipIndex];
            reading.nextFlippedIndex += 1;
            flipThis.setDrawn(true);
        }
    }

    fn fillSlots(slotOrder: ArrayList(ReadingSlot), cardSet: *CardSet, allocator: std.mem.Allocator) std.StringHashMap(usize) {
        var slots = std.StringHashMap(usize).init(allocator);
        for (slotOrder.items) |slot| {
            if (cardSet.selectNextCardRandomly() != null) {
                std.debug.print(">>>> Trying to put card into slot: {s}\n", .{slot.name});
                slots.put(slot.name, cardSet.selectionIndex) catch continue;
            }
        }
        return slots;
    }

    pub fn resetReading(reading: *Reading, allocator: std.mem.Allocator) void {
        std.debug.print(">>>> Resetting the reading...\n", .{});

        reading.slotIndexes.deinit();
        reading.slotIndexes = fillSlots(reading.slots, @constCast(&reading.cardSet), allocator);
        reading.nextFlippedIndex = 0;

        for (reading.slots.items) |*slot| { slot.setDrawn(false); }

        std.debug.print(">>>> Reset successful!\n", .{});
    }
};
