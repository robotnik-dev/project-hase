use godot::prelude::*;

struct GodotRustExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GodotRustExtension {}

mod player_camera;
mod player_input;
