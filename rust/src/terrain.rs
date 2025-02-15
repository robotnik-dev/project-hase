use godot::{classes::Path3D, obj::Base, prelude::GodotClass};

#[derive(GodotClass)]
#[class(init, tool, base=Path3D)]
struct Terrain {
    base: Base<Path3D>,
}

// #[godot_api]
// impl IPath3D for Terrain {
//     fn enter_tree(&mut self) {
//     }
// }

// #[godot_api]
// impl Terrain {
//     #[func]
//     fn on_curve_changed(&mut self) {

//     }
// }
