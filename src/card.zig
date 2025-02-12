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
const screenDimension   = constants.ScreenDimension;

pub const Card = struct {
    imageTexture: Texture2D,
    renderDimension: Dim2D,
    textureDimension: Dim2D,

    pub fn init(imageTexture: Texture2D) Card {
        const textureDimension = Dim2D.init(@floatFromInt(imageTexture.width), @floatFromInt(imageTexture.height));

        const tooBig = screenWidthFloat < textureDimension.width or screenHeightFloat < textureDimension.height;
        const adjusted = constrainToRenderDimension(textureDimension, screenDimension);

        const renderWidth  = if (tooBig) adjusted.width  else textureDimension.width;
        const renderHeight = if (tooBig) adjusted.height else textureDimension.height;

        return Card {
            .imageTexture     = imageTexture,
            .renderDimension  = Dim2D.init(renderWidth, renderHeight),
            .textureDimension = textureDimension
        };
    }

    pub fn deinit(self: Card) void {
        rl.unloadTexture(self.imageTexture);
    }

    pub fn renderShape(self: Card) Rectangle {
        return Rectangle.init(0, 0, self.renderDimension.width, self.renderDimension.height);
    }

    pub fn sourceShape(self: Card) Rectangle {
        return Rectangle.init(0, 0, self.textureDimension.width, self.textureDimension.height);
    }

    pub fn render(self: Card) void {
        rl.drawTexturePro(
            self.imageTexture,
            self.sourceShape(),
            self.renderShape(),
            rl.Vector2.zero(),
            0,
            rl.Color.white
        );
    }
};

fn constrainToRenderDimension(source: Dim2D, render: Dim2D) Dim2D {
    const widthTooBig  = render.width < source.width;
    const heightTooBig = render.height < source.height;

    var adjustedWidth  = source.width;
    var adjustedHeight = source.height;
    if (widthTooBig) {
        const adjust = render.width / source.width;
        adjustedWidth  = adjustedWidth * adjust;
        adjustedHeight = adjustedHeight * adjust;
    }
    if (heightTooBig) {
        const adjust = render.height / source.height;
        adjustedHeight = adjustedHeight * adjust;
        adjustedWidth  = adjustedWidth * adjust;
    }

    return Dim2D.init(adjustedWidth, adjustedHeight);
}
