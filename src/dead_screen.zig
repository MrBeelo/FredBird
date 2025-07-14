const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const main_mod = @import("main.zig");
const text_mod = @import("text.zig");

pub fn UpdateDeadScreen() void {
    if (rl.IsKeyPressed(rl.KEY_SPACE)) {
        main_mod.gamestate = main_mod.Gamestate.PLAYING;
        main_mod.fred.Reset();
    }
    if (rl.IsKeyPressed(rl.KEY_ESCAPE)) main_mod.gamestate = main_mod.Gamestate.MAIN_MENU;
}

pub fn DrawDeadScreen() !void {
    const death_text = "You died.";
    const death_text_font_size = 128;
    text_mod.DrawMontserratText(death_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(death_text, death_text_font_size).x / 2, .y = 200 }, death_text_font_size, rl.WHITE);

    const score_text = try std.fmt.bufPrintZ(&main_mod.buf, "Score: {d:.0}", .{main_mod.score});
    const score_text_font_size = 32;
    text_mod.DrawMontserratText(score_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(score_text, score_text_font_size).x / 2, .y = 320 }, score_text_font_size, rl.WHITE);

    const highScore_text = try std.fmt.bufPrintZ(&main_mod.buf, "High Score: {d:.0}", .{main_mod.high_score});
    const highScore_text_font_size = 32;
    text_mod.DrawMontserratText(highScore_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(highScore_text, highScore_text_font_size).x / 2, .y = 350 }, highScore_text_font_size, rl.WHITE);

    const playAgain_text = "Press space to play again.";
    const playAgain_text_font_size = 48;
    text_mod.DrawMontserratText(playAgain_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(playAgain_text, playAgain_text_font_size).x / 2, .y = 700 }, playAgain_text_font_size, rl.WHITE);
    
    const back_text = "Press escape to go back to main menu.";
    const back_text_font_size = 48;
    text_mod.DrawMontserratText(back_text, rl.Vector2{ .x = main_mod.simulation_size.x / 2 - text_mod.MeasureMontserratText(back_text, back_text_font_size).x / 2, .y = 760 }, back_text_font_size, rl.WHITE);
}
