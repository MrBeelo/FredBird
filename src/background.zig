const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");
const timer_mod = @import("timer.zig");

pub const background_size = rl.Vector2{.x = 1920, .y = 1088};
pub var background_texture: rl.Texture2D = undefined;
pub var backgrounds: std.ArrayList(Background) = undefined;

pub const Background = struct {
    pos: rl.Vector2,
    rect: rl.Rectangle,
    
    pub fn Update(self: *Background) void {
        self.pos.x -= main_mod.dt60 * 1;
        if(self.pos.x < -background_size.x) RemoveLastBackground(&backgrounds);
        
        self.rect = rl.Rectangle{.x = self.pos.x, .y = self.pos.y, .width = background_size.x, .height = background_size.y};
    }
    
    pub fn Draw(self: *Background) void {
        rl.DrawTexturePro(background_texture, rl.Rectangle{.x = 0, .y = 0, .width = 1920, .height = 1088}, self.rect, rl.Vector2{.x = 0, .y = 0}, 0, rl.Color{.r = main_mod.game_color.r - 155, .g = main_mod.game_color.g - 155, .b = main_mod.game_color.b - 155, .a = 255});
    }
};

pub fn LoadBackground() void {
    background_texture = rl.LoadTexture("res/sprite/bg.png");
}

pub fn UnloadBackground() void {
    rl.UnloadTexture(background_texture);
}

pub fn SummonInitialBackground() void {
    var bg: Background = undefined;
    
    bg.pos = rl.Vector2{.x = 0, .y = 0};
    bg.rect = undefined;
    
    backgrounds.append(bg) catch {};
}

pub fn SummonSecondaryBackground() void {
    var bg: Background = undefined;
    
    bg.pos = rl.Vector2{.x = main_mod.simulation_size.x - 10, .y = 0};
    bg.rect = undefined;
    
    backgrounds.append(bg) catch {};
}

pub fn UpdateBackgrounds() void {
    for (backgrounds.items) |*background| {
        background.Update();
    }
    
    if(backgrounds.items.len <= 0) SummonInitialBackground();
    if(backgrounds.items.len <= 1) SummonSecondaryBackground();
}

pub fn DrawBackgrounds() void {
    for (backgrounds.items) |*background| {
        background.Draw();
    }
}

fn RemoveLastBackground(list: *std.ArrayList(Background)) void {
    if (list.items.len >= 1) {
        list.items = list.items[1..list.items.len];
    } else {
        list.clearRetainingCapacity();
    }
}