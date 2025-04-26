use godot::{
    classes::{InputEvent, InputEventJoypadButton, InputEventKey, InputMap},
    global::{JoyButton, Key},
    obj::WithBaseField,
    prelude::*,
};

#[derive(GodotConvert, Export, Var)]
#[godot(via = GString)]
enum PlayerInputKey {
    DriveForward,
    DriveBackward,
    TiltForward,
    TiltBackward,
}

impl PlayerInputKey {
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
#[class(tool, base=Node)]
/// Custom Input Class made for quick access and change the keybindings for a specific set of events in the Editor.
/// It is designed to be used with the associated signals only.
///
/// To change the keybindings for a specific event. just press `Configure` for any `InputEventKey` in the Inspector
pub struct PlayerInput {
    /// List of keybindings that trigger the `drive_forward` signal
    #[export]
    drive_forward: Array<Gd<InputEvent>>,

    /// List of keybindings that trigger the `drive_backward` signal
    #[export]
    drive_backward: Array<Gd<InputEvent>>,

    /// List of keybindings that trigger the `tilt_forward` signal
    #[export]
    tilt_forward: Array<Gd<InputEvent>>,

    /// List of keybindings that trigger the `tilt_backward` signal
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

        Self {
            drive_forward,
            drive_backward,
            tilt_forward,
            tilt_backward,
            base,
        }
    }

    fn ready(&mut self) {
        if !InputMap::singleton().has_action(PlayerInputKey::DriveForward.as_str()) {
            InputMap::singleton().add_action(PlayerInputKey::DriveForward.as_str());
            for key in self.get_drive_forward().iter_shared() {
                InputMap::singleton().action_add_event(PlayerInputKey::DriveForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(PlayerInputKey::DriveBackward.as_str()) {
            InputMap::singleton().add_action(PlayerInputKey::DriveBackward.as_str());
            for key in self.get_drive_backward().iter_shared() {
                InputMap::singleton()
                    .action_add_event(PlayerInputKey::DriveBackward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(PlayerInputKey::TiltForward.as_str()) {
            InputMap::singleton().add_action(PlayerInputKey::TiltForward.as_str());
            for key in self.get_tilt_forward().iter_shared() {
                InputMap::singleton().action_add_event(PlayerInputKey::TiltForward.as_str(), &key);
            }
        }

        if !InputMap::singleton().has_action(PlayerInputKey::TiltBackward.as_str()) {
            InputMap::singleton().add_action(PlayerInputKey::TiltBackward.as_str());
            for key in self.get_tilt_backward().iter_shared() {
                InputMap::singleton().action_add_event(PlayerInputKey::TiltBackward.as_str(), &key);
            }
        }

        if let Some(mut signals) = self.base().get_node_or_null("/root/Signals") {
            let cb = self.to_gd().callable("on_car_crashed");
            signals.call("connect_car_crashed", &[cb.to_variant()]);
        };
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
    #[func]
    /// Disable playerinput when car crashed
    fn on_car_crashed(&mut self, _pos: Variant, _last_poc: Variant, _abyss: Variant) {
        self.base_mut().set_process_unhandled_input(false);
    }

    /// Emitted on `unhandled_input` event for `is_action_pressed` and the event `drive_forward`
    #[signal]
    fn drive_forward_pressed();

    /// Emitted on `unhandled_input` event for `is_action_released` and the event `drive_forward`
    #[signal]
    fn drive_forward_released();

    /// Emitted on `unhandled_input` event for `is_action_pressed` and the event `drive_backward`
    #[signal]
    fn drive_backward_pressed();

    /// Emitted on `unhandled_input` event for `is_action_released` and the event `drive_backward`
    #[signal]
    fn drive_backward_released();

    /// Emitted on `unhandled_input` event for `is_action_pressed` and the event `tilt_forward`
    #[signal]
    fn tilt_forward_pressed();

    /// Emitted on `unhandled_input` event for `is_action_released` and the event `tilt_forward`
    #[signal]
    fn tilt_forward_released();

    /// Emitted on `unhandled_input` event for `is_action_pressed` and the event `tilt_backward`
    #[signal]
    fn tilt_backward_pressed();

    /// Emitted on `unhandled_input` event for `is_action_released` and the event `tilt_backward`
    #[signal]
    fn tilt_backward_released();
}
