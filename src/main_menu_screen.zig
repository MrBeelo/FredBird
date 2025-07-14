const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const main_mod = @import("main.zig");
const text_mod = @import("text.zig");

pub fn UpdateMainMenuScreen() void {
    if (rl.IsKeyPressed(rl.KEY_SPACE)) {
        main_mod.gamestate = main_mod.Gamestate.PLAYING;
        main_mod.fred.Reset();
    }
    
    if(rl.IsKeyPressed(rl.KEY_ESCAPE)) main_mod.should_leave_game = true;
}

pub fn DrawMainMenuScreen() void {
    const title_text = "FRED BIRD";
    const title_text_font_size = 128;
    text_mod.DrawMontserratText(title_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(title_text, title_text_font_size).x / 2, .y = 200 }, title_text_font_size, rl.WHITE);

    const high_score_text = std.fmt.bufPrintZ(&main_mod.buf, "High Score: {d:.0}", .{main_mod.high_score}) catch "";
    const high_score_text_font_size = 32;
    if(main_mod.high_score > 0) text_mod.DrawMontserratText(high_score_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(high_score_text, high_score_text_font_size).x / 2, .y = 320 }, high_score_text_font_size, rl.WHITE);

    const play_text = "Press space to play!";
    const play_text_font_size = 48;
    text_mod.DrawMontserratText(play_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(play_text, play_text_font_size).x / 2, .y = 700 }, play_text_font_size, rl.WHITE);
    
    const credits_text_1 = "\"Who Likes to Party\" Kevin MacLeod (incompetech.com)";
    const credits_text_2 = "Licensed under Creative Commons: By Attribution 4.0 License";
    const credits_text_3 = "http://creativecommons.org/licenses/by/4.0/";
    const credits_text_font_size: f32 = 24;
    text_mod.DrawMontserratText(credits_text_1, rl.Vector2{ .x = 10, .y = main_mod.simulation_size.y - credits_text_font_size * 3 - 10 }, credits_text_font_size, rl.Color{.r = 255, .g = 255, .b = 255, .a = 100});
    text_mod.DrawMontserratText(credits_text_2, rl.Vector2{ .x = 10, .y = main_mod.simulation_size.y - credits_text_font_size * 2 - 10 }, credits_text_font_size, rl.Color{.r = 255, .g = 255, .b = 255, .a = 100});
    text_mod.DrawMontserratText(credits_text_3, rl.Vector2{ .x = 10, .y = main_mod.simulation_size.y - credits_text_font_size * 1 - 10 }, credits_text_font_size, rl.Color{.r = 255, .g = 255, .b = 255, .a = 100});
    
    const beelo_text = "Made by MrBeelo with Zig and Raylib";
    const beelo_text_font_size: f32 = 24;
    text_mod.DrawMontserratText(beelo_text, rl.Vector2{ .x = main_mod.simulation_size.x - text_mod.MeasureMontserratText(beelo_text, beelo_text_font_size).x - 10, .y = main_mod.simulation_size.y - beelo_text_font_size - 10 }, beelo_text_font_size, rl.Color{.r = 255, .g = 255, .b = 255, .a = 100});
}