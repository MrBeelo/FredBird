const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");
const cwd: std.fs.Dir = std.fs.cwd();
var save_dir: std.fs.Dir = undefined;
var savefile: std.fs.File = undefined;

pub fn InitSavefile() !void {
    cwd.makeDir("res/data") catch |e| switch(e) {
        error.PathAlreadyExists => {},
        else => return e,
    };
    
    save_dir = try cwd.openDir("res/data", .{});
    savefile = try save_dir.createFile("savefile.fred", .{.truncate = true});
    
    save_dir.close();
    savefile.close();
}

pub fn WriteData(number: f32) !void {
    save_dir = try cwd.openDir("res/data", .{});
    savefile = try save_dir.openFile("savefile.fred", .{ .mode = .write_only });
    
    var writer = savefile.writer();
    try writer.print("{d:.0}\n", .{number});
    
    save_dir.close();
    savefile.close();
}

pub fn ReadData() !f32 {
    save_dir = try cwd.openDir("res/data", .{});
    savefile = try save_dir.openFile("savefile.fred", .{ .mode = .read_write });
    
    const buffer = try main_mod.allocator.alloc(u8, 1024);
    defer main_mod.allocator.free(buffer);
    
    const bytes_read = try savefile.read(buffer);
    const float_as_string = buffer[0..bytes_read];
    const trimmed = std.mem.trimRight(u8, float_as_string, "\n\r \t");
    const parsed_float = std.fmt.parseFloat(f32, trimmed) catch |e| switch (e) {
        error.InvalidCharacter => {
            try WriteData(0);
            return 0;
        },
    };
    
    save_dir.close();
    savefile.close();
    
    return parsed_float;
}

