
const Rectangle = @import("raylib").Rectangle;

pub const ScreenWidth = 600;
pub const ScreenHeight = 800;

pub const Screen = Rectangle.init(0, 0, ScreenWidth, ScreenHeight);

// TODO: Remove if un-needed
pub const WidthFloat: f32  = 600.0;
pub const HeightFloat: f32 = 800.0;

pub const Error = error {
    FileNotFound,
    PathNotADirectory,
    ImageNotLoadedIntoTexture,
    NoValidImageFilesProvided,
    Unknown,
    InvalidArgumentCombination
};
