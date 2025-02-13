const std = @import("std");
const rl = @import("raylib");
const clap = @import("clap");
const load = @import("loading.zig");

const ArrayList = std.ArrayList;

const Color = rl.Color;
const Image = rl.Image;
const Texture2D = rl.Texture2D;
const Rectangle = rl.Rectangle;

const RaylibError = rl.RaylibError;
const Error = @import("constants.zig").Error;

const Desk = @import("desk.zig").Desk;
const Card = @import("card.zig").Card;
const Reading = @import("reading.zig").Reading;
const CardSet = @import("cardset.zig").CardSet;
const CardSelection = @import("cardset.zig").CardSelection;

// Setup
const screen = @import("constants.zig").Screen;
const screenDimension = @import("constants.zig").ScreenDimension;
const cardDimension = @import("constants.zig").CardDimension;
const deskDimension = @import("constants.zig").DeskDimension;
const Dim2D = @import("constants.zig").Dim2D;
const addTrailingZero = @import("loading.zig").addTrailingZero;

var bordersToggled: bool = false;

fn prepareWindow(width: i32, height: i32) void {
   const monitor = rl.getCurrentMonitor();

   const finalX = @divTrunc(rl.getMonitorWidth(monitor), 2) - @divTrunc(width, 2);
   const finalY = @divTrunc(rl.getMonitorHeight(monitor), 2) - @divTrunc(height, 2);

   rl.setWindowPosition(finalX, finalY);
   rl.setWindowSize(width, height);
   if (! bordersToggled) {
       // TODO: This doesn't cause a "window context" on macOS Stage Manager
       //rl.toggleBorderlessWindowed();
       bordersToggled = true;
   }
}
// Errors are defined in error enumerations, example:

//--------------------------------------------------------------------------------------
// Program entry point
//--------------------------------------------------------------------------------------
pub fn main() anyerror!void {

    // First we set up the CLI parsing
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    //Initialization
    //--------------------------------------------------------------------------------------
    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    rl.initWindow(
        deskDimension.width,
        deskDimension.height,
        "Cardflip",
    );

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`.
    const params = comptime clap.parseParamsComptime(
        \\-h, --help            Display this help and exit.
        \\-p, --path <str>      Path containing a set of card images to display
        \\<str>...              A list of files to load (mutually exclusive with 'path')
    );

    // Initialize our diagnostics, which can be used for reporting useful errors.
    // This is optional. You can also pass `.{}` to `clap.parse` if you don't
    // care about the extra information `Diagnostics` provides.
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        // Report useful error and exit.
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    const hasPositionals = res.positionals.len > 0;
    const hasPathParam   = res.args.path != null;
    if (hasPositionals and hasPathParam) {
        return Error.InvalidArgumentCombination;
    }

    var filePaths = std.ArrayList([]const u8).init(gpa.allocator());

    if (res.args.path) |pathParam| {
        const rawPath = addTrailingZero(pathParam, gpa.allocator()) catch return Error.Unknown;
        const path: [*:0]const u8 = @ptrCast(rawPath.ptr);

        std.debug.print("**** Trying to load cards from directory: {s}\n", .{pathParam});

        var dir = std.fs.openDirAbsolute(pathParam, .{ .iterate = true }) catch |err| {
            std.debug.print("Could not open directory: '{s}'\n\nException: {}\n", .{rawPath, err});
            return err;
        };
        defer dir.close();

        load.filesFromPath(path, dir, &filePaths, gpa.allocator()) catch return Error.ImageNotLoadedIntoTexture;
    } else {
        for (res.positionals) |path| {
            if (load.isImageFile(path)) {
                const dupePath = gpa.allocator().dupe(u8, path) catch continue;
                filePaths.append(dupePath) catch continue;
            }
        }
    }
    if (filePaths.items.len == 0) return Error.NoValidImageFilesProvided;

    const cardSet = CardSet.initFromFilePaths(filePaths, cardDimension, gpa.allocator());
    if (cardSet.cards.items.len == 0) return Error.NoValidImageFilesProvided;

    const reading = Reading.init(cardSet, gpa.allocator());
    var desk = Desk.init(reading);

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer rl.closeWindow(); // Close window and OpenGL context
    defer desk.deinit();
    //--------------------------------------------------------------------------------------

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    while (! rl.windowShouldClose()) {
        // Update
        //--------------------------------------------------------------------------------------
        const upDown    = rl.isKeyPressed(rl.KeyboardKey.up);

        if (upDown) {
            desk.drawNextCard();
        }
        //--------------------------------------------------------------------------------------

        // Draw
        //--------------------------------------------------------------------------------------
        prepareWindow(@intFromFloat(deskDimension.width), @intFromFloat(deskDimension.height));

        rl.beginDrawing();
        rl.clearBackground(Color.light_gray);

        desk.render();

        rl.endDrawing();
        //--------------------------------------------------------------------------------------
    }
}
