use godot::{
    builtin::Array,
    classes::{IObject, Object},
    meta::ToGodot,
    obj::Base,
    prelude::{godot_api, GodotClass},
};
use serde::{Deserialize, Serialize};

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

#[derive(GodotClass)]
#[class(base=Object)]
pub struct Collectibles {
    levels: Vec<Level>,

    base: Base<Object>,
}

#[godot_api]
impl IObject for Collectibles {
    fn init(base: Base<Object>) -> Self {
        Self {
            levels: vec![],
            base,
        }
    }
}

#[godot_api]
impl Collectibles {
    #[func]
    fn get_collected_for_level(&self, level_id: i32) -> Array<i32> {
        match self.levels.iter().find(|l| l.id == level_id) {
            Some(level) => level.collected_ids.to_godot(),
            None => Array::new(),
        }
    }

    #[func]
    fn get_sum_of_collected(&self) -> i32 {
        self.levels
            .iter()
            .fold(0, |acc, l| acc + l.collected_ids.len() as i32)
    }

    #[func]
    fn collected_in_level(&mut self, id: i32, level_id: i32) {
        let (idx, new_level) = match self
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
            self.levels.push(new_level);
        } else {
            self.levels[idx as usize] = new_level;
        }
    }
}
