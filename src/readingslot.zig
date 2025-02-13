const std = @import("std");

pub const ReadingSlot = struct {
    name: []const u8,
    row: u3 = 1,
    drawn: bool = false,

    pub fn init(name: []const u8, row: u3) ReadingSlot {
        return ReadingSlot {
            .name = name,
            .row  = row
        };
    }

    pub fn setDrawn(slot: *ReadingSlot) void {
        slot.drawn = true;
    }
};
