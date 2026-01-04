# Shader Playground 🎨

High-performance GPU shader rendering with Flutter and Rust backend.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Frontend                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Riverpod  │  │   Widgets   │  │   ShaderCanvas      │  │
│  │   State     │  │   (Editor)  │  │   (CustomPainter)   │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
│         └────────────────┼─────────────────────┘             │
│                          │                                   │
│              ┌───────────┴───────────┐                       │
│              │  flutter_rust_bridge  │                       │
│              │        (FFI)          │                       │
│              └───────────┬───────────┘                       │
└──────────────────────────┼──────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────┐
│                          │         Rust Backend             │
│              ┌───────────┴───────────┐                      │
│              │        api.rs         │                      │
│              │    (Public API)       │                      │
│              └───────────┬───────────┘                      │
│                          │                                  │
│    ┌─────────────────────┼─────────────────────┐           │
│    │                     │                     │           │
│    ▼                     ▼                     ▼           │
│ ┌──────────┐      ┌────────────┐       ┌────────────┐      │
│ │ shaderc  │      │   wgpu     │       │  bytemuck  │      │
│ │ (GLSL →  │      │  (Vulkan/  │       │  (Zero-    │      │
│ │  SPIRV)  │      │   Metal)   │       │   copy)    │      │
│ └──────────┘      └────────────┘       └────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Frontend** | Flutter + Riverpod | UI & State Management |
| **Bridge** | flutter_rust_bridge | FFI Communication |
| **Backend** | Rust + wgpu | GPU Rendering |
| **Shader** | GLSL → SPIR-V (shaderc) | Runtime Compilation |

## Project Structure

```
shaders/
├── lib/
│   ├── main.dart                    # App entry point
│   └── src/
│       ├── models/                  # Data models
│       │   ├── shader_state.dart    # State definitions
│       │   └── shader_presets.dart  # Preset shaders
│       ├── providers/               # Riverpod providers
│       │   └── shader_provider.dart # State management
│       ├── services/                # Business logic
│       │   ├── shader_engine_service.dart
│       │   └── frame_renderer.dart
│       ├── widgets/                 # UI components
│       │   ├── shader_canvas.dart   # GPU render output
│       │   ├── shader_editor.dart   # GLSL code editor
│       │   ├── uniform_sliders.dart # Parameter controls
│       │   └── fps_counter.dart     # Performance display
│       └── pages/                   # Full page layouts
│           └── shader_playground_page.dart
├── rust/
│   ├── Cargo.toml                   # Rust dependencies
│   └── src/
│       ├── lib.rs                   # Crate root
│       ├── api.rs                   # FFI API (exposed to Dart)
│       ├── model.rs                 # Uniform structures
│       ├── renderer.rs              # wgpu rendering
│       └── shader_compiler.rs       # GLSL → SPIR-V
└── assets/
    └── shaders/                     # Sample GLSL shaders
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Rust toolchain (rustup)
- Android NDK / Xcode (for mobile)

### Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   cd rust && cargo build
   ```

2. **Generate FFI bindings:**
   ```bash
   flutter_rust_bridge_codegen generate
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Key Features

- **Real-time GLSL editing** with live preview
- **Runtime shader compilation** (no pre-compilation needed)
- **High-performance GPU rendering** via wgpu
- **Parameter sliders** for uniform tweaking
- **Preset shaders** for inspiration
- **FPS counter** for performance monitoring

## Shader Format

```glsl
#version 450

layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 f_color;

layout(set = 0, binding = 0) uniform Uniforms {
    float time;           // Elapsed time in seconds
    float screen_width;   // Canvas width in pixels
    float screen_height;  // Canvas height in pixels
    float _padding;       // Alignment padding
};

void main() {
    vec2 uv = v_uv;
    vec3 col = 0.5 + 0.5 * cos(time + uv.xyx + vec3(0.0, 2.0, 4.0));
    f_color = vec4(col, 1.0);
}
```

## Performance Notes

- **No unnecessary rebuilds**: Uses `RepaintBoundary` and `CustomPainter` with repaint notifiers
- **Separate render thread**: GPU work doesn't block UI
- **Zero-copy uniforms**: bytemuck for efficient data transfer
- **Debounced compilation**: Shader edits are batched

## License

MIT
