const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");
const timer_mod = @import("timer.zig");

pub const pillar_size = rl.Vector2{.x = 256, .y = 1024};
pub var pillar_texture: rl.Texture2D = undefined;
pub var pillars: std.ArrayList(Pillar) = undefined;
pub var pillar_spawn_timer = timer_mod.Timer{.auto_start = true, .duration = 2, .repeat = true};
pub var wiggle_space: f32 = 300;

pub const Pillar = struct {
    pos: rl.Vector2,
    rect: rl.Rectangle,
    top: bool,
    passed: bool,
    
    pub fn Update(self: *Pillar) void {
        self.pos.x -= main_mod.dt60 * 5 + if(main_mod.time_played / 50 > 5) 5 else main_mod.time_played / 50;
        if(self.pos.x < -pillar_size.x) RemoveLastPillar(&pillars);
        
        self.rect = rl.Rectangle{.x = self.pos.x, .y = self.pos.y, .width = pillar_size.x, .height = pillar_size.y};
    }
    
    pub fn Draw(self: *Pillar) void {
        const flip: f32 = if(self.top) -1 else 1;
        rl.DrawTexturePro(pillar_texture, rl.Rectangle{.x = 0, .y = 0, .width = 64 * flip, .height = 256 * flip}, self.rect, rl.Vector2{.x = 0, .y = 0}, 0, main_mod.game_color);
        if(main_mod.f3On) rl.DrawRectangleLinesEx(self.rect, 5, rl.RED);
    }
};

pub fn LoadPillars() void {
    pillar_texture = rl.LoadTexture("res/sprite/pillar.png");
    pillar_spawn_timer.Init();
}

pub fn UnloadPillars() void {
    rl.UnloadTexture(pillar_texture);
}

pub fn SummonPillars() !void {
    var p1: Pillar = undefined;
    var p2: Pillar = undefined;
    
    p1.pos = rl.Vector2{.x = main_mod.simulation_size.x, .y = @floatFromInt(rl.GetRandomValue(-pillar_size.y, @intFromFloat(-(pillar_size.y - (main_mod.simulation_size.y - wiggle_space)))))};
    p1.rect = undefined;
    p1.top = true;
    p1.passed = false;
    
    p2.pos = rl.Vector2{.x = main_mod.simulation_size.x, .y = p1.pos.y + pillar_size.y + wiggle_space};
    p2.rect = undefined;
    p2.top = false;
    p2.passed = false;
    
    try pillars.append(p1);
    try pillars.append(p2);
}

pub fn UpdatePillars() !void {
    pillar_spawn_timer.Update();
    if(pillar_spawn_timer.call) try SummonPillars();
    for (pillars.items) |*pillar| {
        pillar.Update();
    }
}

pub fn DrawPillars() void {
    for (pillars.items) |*pillar| {
        pillar.Draw();
    }
}

fn RemoveLastPillar(list: *std.ArrayList(Pillar)) void {
    if (list.items.len >= 1) {
        list.items = list.items[1..list.items.len];
    } else {
        list.clearRetainingCapacity();
    }
}