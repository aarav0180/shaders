/// GPU Shader Service - loads and manages Flutter fragment shaders
library;

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

/// Information about a loaded shader
class ShaderInfo {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final ui.FragmentProgram? program;
  final ui.FragmentShader? shader;

  const ShaderInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    this.program,
    this.shader,
  });

  ShaderInfo withProgram(ui.FragmentProgram program) {
    return ShaderInfo(
      id: id,
      name: name,
      description: description,
      assetPath: assetPath,
      program: program,
      shader: program.fragmentShader(),
    );
  }

  bool get isLoaded => shader != null;
}

/// Available GPU shaders
final List<ShaderInfo> availableShaders = [
  const ShaderInfo(
    id: 'plasma_ball',
    name: 'Plasma Ball',
    description: 'Electric plasma ball with lightning arcs',
    assetPath: 'shaders/plasma_ball.frag',
  ),
  const ShaderInfo(
    id: 'plasma',
    name: 'Plasma',
    description: 'Classic plasma effect with swirling colors',
    assetPath: 'shaders/plasma.frag',
  ),
  const ShaderInfo(
    id: 'fractal_noise',
    name: 'Fractal Noise',
    description: 'Flowing organic patterns with FBM',
    assetPath: 'shaders/fractal_noise.frag',
  ),
  const ShaderInfo(
    id: 'kaleidoscope',
    name: 'Kaleidoscope',
    description: 'Mirrored psychedelic patterns',
    assetPath: 'shaders/kaleidoscope.frag',
  ),
  const ShaderInfo(
    id: 'tunnel',
    name: 'Tunnel',
    description: 'Hypnotic tunnel zoom effect',
    assetPath: 'shaders/tunnel.frag',
  ),
  const ShaderInfo(
    id: 'voronoi',
    name: 'Voronoi',
    description: 'Animated cellular patterns',
    assetPath: 'shaders/voronoi.frag',
  ),
  const ShaderInfo(
    id: 'sinusoidal_warp',
    name: 'Sinusoidal Warp',
    description: 'Bumped metallic surface with lighting',
    assetPath: 'shaders/sinusoidal_warp.frag',
  ),
];

/// Service to load and manage GPU shaders
class GpuShaderService {
  final Map<String, ShaderInfo> _loadedShaders = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Load all shaders
  Future<void> loadAllShaders() async {
    if (_initialized) return;

    for (final info in availableShaders) {
      try {
        final program = await ui.FragmentProgram.fromAsset(info.assetPath);
        _loadedShaders[info.id] = info.withProgram(program);
        debugPrint('Loaded shader: ${info.name}');
      } catch (e) {
        debugPrint('Failed to load shader ${info.name}: $e');
        _loadedShaders[info.id] = info; // Store without program
      }
    }

    _initialized = true;
    debugPrint('GPU Shader Service initialized with ${_loadedShaders.length} shaders');
  }

  /// Get a shader by ID
  ShaderInfo? getShader(String id) => _loadedShaders[id];

  /// Get all loaded shaders
  List<ShaderInfo> get shaders => _loadedShaders.values.toList();

  /// Get shader IDs
  List<String> get shaderIds => _loadedShaders.keys.toList();
}
