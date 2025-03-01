use core::f64;
use std::f64::consts::PI;

use godot::{
    classes::RigidBody3D,
    global::{fposmod, sign},
    prelude::*,
};

#[derive(GodotClass)]
#[class(init, base=Node3D)]
struct FlipDetection {
    current_count: i64,
    parent: Option<Gd<RigidBody3D>>,
    percentage_flipped: f32,

    base: Base<Node3D>,
}

#[godot_api]
impl INode3D for FlipDetection {
    fn ready(&mut self) {
        let car = self.base().get_parent_node_3d().unwrap();
        self.parent = Some(car.cast());
    }

    fn physics_process(&mut self, _delta: f64) {
        if let Some(car) = &self.parent {
            if !car.get_colliding_bodies().is_empty() {
                self.percentage_flipped = 0.;
                self.current_count = 0;
            } else {
                let sign = sign(&self.base().get_global_rotation().x.to_variant()).to::<f64>();
                let rot_x = self.base().get_global_rotation().x as f64;
                self.percentage_flipped = (fposmod(rot_x, PI * 2.) / (PI * 2.) * sign) as f32;
            }
            godot_print!("{}", self.percentage_flipped);
        }
    }
}

#[godot_api]
impl FlipDetection {
    #[signal]
    fn flipped(direction: StringName, count: i64);
}
