use godot::{
    classes::{IRigidBody3D, MeshInstance3D, RayCast3D, RigidBody3D},
    global::sign,
    obj::WithBaseField,
    prelude::*,
};

use crate::player_input::PlayerInput;

#[derive(GodotClass)]
#[class(init, base=RigidBody3D)]
struct Car {
    #[export]
    #[init(val = None)]
    player_input: Option<Gd<PlayerInput>>,

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

    #[init(val = Vector3 { x: 0.0, y: 0.0, z: 999.0 })]
    end_position: Vector3,

    tilt_direction: f32,

    drive_direction: f32,

    base: Base<RigidBody3D>,
}

#[godot_api]
impl IRigidBody3D for Car {
    fn enter_tree(&mut self) {
        self.base_mut().set_process(false);
        self.base_mut().set_physics_process(false);
    }

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
            self.crashed();
        }

        // rotate wheels manually
        let velocity = self.base().get_linear_velocity();
        let speed = Vector3::new(velocity.x, 0., velocity.z).length();
        let move_direction = sign(&self.base().get_linear_velocity().z.to_variant()).to::<f32>();
        self.get_wheels().iter_shared().for_each(|mut wheel| {
            wheel.rotate_object_local(Vector3::DOWN, move_direction * (delta as f32) * speed);
        });
    }

    fn process(&mut self, _delta: f64) {
        let car_pos = self.base().get_global_position();
        let end_pos = self.end_position;
        if end_pos.z - car_pos.z <= 0.1 {
            self.finished();
            self.base_mut().set_process(false);
        }
    }
}

#[godot_api]
impl Car {
    #[func]
    fn setup(&mut self, start: Vector3, end: Vector3) {
        self.base_mut().set_global_position(start);
        self.end_position = end;

        // connecting signals
        let _on_drive_forward_pressed = &self.to_gd().callable("_on_drive_forward_pressed");
        let _on_drive_forward_released = &self.to_gd().callable("_on_drive_forward_released");
        let _on_drive_backward_pressed = &self.to_gd().callable("_on_drive_backward_pressed");
        let _on_drive_backward_released = &self.to_gd().callable("_on_drive_backward_released");
        let _on_tilt_forward_pressed = &self.to_gd().callable("_on_tilt_forward_pressed");
        let _on_tilt_forward_released = &self.to_gd().callable("_on_tilt_forward_released");
        let _on_tilt_backward_pressed = &self.to_gd().callable("_on_tilt_backward_pressed");
        let _on_tilt_backward_released = &self.to_gd().callable("_on_tilt_backward_released");
        if let Some(input) = self.player_input.as_mut() {
            input.connect("drive_forward_pressed", _on_drive_forward_pressed);
            input.connect("drive_forward_released", _on_drive_forward_released);
            input.connect("drive_backward_pressed", _on_drive_backward_pressed);
            input.connect("drive_backward_released", _on_drive_backward_released);
            input.connect("tilt_forward_pressed", _on_tilt_forward_pressed);
            input.connect("tilt_forward_released", _on_tilt_forward_released);
            input.connect("tilt_backward_pressed", _on_tilt_backward_pressed);
            input.connect("tilt_backward_released", _on_tilt_backward_released);
        }

        self.base_mut().set_physics_process(true);
        self.base_mut().set_process(true);
    }

    #[func]
    fn _on_drive_forward_pressed(&mut self) {
        self.drive_direction = 1.0;
    }

    #[func]
    fn _on_drive_forward_released(&mut self) {
        self.drive_direction = 0.0;
    }

    #[func]
    fn _on_drive_backward_pressed(&mut self) {
        self.drive_direction = -1.0;
    }

    #[func]
    fn _on_drive_backward_released(&mut self) {
        self.drive_direction = 0.0;
    }

    #[func]
    fn _on_tilt_forward_pressed(&mut self) {
        self.tilt_direction = 1.0;
    }

    #[func]
    fn _on_tilt_forward_released(&mut self) {
        self.tilt_direction = 0.0;
    }

    #[func]
    fn _on_tilt_backward_pressed(&mut self) {
        self.tilt_direction = -1.0;
    }

    #[func]
    fn _on_tilt_backward_released(&mut self) {
        self.tilt_direction = 0.0;
    }

    fn crashed(&mut self) {
        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            signals.call("emit_car_crashed", &[]);
        }
    }

    fn finished(&mut self) {
        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            signals.call("emit_car_finished", &[]);
        }
    }

    /// should return a digits between -1.0 (tilt backward) and +1.0 (tilt forward)
    #[func]
    fn get_tilt_input(&self) -> f32 {
        self.tilt_direction
    }

    /// should return a digits between -1.0 (backwards) and +1.0 (forward)
    #[func]
    fn get_forward_input(&self) -> f32 {
        self.drive_direction
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
