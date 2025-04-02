use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
struct Level {
    name: String,
    collected: Vec<i32>,
}

#[derive(Debug, Deserialize, Serialize)]
struct Save {
    levels: Vec<Level>,
}

fn main() {
    let save: Save = ron::from_str(
        "Save(levels: [Level(name: \"Level1\", collected: [0]), Level(name: \"Level2\", collected: [])])",
    )
    .unwrap();

    println!("RON: {}", ron::to_string(&save).unwrap());

    println!(
        "Pretty RON: {}",
        ron::ser::to_string_pretty(&save, ron::ser::PrettyConfig::default()).unwrap(),
    );
}
