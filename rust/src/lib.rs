use godot::prelude::*;

struct GodotRustExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GodotRustExtension {}

mod car;
mod flip_detection;
mod level;
mod player_camera;
mod player_input;
