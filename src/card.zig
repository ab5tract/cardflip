const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");

const Image = rl.Image;
const Texture2D = rl.Texture2D;
const Rectangle = rl.Rectangle;
const Dim2D = constants.Dim2D;

const screenWidth  = constants.ScreenWidth;
const screenHeight = constants.ScreenHeight;
const screenWidthFloat  = constants.WidthFloat;
const screenHeightFloat = constants.HeightFloat;

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
        const adjusted = determineRenderSize(textureWidth, textureHeight);

        const renderWidth  = if (tooBig) adjusted.width  else textureWidth;
        const renderHeight = if (tooBig) adjusted.height else textureHeight;

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

    pub fn render(self: Card) void {
        rl.drawTexturePro(
            self.imageTexture,
            self.sourceRect(),
            self.destRect(),
            rl.Vector2.zero(),
            0,
            rl.Color.white
        );
    }
};

fn determineRenderSize(width: f32, height: f32) Dim2D {
    const widthTooBig = screenWidthFloat < width;
    const heightTooBig = screenWidthFloat < height;

    var adjustedWidth  = width;
    var adjustedHeight = height;
    if (widthTooBig) {
        const adjust = screenWidthFloat / width;
        adjustedWidth  = adjustedWidth * adjust;
        adjustedHeight = adjustedHeight * adjust;
    }
    if (heightTooBig) {
        const adjust = screenHeightFloat / height;
        adjustedHeight = adjustedHeight * adjust;
        adjustedWidth  = adjustedWidth * adjust;
    }

    return Dim2D.init(adjustedWidth, adjustedHeight);
}
