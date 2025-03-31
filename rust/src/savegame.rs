use godot::{
    builtin::StringName,
    classes::{IObject, Object},
    global::godot_print,
    obj::Base,
    prelude::{godot_api, GodotClass},
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, PartialEq, Default)]
struct Level {
    name: String,
    collected: Vec<i32>,
}

impl Level {
    fn new(name: String, id: i32) -> Self {
        Self {
            name,
            collected: vec![id],
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
    fn save_game() {
        godot_print!("saving");
    }

    #[func]
    fn collected_for_level(&mut self, id: i32, level_name: StringName) {
        let (idx, new_level) = match self
            .save
            .levels
            .iter()
            .enumerate()
            .find(|(_, level)| level.name == level_name.to_string())
        {
            Some((i, level)) => {
                let mut new_l = Level::new(level.name.clone(), id);
                if !level.collected.contains(&id) {
                    // update the collected values
                    let mut new_collected = level.collected.clone();
                    new_collected.push(id);
                    new_l.collected = new_collected;
                } else {
                    // already present, take old collected values
                    new_l.collected = level.collected.clone();
                }
                (i as i32, new_l)
            }
            None => (-1i32, Level::new(level_name.to_string(), id)),
        };

        godot_print!("Collected for {new_level:?}");
        godot_print!("{:?}", self.save);

        if idx == -1 {
            self.save.levels.push(new_level);
        } else {
            self.save.levels[idx as usize] = new_level;
        }

        godot_print!("{:?}", self.save);
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    fn get_save_str() -> &'static str {
        "(levels:[(name:\"Level1\",collected:[0]),(name:\"Level2\",collected:[])])"
    }

    fn get_save() -> Save {
        Save {
            levels: vec![
                Level {
                    name: String::from("Level1"),
                    collected: vec![0i32],
                },
                Level {
                    name: String::from("Level2"),
                    collected: vec![],
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
        let save = ron::ser::to_string(&get_save()).unwrap();
        assert_eq!(save, get_save_str())
    }
}
