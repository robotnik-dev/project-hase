use std::{fs::OpenOptions, io::Write};

use godot::{
    classes::{Engine, IObject, Object},
    global::godot_error,
    obj::Base,
    prelude::{godot_api, GodotClass},
};
use ron::ser::PrettyConfig;
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, PartialEq, Default)]
struct Level {
    name: String,
    collected_ids: Vec<i32>,
}

impl Level {
    fn new(name: String, id: i32) -> Self {
        Self {
            name,
            collected_ids: vec![id],
        }
    }
}

#[derive(Debug, Deserialize, Serialize, PartialEq, Default)]
struct Save {
    levels: Vec<Level>,
}

impl Save {
    fn new() -> Self {
        Save { levels: vec![] }
    }
}

#[derive(GodotClass)]
#[class(base=Object)]
pub struct SaveGame {
    save: Save,

    base: Base<Object>,
}

#[godot_api]
impl IObject for SaveGame {
    fn init(base: Base<Object>) -> Self {
        Self {
            save: Save::new(),
            base,
        }
    }
}

#[godot_api]
impl SaveGame {
    #[func]
    fn save(&mut self) {
        match ron::ser::to_string_pretty(&self.save, PrettyConfig::new().struct_names(true)) {
            Ok(save) => {
                let mut path = Engine::singleton()
                    .get_singleton("OS")
                    .unwrap()
                    .call("get_user_data_dir", &[])
                    .to_string();
                path.push_str("/savegame.ron");
                if let Ok(mut file) = OpenOptions::new()
                    .create(true)
                    .write(true)
                    .truncate(true)
                    .open(path)
                {
                    if let Err(err) = file.write_all(save.as_bytes()) {
                        godot_error!("Could not save to disk due to: {}", err.to_string())
                    }
                }
            }
            Err(err) => godot_error!(
                "Could not convert save to string due to: {}",
                err.to_string()
            ),
        }
    }

    #[func]
    fn collected_in_level(&mut self, id: i32, level_name: String) {
        let (idx, new_level) = match self
            .save
            .levels
            .iter()
            .enumerate()
            .find(|(_, level)| level.name == level_name)
        {
            Some((i, level)) => {
                let mut new_l = Level::new(level.name.clone(), id);
                if !level.collected_ids.contains(&id) {
                    // update the collected values
                    let mut new_collected = level.collected_ids.clone();
                    new_collected.push(id);
                    new_l.collected_ids = new_collected;
                } else {
                    // already present, take old collected values
                    new_l.collected_ids = level.collected_ids.clone();
                }
                (i as i32, new_l)
            }
            None => (-1i32, Level::new(level_name, id)),
        };

        if idx == -1 {
            self.save.levels.push(new_level);
        } else {
            self.save.levels[idx as usize] = new_level;
        }
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    fn get_save_str() -> &'static str {
        r#"Save(levels:[Level(name:"Level1",collected_ids:[0]),Level(name:"Level2",collected_ids:[])])"#
    }

    fn get_save() -> Save {
        Save {
            levels: vec![
                Level {
                    name: String::from("Level1"),
                    collected_ids: vec![0i32],
                },
                Level {
                    name: String::from("Level2"),
                    collected_ids: vec![],
                },
            ],
        }
    }

    #[test]
    fn load_from_file() {
        let save: Save = ron::from_str(get_save_str()).unwrap();
        let correct_save = get_save();
        assert_eq!(save, correct_save);
    }

    #[test]
    fn save_to_file() {
        let save = ron::ser::to_string_pretty(
            &get_save(),
            PrettyConfig::new()
                .compact_arrays(true)
                .compact_structs(true)
                .struct_names(true)
                .separator(""),
        )
        .unwrap();
        assert_eq!(save, get_save_str())
    }
}
