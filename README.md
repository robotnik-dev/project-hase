# Godot-Rust template

![Tested](https://github.com/robotnik-dev/rust-godot-template/actions/workflows/ci.yaml/badge.svg)
![Deployed](https://github.com/robotnik-dev/rust-godot-template/actions/workflows/cd.yaml/badge.svg)

A setup to build a Godot 4 app with rust bindings.
> To run the game you need to follow the [setup](#setup) guide even if you dont touch the rust files at all.

# Setup
## Windows
Make sure you have the following installed
- Godot 4.3
- VSCode
- rust (via rustup)

1. After downloading Godot, extract the contents to the following path (rename Godot folder and executable):

    C:\Program Files\Godot\Godot.exe

    > This is important so that VSCode can find the godot executable.
2. Open this folder in VSCode and install all recommended extensions (you should be asked automatically at startup)
3. Build the project once with the shortcut "CTRL+SHIFT+B" and select "godot-rust: Build Debug"
4. Build it again in release mode: "CTRL+SHIFT+B" and select "godot-rust: Build Release"
5. Now you can close VSCode and open the game via the godot launcher

# CI
Builds and exports the game after each push.

# CD
1. For the CD pipeline to run you have to push a new tag in the format

        v*.*.*

    The same tag will be used to deploy the game to different platforms.

2. Set the following repository variable and secrets
    
    vars:

        ITCHIO_GAMENAME
    
    secrets:

        BUTLER_API_KEY
        DOCKER_HUB_PASSWORD
        ITCHIO_USERNAME
