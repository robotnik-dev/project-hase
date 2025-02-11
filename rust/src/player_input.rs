use godot::{
    classes::{InputEvent, InputEventKey, InputMap},
    global::Key,
    obj::WithBaseField,
    prelude::*,
};

pub enum CustomPlayerInput {
    DriveForward,
    DriveBackward,
    TiltForward,
    TiltBackward,
}

impl CustomPlayerInput {
    fn as_str(&self) -> &'static str {
        match self {
            Self::DriveForward => "drive_forward",
            Self::DriveBackward => "drive_backward",
            Self::TiltForward => "tilt_forward",
            Self::TiltBackward => "tilt_backward",
        }
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
struct PlayerInput {
    #[export]
    drive_forward: Array<Gd<InputEventKey>>,

    #[export]
    drive_backward: Array<Gd<InputEventKey>>,

    #[export]
    tilt_forward: Array<Gd<InputEventKey>>,

    #[export]
    tilt_backward: Array<Gd<InputEventKey>>,

    base: Base<Node>,
}

#[godot_api]
impl INode for PlayerInput {
    fn init(base: Base<Node>) -> Self {
        // setting up default inputs
        let mut drive_forward = Array::new();
        let mut drive_backward = Array::new();
        let mut tilt_forward = Array::new();
        let mut tilt_backward = Array::new();

        let mut w_key = InputEventKey::new_gd();
        w_key.set_keycode(Key::W);

        let mut a_key = InputEventKey::new_gd();
        a_key.set_keycode(Key::A);

        let mut s_key = InputEventKey::new_gd();
        s_key.set_keycode(Key::S);

        let mut d_key = InputEventKey::new_gd();
        d_key.set_keycode(Key::D);

        let mut up_key = InputEventKey::new_gd();
        up_key.set_keycode(Key::UP);

        let mut left_key = InputEventKey::new_gd();
        left_key.set_keycode(Key::LEFT);

        let mut down_key = InputEventKey::new_gd();
        down_key.set_keycode(Key::DOWN);

        let mut right_key = InputEventKey::new_gd();
        right_key.set_keycode(Key::RIGHT);

        drive_forward.push(&w_key);
        drive_forward.push(&up_key);
        drive_backward.push(&s_key);
        drive_backward.push(&down_key);
        tilt_forward.push(&d_key);
        tilt_forward.push(&right_key);
        tilt_backward.push(&a_key);
        tilt_backward.push(&left_key);

        if !InputMap::singleton().has_action(CustomPlayerInput::DriveForward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::DriveForward.as_str());
            for key in drive_forward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::DriveForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(CustomPlayerInput::DriveBackward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::DriveBackward.as_str());
            for key in drive_backward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::DriveBackward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(CustomPlayerInput::TiltForward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::TiltForward.as_str());
            for key in tilt_forward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::TiltForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(CustomPlayerInput::TiltBackward.as_str()) {
            InputMap::singleton().add_action(CustomPlayerInput::TiltBackward.as_str());
            for key in tilt_backward.iter_shared() {
                InputMap::singleton()
                    .action_add_event(CustomPlayerInput::TiltBackward.as_str(), &key);
            }
        }

        Self {
            drive_forward,
            drive_backward,
            tilt_forward,
            tilt_backward,
            base,
        }
    }
    fn unhandled_input(&mut self, event: Gd<InputEvent>) {
        if event.is_action_pressed("drive_forward") {
            self.base_mut().emit_signal("drive_forward_pressed", &[]);
        } else if event.is_action_released("drive_forward") {
            self.base_mut().emit_signal("drive_forward_released", &[]);
        }

        if event.is_action_pressed("drive_backward") {
            self.base_mut().emit_signal("drive_backward_pressed", &[]);
        } else if event.is_action_released("drive_backward") {
            self.base_mut().emit_signal("drive_backward_released", &[]);
        }

        if event.is_action_pressed("tilt_forward") {
            self.base_mut().emit_signal("tilt_forward_pressed", &[]);
        } else if event.is_action_released("tilt_forward") {
            self.base_mut().emit_signal("tilt_forward_released", &[]);
        }

        if event.is_action_pressed("tilt_backward") {
            self.base_mut().emit_signal("tilt_backward_pressed", &[]);
        } else if event.is_action_released("tilt_backward") {
            self.base_mut().emit_signal("tilt_backward_released", &[]);
        }
    }
}

#[godot_api]
impl PlayerInput {
    #[signal]
    fn drive_forward_pressed();

    #[signal]
    fn drive_forward_released();

    #[signal]
    fn drive_backward_pressed();

    #[signal]
    fn drive_backward_released();

    #[signal]
    fn tilt_forward_pressed();

    #[signal]
    fn tilt_forward_released();

    #[signal]
    fn tilt_backward_pressed();

    #[signal]
    fn tilt_backward_released();
}
