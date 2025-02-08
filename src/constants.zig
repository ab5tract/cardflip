
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

pub const Dim2D = struct {
    width: f32,
    height: f32,

    pub fn init(w: f32, h: f32) Dim2D {
        return Dim2D {
            .width  = w,
            .height = h
        };
    }
};
