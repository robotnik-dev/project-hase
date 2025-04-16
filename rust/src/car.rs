use godot::{
    classes::{node::ProcessMode, Area3D, IRigidBody3D, RigidBody3D},
    global::sign,
    obj::WithBaseField,
    prelude::*,
};

use crate::player_input::PlayerInput;

#[derive(GodotConvert, Var, Export, Default)]
#[godot(via = GString)]
pub enum Effect {
    #[default]
    Boost,
}

#[derive(GodotClass)]
#[class(init, base=RigidBody3D)]
struct Car {
    #[export]
    #[init(val = None)]
    player_input: Option<Gd<PlayerInput>>,

    #[export]
    collectables_needed_to_unlock: i32,

    #[export]
    #[init(val = None)]
    ui_preview: Option<Gd<PackedScene>>,

    #[export]
    ui_display_name: StringName,

    #[export]
    effect: Effect,

    #[export]
    #[init(val = 1000.0)]
    boost_power: f32,

    #[export]
    #[init(val = 1.0)]
    boost_fill_speed: f32,

    #[export]
    #[init(val = array![])]
    crash_detects: Array<Gd<Area3D>>,

    #[export]
    #[init(val = array![])]
    wheels: Array<Gd<Node3D>>,

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

    last_point_of_contact: Vector3,

    base: Base<RigidBody3D>,
}

#[godot_api]
impl IRigidBody3D for Car {
    fn enter_tree(&mut self) {
        self.base_mut().set_process(false);
        self.base_mut().set_physics_process(false);
    }

    fn ready(&mut self) {
        let _crashed = self.to_gd().callable("crashed");
        for mut area in self.crash_detects.iter_shared() {
            area.connect("area_entered", &_crashed);
            area.connect("body_entered", &_crashed);
        }
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

        // rotate wheels manually
        let velocity = self.base().get_linear_velocity();
        let speed = Vector3::new(velocity.x, 0., velocity.z).length();
        let move_direction = sign(&self.base().get_linear_velocity().z.to_variant()).to::<f32>();
        self.get_wheels().iter_shared().for_each(|mut wheel| {
            wheel.rotate_object_local(Vector3::LEFT, move_direction * (delta as f32) * speed);
        });

        // update the last point of contact for grave spawning
        if self.is_on_floor() {
            self.last_point_of_contact = self.base().get_global_position();
        }
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
    fn effect(&mut self) {
        match self.effect {
            Effect::Boost => {
                let force = self.boost_power;
                let direction = self.get_facing_direction();
                self.base_mut().apply_central_impulse(direction * force);
            }
        }
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

    #[func]
    fn crashed(&mut self, _area_or_body: Variant) {
        // if the collision shape is an area, it means that the crashzone in the abyss triggered the crash
        // because there are no other areas, everything else are bodies
        let abyss = _area_or_body.try_to::<Gd<Area3D>>().is_ok();

        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            signals.call(
                "emit_car_crashed",
                &[
                    self.base().get_global_position().to_variant(),
                    self.last_point_of_contact.to_variant(),
                    abyss.to_variant(),
                ],
            );
            self.base_mut().set_process(false);
            self.base_mut().set_physics_process(false);
            // disable areas for crash detection
            for mut area in self.crash_detects.iter_shared() {
                area.call_deferred("set_process_mode", &[ProcessMode::DISABLED.to_variant()]);
            }
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

    fn get_facing_direction(&self) -> Vector3 {
        let rotation = self.base().get_rotation();
        Vector3::BACK.rotated(Vector3::RIGHT, rotation.x)
    }
}
