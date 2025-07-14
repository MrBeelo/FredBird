const rl = @cImport({ @cInclude("raylib.h"); });
const main_mod = @import("main.zig");

const Callback = fn () void;

pub const Timer = struct {
    duration: f32,
    start_time: f32 = 0,
    active: bool = false,
    repeat: bool = false,
    auto_start: bool = false,
    call: bool = false,
    grace: f32 = 0.0,
    
    pub fn Init(self: *Timer) void
    {
        if(self.auto_start) self.Activate();
    }
    
    pub fn Activate(self: *Timer) void
    {
        self.active = true;
        self.start_time = @floatCast(rl.GetTime());
    }
    
    pub fn Deactivate(self: *Timer) void
    {
        self.active = false;
        self.start_time = 0;
        if(self.repeat) self.Activate();
    }
    
    pub fn Update(self: *Timer) void {
        if (self.active and (rl.GetTime() - self.start_time >= self.duration)) {
            self.call = true;
            self.grace = 1;
            self.Deactivate();
        }
        
        if(self.grace >= 0.0) self.grace -= 1;
        if(self.call and self.grace < 0.0) self.call = false;
    }
};

