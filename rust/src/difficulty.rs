use godot::{
    classes::{PhysicsMaterial, ResourceLoader},
    prelude::*,
};
//TODO: emitting 'changed' on every change?
const RESOURCE_PATH: &str = "car/difficulties";

#[derive(GodotClass)]
#[class(init, base=Resource)]
pub struct DifficultySetting {
    #[export(range = (0.0, 5000.0, 1.0))]
    #[init(val = 1000.0)]
    boost_power: f32,

    #[export(range = (0.0, 1.0, 0.01))]
    #[init(val = 1.0)]
    boost_fill_speed: f32,

    #[export(range = (0.0, 10000.0, 1.0))]
    #[init(val = 1800.)]
    engine_power: f32,

    #[export(range = (0.0, 10000.0, 1.0))]
    #[init(val = 800.)]
    tilt_speed: f32,

    #[export(range = (0.0, 1000.0, 1.0))]
    #[init(val = 20.)]
    mass: f32,

    #[export(range = (0.0, 100.0, 0.1))]
    #[init(val = 5.)]
    gravity_scale: f32,

    #[export(range = (0.0, 100.0, 0.1))]
    #[init(val = 0.6)]
    linear_damp: f32,

    #[export(range = (0.0, 100.0, 0.1))]
    #[init(val = 1.5)]
    angular_damp: f32,

    #[export]
    physics_material: Option<Gd<PhysicsMaterial>>,

    base: Base<Resource>,
}

#[godot_api]
impl DifficultySetting {
    #[func]
    fn from_index(index: i32) -> Gd<DifficultySetting> {
        let dir = std::fs::read_dir(RESOURCE_PATH).expect("Resource path not valid");
        let file_path = dir
            .filter_map(Result::ok)
            .find(|entry| {
                entry
                    .file_name()
                    .to_str()
                    .map(|name| name.starts_with(&index.to_string()))
                    .unwrap_or(false)
            })
            .map(|entry| entry.path())
            .expect("No file found for given index");

        let resource_path = format!(
            "res://{}/{}",
            RESOURCE_PATH,
            file_path.file_name().unwrap().to_str().unwrap()
        );

        ResourceLoader::singleton()
            .load(&resource_path)
            .expect("Failed to load resource 'DifficultySetting'")
            .cast::<DifficultySetting>()
    }
}
