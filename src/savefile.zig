const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");
const cwd: std.fs.Dir = std.fs.cwd();
var save_dir: std.fs.Dir = undefined;
var savefile: std.fs.File = undefined;

pub fn InitSavefile() void {
    cwd.makeDir("res/data") catch {};
    save_dir = cwd.openDir("res/data", .{}) catch std.fs.Dir{ .fd = 0 };
    savefile = save_dir.createFile("savefile.fred", .{.truncate = true}) catch std.fs.File{ .handle = 0 };
    
    save_dir.close();
    savefile.close();
}

pub fn WriteData(number: f32) void {
    save_dir = cwd.openDir("res/data", .{}) catch std.fs.Dir{ .fd = 0 };
    savefile = save_dir.openFile("savefile.fred", .{ .mode = .write_only }) catch std.fs.File{ .handle = 0 };
    
    var writer = savefile.writer();
    writer.print("{d:.0}\n", .{number}) catch {};
    
    save_dir.close();
    savefile.close();
}

pub fn ReadData() f32 {
    save_dir = cwd.openDir("res/data", .{}) catch std.fs.Dir{ .fd = 0 };
    savefile = save_dir.openFile("savefile.fred", .{ .mode = .read_write }) catch std.fs.File{ .handle = 0 };
    
    const buffer: []u8 = main_mod.allocator.alloc(u8, 1024) catch "";
    defer main_mod.allocator.free(buffer);
    
    const bytes_read = savefile.read(buffer) catch 0;
    const float_as_string = buffer[0..bytes_read];
    const trimmed = std.mem.trimRight(u8, float_as_string, "\n\r \t");
    const parsed_float = std.fmt.parseFloat(f32, trimmed) catch |e| switch (e) {
        error.InvalidCharacter => {
            WriteData(0);
            return 0;
        },
    };
    
    save_dir.close();
    savefile.close();
    
    return parsed_float;
}

