const std = @import("std");

const rl = @import("raylib");
const Image = rl.Image;
const Texture2D = rl.Texture2D;
const Rectangle = rl.Rectangle;

const screenWidth  = @import("constants.zig").ScreenWidth;
const screenHeight = @import("constants.zig").ScreenHeight;
const screenWidthFloat  = @import("constants.zig").WidthFloat;
const screenHeightFloat = @import("constants.zig").HeightFloat;

pub const Card = struct {
    imageTexture: Texture2D,
    renderWidth: f32,
    renderHeight: f32,
    textureWidth: f32,
    textureHeight: f32,

    pub fn init(imageTexture: Texture2D) Card {
        const textureWidth: f32  = @floatFromInt(imageTexture.width);
        const textureHeight: f32 = @floatFromInt(imageTexture.height);
        const tooBig = screenWidthFloat < textureWidth or screenHeightFloat < textureHeight;

        const renderWidth  = if (tooBig) determineRenderSize(textureWidth) else textureWidth;
        const renderHeight = if (tooBig) determineRenderSize(textureHeight) else textureHeight;

        return Card {
            .imageTexture  = imageTexture,
            .renderWidth   = renderWidth,
            .renderHeight  = renderHeight,
            .textureWidth  = textureWidth,
            .textureHeight = textureHeight
        };
    }

    pub fn deinit(self: Card) void {
        rl.unloadTexture(self.imageTexture);
    }

    pub fn destRect(self: Card) Rectangle {
        return Rectangle.init(0, 0, self.renderWidth, self.renderHeight);
    }

    pub fn sourceRect(self: Card) Rectangle {
        return Rectangle.init(0, 0, self.textureWidth, self.textureHeight);
    }
};

fn determineRenderSize(dimSize: f32) f32 {
    return dimSize * (screenHeightFloat / screenWidthFloat);
}
