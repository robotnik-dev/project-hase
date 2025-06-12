#!/bin/bash

# Configuration
RUST_SRC_DIR="rust/src"
GDEXTENSION_FILE="godot/Project.gdextension"
ICON_FILENAME="RustNode.svg"

# Check if rust source directory exists
if [ ! -d "$RUST_SRC_DIR" ]; then
    echo "Error: Directory '$RUST_SRC_DIR' does not exist"
    exit 1
fi

# Check if .gdextension file exists
if [ ! -f "$GDEXTENSION_FILE" ]; then
    echo "Error: File '$GDEXTENSION_FILE' does not exist"
    exit 1
fi

echo "Searching for GodotClass structs in $RUST_SRC_DIR..."

# Find all Rust files and search for structs with #[derive(...GodotClass...)]
struct_names=()

while IFS= read -r -d '' file; do
    echo "Checking file: $file"
    
    # Use awk to find derive macros with GodotClass and the subsequent struct
    struct_in_file=$(awk '
        /^[[:space:]]*#\[derive\(.*GodotClass.*\)\]/ { 
            found_derive = 1
            next
        }
        found_derive && /^[[:space:]]*#\[/ {
            # Skip other attributes
            next
        }
        found_derive && /^[[:space:]]*pub[[:space:]]+struct[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)/ {
            match($0, /struct[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)/, arr)
            if (arr[1]) {
                print arr[1]
            }
            found_derive = 0
            next
        }
        found_derive && /^[[:space:]]*struct[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)/ {
            match($0, /struct[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)/, arr)
            if (arr[1]) {
                print arr[1]
            }
            found_derive = 0
            next
        }
        /^[[:space:]]*struct/ {
            found_derive = 0
        }
        !/^[[:space:]]*#/ && !/^[[:space:]]*$/ && !/^[[:space:]]*\/\// {
            found_derive = 0
        }
    ' "$file")
    
    # Add found struct names to array
    if [ -n "$struct_in_file" ]; then
        while IFS= read -r struct_name; do
            if [ -n "$struct_name" ]; then
                struct_names+=("$struct_name")
                echo "Found struct: $struct_name in $file"
            fi
        done <<< "$struct_in_file"
    fi
    
done < <(find "$RUST_SRC_DIR" -name "*.rs" -type f -print0)

if [ ${#struct_names[@]} -eq 0 ]; then
    echo "No structs implementing GodotClass found."
    exit 0
fi

echo "Found ${#struct_names[@]} struct(s) implementing GodotClass:"
printf '%s\n' "${struct_names[@]}"

# Check if [icons] section exists
if grep -q "^\[icons\]" "$GDEXTENSION_FILE"; then
    echo "[icons] section found, updating..."
    
    # Create temporary file for processing
    temp_file=$(mktemp)
    
    # Process the file
    awk -v struct_names="${struct_names[*]}" -v icon_file="$ICON_FILENAME" '
    BEGIN {
        split(struct_names, structs, " ")
        in_icons_section = 0
        icons_section_processed = 0
    }
    
    /^\[icons\]/ {
        print $0
        in_icons_section = 1
        icons_section_processed = 1
        
        # Add all struct entries after [icons] header
        for (i in structs) {
            if (structs[i] != "") {
                print structs[i] " = \"res://" icon_file "\""
            }
        }
        next
    }
    
    /^\[.*\]/ && in_icons_section {
        in_icons_section = 0
    }
    
    # Skip existing icon entries in [icons] section
    in_icons_section && /^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/ {
        next
    }
    
    {
        print $0
    }
    ' "$GDEXTENSION_FILE" > "$temp_file"
    
    mv "$temp_file" "$GDEXTENSION_FILE"
    
else
    echo "[icons] section not found, adding at the end..."
    
    # Add [icons] section at the end of file
    echo "" >> "$GDEXTENSION_FILE"
    echo "[icons]" >> "$GDEXTENSION_FILE"
    
    for struct_name in "${struct_names[@]}"; do
        echo "$struct_name = \"res://assets/$ICON_FILENAME\"" >> "$GDEXTENSION_FILE"
    done
fi

echo "Successfully updated $GDEXTENSION_FILE"
echo "Added icons for: ${struct_names[*]}"
echo ""
echo "Changes made:"
for struct_name in "${struct_names[@]}"; do
    echo "  $struct_name = \"res://assets/$ICON_FILENAME\""
done