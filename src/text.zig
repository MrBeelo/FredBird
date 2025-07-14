const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");

pub var montserrat: rl.Font = undefined;

pub fn LoadMontserrat() void {
    montserrat = rl.LoadFontEx("res/font/montserrat.ttf", 100, 0, 0);
}

pub fn UnloadMontserrat() void {
    rl.UnloadFont(montserrat);
}

pub fn DrawMontserratText(text: [*c]const u8, position: rl.Vector2, font_size: f32, tint: rl.Color) void {
    rl.DrawTextEx(montserrat, text, position, font_size, 0, tint);
}

pub fn DrawMontserratTextPro(text: [*c]const u8, position: rl.Vector2, origin: rl.Vector2, rotation: f32, font_size: f32, spacing: f32, tint: rl.Color) void {
    rl.DrawTextPro(montserrat, text, position, origin, rotation, font_size, spacing, tint);
}

pub fn MeasureMontserratText(text: [*c]const u8, font_size: f32) rl.Vector2 {
    return rl.MeasureTextEx(montserrat, text, font_size, 0);
}

pub fn MeasureMontserratTextPro(text: [*c]const u8, font_size: f32, spacing: f32) rl.Vector2 {
    return rl.MeasureTextEx(montserrat, text, font_size, spacing);
}