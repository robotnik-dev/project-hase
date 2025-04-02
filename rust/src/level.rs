use godot::prelude::*;

#[derive(GodotClass)]
#[class(init, base=Node3D)]
struct Level {
    #[export]
    #[init(val = 1)]
    /// The ID for the level this Node is in. It has to be unique!
    /// This will be saved on the disk
    level_id: i32,

    #[export]
    start: Option<Gd<Node3D>>,

    #[export]
    end: Option<Gd<Node3D>>,

    #[var]
    start_position: Vector3,

    #[var]
    end_position: Vector3,

    base: Base<Node3D>,
}

#[godot_api]
impl INode3D for Level {
    fn ready(&mut self) {
        let Some(start) = self.get_start() else {
            godot_error!("No scene to a start point specified ");
            return;
        };
        let Some(end) = self.get_end() else {
            godot_error!("No scene to a end point specified ");
            return;
        };
        self.set_start_position(start.get_global_position());
        self.set_end_position(end.get_global_position());
    }
}
