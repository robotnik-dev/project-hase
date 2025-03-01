use godot::{
    classes::{
        InputEvent, InputEventJoypadButton, InputEventKey, InputMap,
    },
    global::{JoyButton, Key},
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
    drive_forward: Array<Gd<InputEvent>>,

    #[export]
    drive_backward: Array<Gd<InputEvent>>,

    #[export]
    tilt_forward: Array<Gd<InputEvent>>,

    #[export]
    tilt_backward: Array<Gd<InputEvent>>,

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

        let mut a_button = InputEventJoypadButton::new_gd();
        a_button.set_button_index(JoyButton::A);

        let mut b_button = InputEventJoypadButton::new_gd();
        b_button.set_button_index(JoyButton::B);

        let mut r_bumper = InputEventJoypadButton::new_gd();
        r_bumper.set_button_index(JoyButton::RIGHT_SHOULDER);

        let mut l_bumper = InputEventJoypadButton::new_gd();
        l_bumper.set_button_index(JoyButton::LEFT_SHOULDER);

        // Keyboard
        drive_forward.push(&w_key.upcast());
        drive_forward.push(&up_key.upcast());
        drive_backward.push(&s_key.upcast());
        drive_backward.push(&down_key.upcast());
        tilt_forward.push(&d_key.upcast());
        tilt_forward.push(&right_key.upcast());
        tilt_backward.push(&a_key.upcast());
        tilt_backward.push(&left_key.upcast());

        // Controller
        drive_forward.push(&a_button.upcast());
        drive_backward.push(&b_button.upcast());
        tilt_forward.push(&r_bumper.upcast());
        tilt_backward.push(&l_bumper.upcast());

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
