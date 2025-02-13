
const std = @import("std");

const rl  = @import("raylib");
const Rectangle = rl.Rectangle;
const Color = rl.Color;

const constants = @import("constants.zig");
const Dim2D = constants.Dim2D;
const deskDimension = constants.DeskDimension;
const deskShape = constants.DeskShape;

const CardSet = @import("cardset.zig").CardSet;
const Reading = @import("reading.zig").Reading;

pub const Desk = struct {
    dimension: Dim2D = deskDimension,
    shape: Rectangle = deskShape,
    reading: Reading,

    pub fn init(reading: Reading) Desk {
        return Desk {
            .reading = reading
        };
    }

    pub fn deinit(self: *Desk) void {
        self.reading.deinit();
    }

    pub fn render(self: *Desk) void {
        self.reading.render();
    }
};
