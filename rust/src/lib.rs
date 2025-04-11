use content_loader::ContentLoader;
use godot::{classes::Engine, prelude::*};
use savegame::SaveGame;

mod car;
mod content_loader;
mod flip_detection;
mod level;
mod player_camera;
mod player_input;
mod savegame;

struct GodotRustExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GodotRustExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            Engine::singleton().register_singleton("SaveGame", &SaveGame::new_alloc());
            Engine::singleton().register_singleton("ContentLoader", &ContentLoader::new_alloc());
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut engine = Engine::singleton();
            let savegame = "SaveGame";
            let content_loader = "ContentLoader";

            if let Some(singleton) = engine.get_singleton(savegame) {
                engine.unregister_singleton(savegame);
                singleton.free();
            } else {
                godot_error!("Failed to get singleton: {savegame}");
            }

            if let Some(singleton) = engine.get_singleton(content_loader) {
                engine.unregister_singleton(content_loader);
                singleton.free();
            } else {
                godot_error!("Failed to get singleton: {content_loader}");
            }
        }
    }
}
