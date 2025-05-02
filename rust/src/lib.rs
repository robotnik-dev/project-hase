use collectibles::Collectibles;
use content_loader::ContentLoader;
use godot::{classes::Engine, prelude::*};

mod car;
mod collectibles;
mod content_loader;
mod flip_detection;
mod level;
mod player_camera;
mod player_input;

struct GodotRustExtension;

#[gdextension]
unsafe impl ExtensionLibrary for GodotRustExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            Engine::singleton().register_singleton("Collectibles", &Collectibles::new_alloc());
            Engine::singleton().register_singleton("ContentLoader", &ContentLoader::new_alloc());
        }
    }

    fn on_level_deinit(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut engine = Engine::singleton();
            let collectibles = "Collectibles";
            let content_loader = "ContentLoader";

            if let Some(singleton) = engine.get_singleton(collectibles) {
                engine.unregister_singleton(collectibles);
                singleton.free();
            } else {
                godot_error!("Failed to get singleton: {collectibles}");
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
