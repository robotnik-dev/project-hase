use core::f64;
use std::f64::consts::PI;

use godot::{
    classes::RigidBody3D,
    global::{absf, fposmod},
    prelude::*,
};

#[derive(GodotClass)]
#[class(init, base=Node3D)]
struct FlipDetection {
    #[export]
    #[init(val = true)]
    #[var(get, set = set_enabled)]
    enabled: bool,

    #[export]
    #[init(val = 0.18)]
    flip_detection_accuracy: f64,

    #[init(val = 0.12)]
    ground_level_accuracy: f64,

    parent: Option<Gd<RigidBody3D>>,

    current_back_flip_count: i64,
    current_front_flip_count: i64,

    percentage_flipped: f64,

    #[var]
    front_flip_progress: f64,

    #[var]
    back_flip_progress: f64,

    front_start_rot_set: bool,
    back_start_rot_set: bool,
    front_start_rot: f64,
    back_start_rot: f64,

    base: Base<Node3D>,
}

#[godot_api]
impl INode3D for FlipDetection {
    fn ready(&mut self) {
        let car = self.base().get_parent_node_3d().unwrap();
        self.parent = Some(car.cast());
        self.set_enabled(self.get_enabled());
        self.base_mut().add_to_group("FlipDetection");
    }

    fn physics_process(&mut self, _delta: f64) {
        if self.is_on_floor() {
            self.reset_flip_count();
        } else {
            // in the air
            if self.is_level_with_ground() {
                if self.front_flip_progress > 1. - self.flip_detection_accuracy {
                    // front flip detected
                    let count = self.increase_front_flip_count();
                    self.flipped("front".into(), count);
                    self.reset_front_flip_progress();
                } else if self.back_flip_progress > 1. - self.flip_detection_accuracy {
                    // back flip detected
                    let count = self.increase_back_flip_count();
                    self.flipped("back".into(), count);
                    self.reset_back_flip_progress();
                }
            } else {
                let rot_x = self.base().get_global_rotation().x as f64;
                let percentage_flipped = fposmod(rot_x, PI * 2.) / (PI * 2.);
                let direction = if percentage_flipped - self.percentage_flipped >= 0. {
                    self.reset_back_flip_progress();
                    self.back_start_rot_set = false;
                    if !self.front_start_rot_set {
                        self.front_start_rot = percentage_flipped;
                        self.front_start_rot_set = true;
                    }
                    "front"
                } else {
                    self.reset_front_flip_progress();
                    self.front_start_rot_set = false;
                    if !self.back_start_rot_set {
                        self.back_start_rot = percentage_flipped;
                        self.back_start_rot_set = true;
                    }
                    "back"
                };
                self.set_flip_progress(percentage_flipped, direction);
                self.percentage_flipped = percentage_flipped;
            }
        }
    }
}

#[godot_api]
impl FlipDetection {
    fn flipped(&mut self, direction: StringName, count: i64) {
        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            signals.callv(
                "emit_car_flipped",
                &Array::from_iter([direction.to_variant(), count.to_variant()]),
            );
        }
    }

    #[func]
    fn set_enabled(&mut self, value: bool) {
        self.enabled = value;
        self.base_mut().set_physics_process(value);
    }

    #[func]
    fn is_on_floor(&self) -> bool {
        if let Some(car) = &self.parent {
            !car.get_colliding_bodies().is_empty()
        } else {
            false
        }
    }

    fn is_level_with_ground(&mut self) -> bool {
        absf(self.base().get_global_rotation().x as f64) < self.ground_level_accuracy
    }

    fn reset_flip_count(&mut self) {
        self.current_back_flip_count = 0;
        self.current_front_flip_count = 0;
    }

    fn increase_back_flip_count(&mut self) -> i64 {
        self.current_back_flip_count += 1;
        self.current_back_flip_count
    }

    fn increase_front_flip_count(&mut self) -> i64 {
        self.current_front_flip_count += 1;
        self.current_front_flip_count
    }

    fn set_flip_progress(&mut self, value: f64, direction: &str) {
        if direction == "back" {
            self.back_flip_progress = (1.0 - value) - (1.0 - self.back_start_rot);
        } else if direction == "front" {
            self.front_flip_progress = value - self.front_start_rot;
        }
    }

    fn reset_back_flip_progress(&mut self) {
        self.back_flip_progress = 0.;
    }

    fn reset_front_flip_progress(&mut self) {
        self.front_flip_progress = 0.;
    }
}
