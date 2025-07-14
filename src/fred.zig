const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");
const timer_mod = @import("timer.zig");
const pillar_mod = @import("pillar.zig");
const savefile_mod = @import("savefile.zig");
const sound_mod = @import("sounds.zig");

pub var fred_atlas_texture: rl.Texture2D = undefined;
pub const hitbox_buffer: f32 = 15;

pub const Fred = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    vel: rl.Vector2,
    rect: rl.Rectangle,
    hitbox: rl.Rectangle,
    rot_cycle: f32,
    rotate_timer: timer_mod.Timer,
    is_left: bool,
    
    pub fn Reset(self: *Fred) void {
        self.pos = rl.Vector2{.x = 200, .y = main_mod.simulation_size.y / 2 - self.size.y / 2};
        self.size = rl.Vector2{.x = 96, .y = 96};
        self.vel = rl.Vector2{.x = 0, .y = 0};
        self.rect = rl.Rectangle{.x = self.pos.x, .y = self.pos.y, .width = self.size.x, .height = self.size.y};
        self.hitbox = rl.Rectangle{.x = self.pos.x + 15, .y = self.pos.y + 15, .width = self.size.x - 15 * 2, .height = self.size.y - 15 * 2};
        self.rotate_timer = timer_mod.Timer{.auto_start = true, .duration = 0.15, .repeat = true};
        self.is_left = false;
        self.rotate_timer.Init();
        pillar_mod.pillars.clearRetainingCapacity();
        main_mod.score = 0;
        main_mod.time_played = 0;
    }
    
    pub fn Update(self: *Fred) void {
        if(main_mod.gamestate == main_mod.Gamestate.PLAYING)
        {
            self.rotate_timer.Update();
            if(self.rotate_timer.call) self.Rotate();
            if(rl.IsKeyDown(rl.KEY_A)) {
                self.vel.x = -4;
                self.is_left = true;
            } else if(rl.IsKeyDown(rl.KEY_D)) {
                self.vel.x = 4;
                self.is_left = false;
            } else {
                self.vel.x = 0;
            }
            
            if(rl.IsKeyPressed(rl.KEY_SPACE)) {
                self.vel.y = -10;
                rl.PlaySound(sound_mod.jump);
            }
            
            for(pillar_mod.pillars.items) |*pillar| {
                if(self.pos.x > pillar.pos.x + pillar_mod.pillar_size.x and !pillar.passed) {
                    pillar.passed = true;
                    if(pillar.top) main_mod.score += 1;
                }
                
                if(rl.CheckCollisionRecs(self.hitbox, pillar.rect))
                {
                    self.vel = rl.Vector2{.x = 0, .y = 0};
                    main_mod.gamestate = main_mod.Gamestate.DEAD;
                    rl.PlaySound(sound_mod.hit);
                    if(main_mod.score > main_mod.high_score) { 
                        savefile_mod.WriteData(main_mod.score); 
                    }
                    main_mod.high_score = savefile_mod.ReadData();
                }
            }
        }
        
        self.vel.y += main_mod.dt60 / 2;
        
        self.pos.x += self.vel.x * main_mod.dt60;
        self.pos.y += self.vel.y * main_mod.dt60;
        
        if(self.TouchesCeiling() or self.TouchesGround()) self.vel.y = 0;
        
        if(self.TouchesGround()) {
            if(main_mod.gamestate == main_mod.Gamestate.PLAYING) {
                main_mod.gamestate = main_mod.Gamestate.DEAD;
                if(main_mod.score > main_mod.high_score) { 
                    savefile_mod.WriteData(main_mod.score); 
                }
                main_mod.high_score = savefile_mod.ReadData();
                rl.PlaySound(sound_mod.hit);
            }
            
            self.vel.x = 0;
            self.rot_cycle = 0;
        }
        
        self.pos.x = std.math.clamp(self.pos.x, -hitbox_buffer, main_mod.simulation_size.x - self.size.x + hitbox_buffer);
        self.pos.y = std.math.clamp(self.pos.y, -hitbox_buffer, main_mod.simulation_size.y - self.size.y + hitbox_buffer);
        
        self.rect = rl.Rectangle{.x = self.pos.x, .y = self.pos.y, .width = self.size.x, .height = self.size.y};
        self.hitbox = rl.Rectangle{.x = self.pos.x + hitbox_buffer, .y = self.pos.y + hitbox_buffer, .width = self.size.x - hitbox_buffer * 2, .height = self.size.y - hitbox_buffer * 2};
    }
    
    pub fn Draw(self: *Fred) void {
        const eyesOpen: f32 = if(rl.IsKeyDown(rl.KEY_SPACE) and main_mod.gamestate == main_mod.Gamestate.PLAYING) 1.0 else 0.0;
        rl.DrawTexturePro(fred_atlas_texture, rl.Rectangle{.x = 48 * self.rot_cycle, .y = 48 * eyesOpen, .width = 48, .height = 48}, self.rect, rl.Vector2{.x = 0, .y = 0}, 0.0, main_mod.game_color);
        if(main_mod.f3On) {
            rl.DrawRectangleLinesEx(self.rect, 5, rl.RED);
            rl.DrawRectangleLinesEx(self.hitbox, 5, rl.ORANGE);
        } 
    }
    
    pub fn Rotate(self: *Fred) void {
        if(self.is_left) {
            self.rot_cycle += 1;
        } else {
            self.rot_cycle -= 1;
        } 
        
        if(self.rot_cycle >= 4) {
            self.rot_cycle = 0;
        } else if(self.rot_cycle < 0)
        {
            self.rot_cycle = 3;
        }
    }
    
    pub fn TouchesGround(self: *Fred) bool {
        return self.pos.y > main_mod.simulation_size.y - self.size.y + hitbox_buffer;
    }
    
    pub fn TouchesCeiling(self: *Fred) bool {
        return self.pos.y <= -hitbox_buffer;
    }
};

pub fn LoadFred() void {
    fred_atlas_texture = rl.LoadTexture("res/sprite/fred_atlas.png");
}

pub fn UnloadFred() void {
    rl.UnloadTexture(fred_atlas_texture);
}
