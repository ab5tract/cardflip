
const std = @import("std");
const rl  = @import("raylib");

const ArrayList = std.ArrayList;
const Texture2D = rl.Texture2D;
const Image = rl.Image;

const Error = @import("constants.zig").Error;

pub fn isImageFile(fileName: []const u8) bool {
    return (std.mem.count(u8, fileName, ".jpg") > 0)
        or (std.mem.count(u8, fileName, ".jpeg") > 0)
        or (std.mem.count(u8, fileName, ".png") > 0);
}

pub fn filesFromPath(
    fsPath: [*:0]const u8,
    dir: std.fs.Dir,
    filePaths: *ArrayList([]const u8),
    allocator: std.mem.Allocator
) anyerror!void {
    defer allocator.free(std.mem.span(fsPath));

    var maybeWalker = dir.walk(allocator) catch null;
    if (maybeWalker) |*walker| {
        defer walker.*.deinit();

        while (walker.*.next() catch null) |file| {
            if (! isImageFile(file.path)) continue;
            filePaths.*.append(fullPath(fsPath, file.path, allocator)) catch continue;
        }
    }
}

fn loadImageTexture(fileName: [*:0]const u8) anyerror!Texture2D {
    var maybeImage: ?Image = rl.loadImage(fileName) catch null;
    var imageTexture: ?Texture2D = null;

    if (maybeImage) |*image| {
        imageTexture = rl.loadTextureFromImage(image.*) catch |err| {
            std.debug.print("Unable to load texture from file: '{s}'\n\nException: {}", .{fileName, err});
            return Error.ImageNotLoadedIntoTexture;
        };

        rl.unloadImage(image.*);
    }

    std.debug.print("Texture successfully loaded for file: '{s}'\n", .{fileName});
    return imageTexture orelse Error.ImageNotLoadedIntoTexture;
}

fn fullPath(fsPath: [*:0]const u8, fileName: []const u8, allocator: std.mem.Allocator) []const u8 {
    return std.mem.concat(allocator, u8, &[_][]const u8{ std.mem.span(fsPath), fileName })
            catch "/tmp/nonononono\x00";
}
