use godot::{
    builtin::Vector3,
    classes::{IPath3D, Path3D},
    global::godot_print,
    obj::{Base, WithBaseField},
    prelude::{godot_api, GodotClass},
};

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
