const std = @import("std");

const rl = @import("raylib");
const Image = rl.Image;
const Texture2D = rl.Texture2D;
const Rectangle = rl.Rectangle;

const screenWidth  = @import("constants.zig").ScreenWidth;
const screenHeight = @import("constants.zig").ScreenHeight;

pub const Card = struct {
    imageTexture: Texture2D,
    textureWidth: f32,
    textureHeight: f32,

    pub fn init(imageTexture: Texture2D) Card {
        const textureWidth: f32  = @floatFromInt(imageTexture.width);
        const textureHeight: f32 = @floatFromInt(imageTexture.height);
        return Card {
            .imageTexture  = imageTexture,
            .textureWidth  = textureWidth,
            .textureHeight = textureHeight
        };
    }

    pub fn deinit(self: Card) void {
        rl.unloadTexture(self.imageTexture);
    }

    pub fn cardCenter(self: Card) Rectangle {
        return Rectangle.init(
            (self.textureWidth * 0.5) - (self.textureWidth * 0.25),
            self.textureHeight,
            screenWidth,
            screenHeight
        );
    }
};
