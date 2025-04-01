use std::{
    fs::OpenOptions,
    io::{Read, Write},
};

use godot::{
    builtin::Array,
    classes::{Engine, IObject, Object},
    global::{godot_error, godot_print},
    meta::ToGodot,
    obj::Base,
    prelude::{godot_api, GodotClass},
};
use ron::ser::PrettyConfig;
use serde::{Deserialize, Serialize};

const FILENAME: &str = "savegame.ron";

#[derive(Debug, Deserialize, Serialize, PartialEq, Default, Clone)]
struct Level {
    id: i32,
    collected_ids: Vec<i32>,
}

impl Level {
    fn new(id: i32, collected_id: i32) -> Self {
        Self {
            id,
            collected_ids: vec![collected_id],
        }
    }
}

#[derive(Debug, Deserialize, Serialize, PartialEq, Default, Clone)]
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
                path.push_str(format!("/{}", FILENAME).as_str());
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
    fn load(&mut self) {
        let mut path = Engine::singleton()
            .get_singleton("OS")
            .unwrap()
            .call("get_user_data_dir", &[])
            .to_string();
        path.push_str(format!("/{}", FILENAME).as_str());

        if let Ok(mut file) = OpenOptions::new().read(true).open(path.clone()) {
            let mut buf = String::new();
            if let Err(err) = file.read_to_string(&mut buf) {
                godot_error!("Could not read file: {path} due to {err}")
            } else {
                match ron::from_str::<Save>(buf.as_str()) {
                    Ok(save) => {
                        godot_print!("Loaded file: {path} with content: {save:?}");
                        self.save = save;
                    }
                    Err(err) => {
                        godot_error!("Could not generate Save from this file: {path} due to {err}")
                    }
                }
            }
        } else {
            godot_print!("No savegame exists at path: {path}");
        }
    }

    #[func]
    fn get_collected_for_level(&self, level_id: i32) -> Array<i32> {
        match self.save.levels.iter().find(|l| l.id == level_id) {
            Some(level) => level.collected_ids.to_godot(),
            None => Array::new(),
        }
    }

    #[func]
    fn get_sum_of_collected(&self) -> i32 {
        self.save
            .levels
            .iter()
            .fold(0, |acc, l| acc + l.collected_ids.len() as i32)
    }

    #[func]
    fn collected_in_level(&mut self, id: i32, level_id: i32) {
        let (idx, new_level) = match self
            .save
            .levels
            .iter()
            .enumerate()
            .find(|(_, level)| level.id == level_id)
        {
            Some((i, level)) => {
                let mut new_l = Level::new(level.id, id);
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
            None => (-1i32, Level::new(level_id, id)),
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
        r#"Save(levels:[Level(id:1,collected_ids:[0]),Level(id:2,collected_ids:[])])"#
    }

    fn get_save() -> Save {
        Save {
            levels: vec![
                Level {
                    id: 1,
                    collected_ids: vec![0i32],
                },
                Level {
                    id: 2,
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
