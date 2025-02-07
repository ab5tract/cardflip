const std = @import("std");

const rl = @import("raylib");
const Texture2D = rl.Texture2D;
const Image = rl.Image;

pub const Card = struct {
    flipCount: u8 = 0,
    imageTexture: Texture2D,

    pub fn init(imageTexture: Texture2D) Card {
        return Card {
            .imageTexture = imageTexture
        };
    }

    pub fn deinit(self: Card) void {
        rl.unloadTexture(self.imageTexture);
    }
};
