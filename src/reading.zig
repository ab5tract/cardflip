
const std = @import("std");
const ArrayList = std.ArrayList;

const rl  = @import("raylib");
const Rectangle = rl.Rectangle;
const Color = rl.Color;

const constants = @import("constants.zig");
const Dim2D = constants.Dim2D;
const Card = @import("card.zig").Card;
const CardSet = @import("cardset.zig").CardSet;

pub const ReadingSlot = struct {
    name: []const u8,
    row: u3,

    pub fn init(name: []const u8, row: u3) ReadingSlot {
        return ReadingSlot {
            .name = name,
            .row  = row
        };
    }
};

pub const Reading = struct {
    slots: std.StringHashMap(usize),
    slotOrder: ArrayList(ReadingSlot),
    cardSet: CardSet,

    pub fn init(cardSet: CardSet, allocator: std.mem.Allocator) Reading {
        var slotOrder = ArrayList(ReadingSlot).init(allocator);
        slotOrder.append(ReadingSlot.init("Past", 1)) catch {};
        slotOrder.append(ReadingSlot.init("Present", 1)) catch {};
        slotOrder.append(ReadingSlot.init("Future", 1)) catch {};

        const slots = fillSlots(slotOrder, @constCast(&cardSet), allocator);
        return Reading {
            .slots = slots,
            .slotOrder = slotOrder,
            .cardSet = cardSet
        };
    }

    pub fn deinit(self: *Reading) void {
        self.slots.deinit();
        self.slotOrder.deinit();
        self.cardSet.deinit();
    }

    fn fillSlots(slotOrder: ArrayList(ReadingSlot), cardSet: *CardSet, allocator: std.mem.Allocator) std.StringHashMap(usize) {
        var slots = std.StringHashMap(usize).init(allocator);
        for (slotOrder.items) |slot| {
            if (cardSet.selectNextCardRandomly() != null) {
                std.debug.print(">>>> Trying to put card into slot {s}\n", .{slot.name});
                slots.put(slot.name, cardSet.selectionIndex) catch continue;
            }
        }
        return slots;
    }
};
