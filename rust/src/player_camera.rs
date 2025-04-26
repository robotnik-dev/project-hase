use godot::{
    builtin::{Variant, Vector3},
    classes::{camera_3d::ProjectionType, Camera3D, ICamera3D, Node3D},
    meta::ToGodot,
    obj::{Base, Gd, WithBaseField},
    prelude::{godot_api, GodotClass},
};

#[derive(GodotClass)]
#[class(init, tool, base=Camera3D)]
struct PlayerCamera {
    /// Node3D to follow
    #[export]
    follow: Option<Gd<Node3D>>,

    /// How far away the camera appears to be.
    #[export(range = (5., 500., 0.1))]
    #[var(get, set = set_distance)]
    #[init(val = 20.0)]
    distance: f32,

    /// How high or low the camera appears to be.
    #[export(range = (-25., 25., 0.1))]
    #[var(get, set = set_height)]
    #[init(val = 0.0)]
    height: f32,

    base: Base<Camera3D>,
}

#[godot_api]
impl ICamera3D for PlayerCamera {
    fn ready(&mut self) {
        self.base_mut()
            .set_rotation_degrees(Vector3::new(0., -90., 0.));
        self.base_mut().set_as_top_level(true);
        self.base_mut().make_current();
        self.base_mut().set_projection(ProjectionType::ORTHOGONAL);
        self.set_distance(self.get_distance());
        self.set_height(self.get_height());
        self.base_mut().add_to_group("PlayerCamera");
        self.base_mut().set_cull_mask_value(4, false);

        if self.base().is_current() {
            if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
                signals.call("emit_camera_loaded", &[]);
            }
        };

        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            let cb = self.to_gd().callable("on_car_crashed");
            signals.call("connect_car_crashed", &[cb.to_variant()]);
        };
    }

    fn process(&mut self, _delta: f64) {
        if let Some(follow) = self.get_follow() {
            let mut target_pos = follow.get_global_position();
            let current_pos = self.base().get_global_position();
            target_pos.x = current_pos.x;

            self.base_mut().set_global_position(target_pos);
        }
    }
}

#[godot_api]
impl PlayerCamera {
    #[func]
    fn on_car_crashed(&mut self, _pos: Variant, _last_poc: Variant, abyss: Variant) {
        self.base_mut().set_process(false);

        // conditionally, move the cam only when the car crashed through the fall in the abyss
        if abyss.to::<bool>() {
            let cam_pos = self.base().get_global_position();
            let cam = &self.to_gd();
            if let Some(mut tween) = self.base_mut().create_tween() {
                let mut pos = _last_poc.to::<Vector3>();
                pos.x = cam_pos.x;
                tween.tween_property(cam, "global_position", &pos.to_variant(), 1.0);
            }
        }
    }

    #[func]
    fn set_distance(&mut self, value: f32) {
        let new_distance = value;
        self.distance = new_distance;
        self.base_mut().set_size(new_distance);
        let mut global_pos = self.base().get_global_position();
        global_pos.x = -new_distance;
        self.base_mut().set_global_position(global_pos);
    }
    #[func]
    fn set_height(&mut self, value: f32) {
        let new_height = value;
        self.height = new_height;
        self.base_mut().set_v_offset(new_height);
    }
}
