const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const fred_mod = @import("fred.zig");
const timer_mod = @import("timer.zig");
const pillar_mod = @import("pillar.zig");
const text_mod = @import("text.zig");
const bg_mod = @import("background.zig");
const dead_mod = @import("dead_screen.zig");
const main_menu_mod = @import("main_menu_screen.zig");
const savefile_mod = @import("savefile.zig");
const sound_mod = @import("sounds.zig");

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub var dt60: f32 = 0.0;
pub const window_size = rl.Vector2{.x = 1280, .y = 720};
pub const simulation_size = rl.Vector2{.x = 1920, .y = 1080};
pub var f3On: bool = false;
pub var score: f32 = 0;
pub var high_score: f32 = 0;
pub var game_color: rl.Color = rl.WHITE;
pub var buf: [64]u8 = undefined;
pub var fred: fred_mod.Fred = undefined;
pub var should_leave_game: bool = false;
pub var time_played: f32 = 0;

pub const Gamestate = enum {
    PLAYING,
    DEAD,
    MAIN_MENU,
};

pub var gamestate = Gamestate.MAIN_MENU;

pub fn main() anyerror!void {
    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT);
    rl.SetConfigFlags(rl.FLAG_VSYNC_HINT);
    
    rl.InitWindow(window_size.x, window_size.y, "FredBird");
    defer rl.CloseWindow();
    
    rl.InitAudioDevice();
    defer rl.CloseAudioDevice();
    
    rl.SetExitKey(rl.KEY_NULL);
    
    const target: rl.RenderTexture2D = rl.LoadRenderTexture(simulation_size.x, simulation_size.y);
    var scale: f32 = undefined;
    
    rl.SetTextureFilter(target.texture, rl.TEXTURE_FILTER_BILINEAR);
    
    try savefile_mod.InitSavefile();
    high_score = try savefile_mod.ReadData();
    
    text_mod.LoadMontserrat();
    defer text_mod.UnloadMontserrat();
    
    fred_mod.LoadFred();
    defer fred_mod.UnloadFred();
    
    pillar_mod.LoadPillars();
    defer pillar_mod.UnloadPillars();
    
    bg_mod.LoadBackground();
    defer bg_mod.UnloadBackground();
    
    sound_mod.LoadSounds();
    defer sound_mod.UnloadSounds();
    
    pillar_mod.pillars = std.ArrayList(pillar_mod.Pillar).init(allocator);
    defer pillar_mod.pillars.deinit();
    
    bg_mod.backgrounds = std.ArrayList(bg_mod.Background).init(allocator);
    defer bg_mod.backgrounds.deinit();
    
    fred.Reset();

    while (!rl.WindowShouldClose() and !should_leave_game) {
        dt60 = rl.GetFrameTime() * 60;
        if(rl.IsKeyPressed(rl.KEY_F3)) f3On = !f3On;
        scale = @min(window_size.x / simulation_size.x, window_size.y / simulation_size.y);
        
        game_color = if(gamestate != Gamestate.PLAYING) rl.Color{.r = 180, .g = 180, .b = 180, .a = 255} else rl.WHITE;
        
        sound_mod.ManageMusic();
        
        if(gamestate == Gamestate.PLAYING or gamestate == Gamestate.DEAD) try fred.Update();
        if(gamestate == Gamestate.PLAYING or gamestate == Gamestate.MAIN_MENU) try bg_mod.UpdateBackgrounds();
        if(gamestate == Gamestate.MAIN_MENU) main_menu_mod.UpdateMainMenuScreen();
        if(gamestate == Gamestate.DEAD) dead_mod.UpdateDeadScreen();
        
        if(gamestate == Gamestate.PLAYING) {
            try pillar_mod.UpdatePillars();
            time_played += dt60 / 60;
        }
        
        if(target.texture.id != 0) rl.BeginTextureMode(target);
        rl.ClearBackground(rl.WHITE);
        
        bg_mod.DrawBackgrounds();
        
        if(gamestate == Gamestate.PLAYING or gamestate == Gamestate.DEAD)
        {
            pillar_mod.DrawPillars();
            fred.Draw();
        }
        
        if(gamestate == Gamestate.PLAYING) {
            const score_text = try std.fmt.bufPrintZ(&buf, "{d:.0}", .{score});
            const score_text_font_size: f32 = 128;
            text_mod.DrawMontserratText(score_text, rl.Vector2{.x = simulation_size.x / 2 - text_mod.MeasureMontserratText(score_text, score_text_font_size).x / 2, .y = 100}, score_text_font_size, game_color);
            
            var narrator_text: [*c]const u8 = "";
            
            //WARNING: UGLY CODE INCOMING
            if(score >= 10 and score < 15) narrator_text = "Hey.";
            if(score >= 15 and score < 20) narrator_text = "How are you?";
            if(score >= 20 and score < 25) narrator_text = "Doing well?";
            if(score >= 25 and score < 30) narrator_text = "I hope you know that I'm just here to distract you.";
            if(score >= 30 and score < 35) narrator_text = "And when you get to 100 points...";
            if(score >= 35 and score < 40) narrator_text = "There's a secret surprise ;)";
            if(score >= 40 and score < 45) narrator_text = "But you're not getting there.";
            if(score >= 45 and score < 50) narrator_text = "I guess I'll leave for now...";
            if(score >= 75 and score < 76) narrator_text = "English or Spanish?";
            if(score >= 90 and score < 95) narrator_text = "Come on! Almost there!";
            if(score >= 95 and score < 100) narrator_text = "YOU CAN DO IT!!!";
            if(score >= 100 and score < 103) narrator_text = "HAHAHA I LIED! I'M TOO LAZY TO ADD ANYTHING!";
            if(score >= 103 and score < 106) narrator_text = "DID YOU ACTUALLY THINK YOU WERE GONNA GET A SURPRISE?!?";
            if(score >= 106 and score < 110) narrator_text = "Well, I guess that's it...";
            if(score >= 110 and score < 115) narrator_text = "There's nothing else to do...";
            if(score >= 115 and score < 120) narrator_text = "I guess try to reach 500 points?";
            if(score >= 120 and score < 125) narrator_text = "Or you could just find the savefile and edit the ONE number from there.";
            if(score >= 125 and score < 130) narrator_text = "Eh, whatever. Do what you want.";
            if(score >= 130 and score < 135) narrator_text = "Coming back later. Byeeeeeeeee";
            if(score >= 200 and score < 205) narrator_text = "200, huh?";
            if(score >= 205 and score < 210) narrator_text = "Well, here's the deal.";
            if(score >= 210 and score < 215) narrator_text = "And this time I'm not lying.";
            if(score >= 215 and score < 220) narrator_text = "When you reach 500 points...";
            if(score >= 220 and score < 225) narrator_text = "I'm going to tell you ONE thing.";
            if(score >= 225 and score < 230) narrator_text = "And that's it. Understood?";
            if(score >= 230 and score < 235) narrator_text = "Ok, see ya then.";
            if(score >= 500) narrator_text = "GO TOUCH SOME FUCKING GRASS KID";
            
            const narrator_text_font_size = 48;
            text_mod.DrawMontserratText(narrator_text, rl.Vector2{ .x = simulation_size.x / 2 - text_mod.MeasureMontserratText(narrator_text, narrator_text_font_size).x / 2, .y = 700 }, narrator_text_font_size, rl.WHITE);
        }
        
        if(gamestate == Gamestate.DEAD) try dead_mod.DrawDeadScreen();
        if(gamestate == Gamestate.MAIN_MENU) try main_menu_mod.DrawMainMenuScreen();
        
        if(f3On) {
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "FPS: ({d})", .{rl.GetFPS()}), rl.Vector2{.x = 10, .y = 10}, 32, rl.WHITE);
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "Position: ({d:.1}, {d:.1})", .{fred.pos.x, fred.pos.y}), rl.Vector2{.x = 10, .y = 40}, 32, rl.WHITE);
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "Velocity: ({d:.1}, {d:.1})", .{fred.vel.x, fred.vel.y}), rl.Vector2{.x = 10, .y = 70}, 32, rl.WHITE);
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "Pillars: ({d})", .{pillar_mod.pillars.items.len}), rl.Vector2{.x = 10, .y = 100}, 32, rl.WHITE);
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "Fred Rotation Cycle: ({d})", .{fred.rot_cycle}), rl.Vector2{.x = 10, .y = 130}, 32, rl.WHITE);
            text_mod.DrawMontserratText(try std.fmt.bufPrintZ(&buf, "Time Played: ({d:.1})", .{time_played}), rl.Vector2{.x = 10, .y = 160}, 32, rl.WHITE);
        }
        
        if(target.texture.id != 0) rl.EndTextureMode();
        
        rl.BeginDrawing();
        defer rl.EndDrawing();
        
        rl.ClearBackground(rl.BLACK);
        
        rl.DrawTexturePro(target.texture, rl.Rectangle{.x = 0, .y = 0, .width = @floatFromInt(target.texture.width), .height = @floatFromInt(-target.texture.height)}, 
            rl.Rectangle{.x = (window_size.x - simulation_size.x * scale) * 0.5, .y = (window_size.y - simulation_size.y * scale) * 0.5, .width = simulation_size.x * scale, .height = simulation_size.y * scale}, 
            rl.Vector2{.x = 0, .y = 0}, 0.0, rl.WHITE);
    }
}