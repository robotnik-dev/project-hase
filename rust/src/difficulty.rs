use godot::{classes::ResourceLoader, prelude::*};

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

    #[export(range = (0.0, 1.0, 0.01))]
    #[init(val = 1.)]
    friction: f32,

    #[export]
    #[init(val = false)]
    rough: bool,

    #[export(range = (0.0, 1.0, 0.01))]
    #[init(val = 0.4)]
    bounce: f32,

    #[export]
    #[init(val = false)]
    absorbent: bool,

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

        let setting = ResourceLoader::singleton()
            .load(&resource_path)
            .expect("Failed to load resource 'DifficultySetting'")
            .cast::<DifficultySetting>();

        Gd::from_init_fn(|base| Self {
            boost_power: setting.bind().boost_power,
            boost_fill_speed: setting.bind().boost_fill_speed,
            bounce: setting.bind().bounce,
            absorbent: setting.bind().absorbent,
            angular_damp: setting.bind().angular_damp,
            linear_damp: setting.bind().linear_damp,
            engine_power: setting.bind().engine_power,
            friction: setting.bind().friction,
            tilt_speed: setting.bind().tilt_speed,
            mass: setting.bind().mass,
            gravity_scale: setting.bind().gravity_scale,
            rough: setting.bind().rough,
            base,
        })
    }
}
