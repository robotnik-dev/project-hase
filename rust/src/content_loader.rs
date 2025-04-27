use godot::prelude::*;

const CONTENT_ROOT: &str = "res://content";

#[derive(GodotClass)]
#[class(base=Object)]
pub struct ContentLoader {
    grave_texts: Gd<GraveTexts>,
    base: Base<Object>,
}

#[derive(GodotClass)]
#[class(init, base=Resource)]
pub struct GraveTexts {
    #[export]
    texts: Array<GString>,
    base: Base<Resource>,
}

#[godot_api]
impl IObject for ContentLoader {
    fn init(base: Base<Object>) -> Self {
        let grave_texts = ContentLoader::load_grave_texts();
        Self { grave_texts, base }
    }
}

#[godot_api]
impl ContentLoader {
    pub fn load_grave_texts() -> Gd<GraveTexts> {
        let path = GString::from(format!("{CONTENT_ROOT}/grave_texts/texts.tres"));
        try_load::<GraveTexts>(&path).unwrap_or(GraveTexts::new_gd())
    }

    #[func]
    pub fn get_grave_texts(&self) -> Array<GString> {
        self.grave_texts.bind().get_texts()
    }
}
