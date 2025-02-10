use godot::{
    classes::{InputEventKey, InputMap},
    obj::WithBaseField,
    prelude::*,
};

pub enum CustomPlayerInput {
    DriveForward,
    TiltForward,
    TiltBackward,
}

impl CustomPlayerInput {
    fn as_str(&self) -> &'static str {
        match self {
            Self::DriveForward => "drive_forward",
            Self::TiltForward => "tilt_forward",
            Self::TiltBackward => "tilt_backward",
        }
    }
}

#[derive(GodotClass)]
#[class(init, base=Node)]
struct PlayerInput {
    #[export]
    drive_forward: Array<Gd<InputEventKey>>,
    #[export]
    tilt_forward: Array<Gd<InputEventKey>>,
    #[export]
    tilt_backward: Array<Gd<InputEventKey>>,

    base: Base<Node>,
}

#[godot_api]
impl INode for PlayerInput {
    fn ready(&mut self) {
        // setting up inputs
        if !InputMap::singleton().has_action(CustomPlayerInput::DriveForward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::DriveForward.as_str());
            for key in self.drive_forward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::DriveForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(CustomPlayerInput::TiltForward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::TiltForward.as_str());
            for key in self.tilt_forward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::TiltForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(CustomPlayerInput::TiltBackward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::TiltBackward.as_str());
            for key in self.tilt_backward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::TiltBackward.as_str(), &key);
            }
        }
    }

    fn process(&mut self, _delta: f64) {
        if Input::singleton().is_action_pressed("drive_forward") {
            self.base_mut().emit_signal("drive_forward_pressed", &[]);
        }
        if Input::singleton().is_action_pressed("tilt_forward") {
            self.base_mut().emit_signal("tilt_forward_pressed", &[]);
        }
        if Input::singleton().is_action_pressed("tilt_backward") {
            self.base_mut().emit_signal("tilt_backward_pressed", &[]);
        }
    }
}

#[godot_api]
impl PlayerInput {
    #[signal]
    fn drive_forward_pressed();
    #[signal]
    fn tilt_forward_pressed();
    #[signal]
    fn tilt_backward_pressed();
}
