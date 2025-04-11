use godot::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::{Path, PathBuf};

const CONTENT_ROOT: &str = "../godot/content";

#[derive(GodotClass)]
#[class(base=Object)]
pub struct ContentLoader {
    grave_texts: GraveTexts,
    base: Base<Object>,
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct GraveTexts {
    pub texts: Vec<String>,
}

#[godot_api]
impl IObject for ContentLoader {
    fn init(base: Base<Object>) -> Self {
        let grave_texts = ContentLoader::load_grave_texts();
        Self { grave_texts, base }
    }
}

#[godot_api]
impl ContentLoader {
    pub fn load_grave_texts() -> GraveTexts {
        let path = PathBuf::from(CONTENT_ROOT).join("grave_texts");

        if !path.exists() {
            godot_error!("Grave Texts content directory not found: {:?}", path);
            return GraveTexts::default();
        }

        if let Ok(entries) = fs::read_dir(&path) {
            if let Some(entry) = entries.last() {
                let path = entry.unwrap().path();
                if path.extension().and_then(|ext| ext.to_str()) == Some("ron") {
                    match ContentLoader::load_grave_texts_from_file(&path) {
                        Ok(texts) => GraveTexts { texts },
                        Err(err) => {
                            godot_error!("Failed to load texts {}", err);
                            GraveTexts::default()
                        }
                    }
                } else {
                    GraveTexts::default()
                }
            } else {
                GraveTexts::default()
            }
        } else {
            GraveTexts::default()
        }
    }

    fn load_grave_texts_from_file(path: &Path) -> Result<Vec<String>, String> {
        match fs::read_to_string(path) {
            Ok(content) => match ron::from_str(&content) {
                Ok(texts) => Ok(texts),
                Err(err) => Err(format!("RON parsing error: {}", err)),
            },
            Err(err) => Err(format!("File reading error: {}", err)),
        }
    }

    #[func]
    pub fn get_grave_texts(&self) -> Array<GString> {
        self.grave_texts
            .texts
            .iter()
            .map(|t| t.to_godot())
            .collect()
    }
}
