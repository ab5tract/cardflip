
const Rectangle = @import("raylib").Rectangle;

pub const ScreenWidth = 1616;
pub const ScreenHeight = 909;

pub const Screen = Rectangle.init(0, 0, ScreenWidth, ScreenHeight);

// TODO: Remove if un-needed
pub const WidthFloat: f32  = @as(f32, @floatFromInt(ScreenWidth));
pub const HeightFloat: f32 = @as(f32, @floatFromInt(ScreenHeight));

pub const Error = error {
    FileNotFound,
    PathNotADirectory,
    ImageNotLoadedIntoTexture,
    NoValidImageFilesProvided,
    Unknown,
    InvalidArgumentCombination
};
