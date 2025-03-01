use godot::prelude::*;

#[derive(GodotClass)]
#[class(init, base=Node3D)]
struct Level {
    #[export]
    start: Option<Gd<Node3D>>,

    #[export]
    end: Option<Gd<Node3D>>,

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
        let start_pos = start.get_global_position();
        let end_pos = end.get_global_position();

        self.base_mut()
            .emit_signal("start_position_selected", &[start_pos.to_variant()]);
        self.base_mut()
            .emit_signal("end_position_selected", &[end_pos.to_variant()]);
    }
}

#[godot_api]
impl Level {
    #[signal]
    fn start_position_selected(position: Vector3);

    #[signal]
    fn end_position_selected(position: Vector3);
}
