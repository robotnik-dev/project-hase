use godot::{
    classes::{IRigidBody3D, MeshInstance3D, RayCast3D, RigidBody3D},
    global::sign,
    prelude::*,
};

#[derive(GodotClass)]
#[class(init, base=RigidBody3D)]
struct Car {
    #[export]
    #[init(val = array![])]
    crash_detects: Array<Gd<RayCast3D>>,

    #[export]
    #[init(val = array![])]
    wheels: Array<Gd<MeshInstance3D>>,

    #[export]
    #[init(val = 1800.)]
    engine_power: f32,

    #[export]
    #[init(val = 800.)]
    tilt_speed: f32,

    base: Base<RigidBody3D>,
}

#[godot_api]
impl IRigidBody3D for Car {
    fn physics_process(&mut self, delta: f64) {
        let tilt_input = if !self.is_on_floor() {
            self.get_tilt_input()
        } else {
            0.
        };
        let forward_input = if self.is_on_floor() {
            self.get_forward_input()
        } else {
            0.
        };

        let input_direction = Vector3::BACK * forward_input;

        let force = self.engine_power;
        self.base_mut().apply_central_force(input_direction * force);

        let torque = Vector3::RIGHT * self.tilt_speed * tilt_input;
        self.base_mut().apply_torque(torque);

        // crash detection
        if self.is_crashed() {
            self.base_mut().emit_signal("crashed", &[]);
        }

        // rotate wheels manually
        let speed = self.base().get_linear_velocity().length();
        let move_direction = sign(&self.base().get_linear_velocity().z.to_variant()).to::<f32>();
        self.get_wheels().iter_shared().for_each(|mut wheel| {
            wheel.rotate_object_local(Vector3::DOWN, move_direction * (delta as f32) * speed);
        });
    }
}

#[godot_api]
impl Car {
    #[signal]
    fn crashed();

    /// should return a digits between -1.0 (tilt backward) and +1.0 (tilt forward)
    #[func(virtual)]
    fn get_tilt_input(&self) -> f32 {
        0.
    }

    /// should return a digits between -1.0 (backwards) and +1.0 (forward)
    #[func(virtual)]
    fn get_forward_input(&self) -> f32 {
        0.
    }

    fn is_on_floor(&self) -> bool {
        return self.base().get_colliding_bodies().iter_shared().count() > 0;
    }

    fn is_crashed(&self) -> bool {
        self.crash_detects
            .iter_shared()
            .any(|ray| ray.is_colliding())
    }
}
