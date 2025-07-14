const std = @import("std");
const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");

pub var jump: rl.Sound = undefined;
pub var hit: rl.Sound = undefined;
pub var music: rl.Music = undefined;

pub fn LoadSounds() void {
    jump = rl.LoadSound("res/sound/jump.wav");
    hit = rl.LoadSound("res/sound/hit.wav");
    music = rl.LoadMusicStream("res/sound/music.mp3");
    
    rl.SetSoundVolume(jump, 0.7);
    rl.SetSoundVolume(hit, 0.7);
    rl.SetMusicVolume(music, 0.4);
}

pub fn UnloadSounds() void {
    rl.UnloadSound(jump);
    rl.UnloadSound(hit);
    rl.UnloadMusicStream(music);
}

pub fn ManageMusic() void {
    rl.UpdateMusicStream(music);
    if(!rl.IsMusicStreamPlaying(music)) rl.PlayMusicStream(music); 
}