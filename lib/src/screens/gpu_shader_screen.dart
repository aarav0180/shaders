/// GPU Shader Home Screen - High performance shader rendering
library;

import 'package:flutter/material.dart';
import '../services/gpu_shader_service.dart';
import '../widgets/gpu_shader_canvas.dart';

class GpuShaderScreen extends StatefulWidget {
  const GpuShaderScreen({super.key});

  @override
  State<GpuShaderScreen> createState() => _GpuShaderScreenState();
}

class _GpuShaderScreenState extends State<GpuShaderScreen> {
  final GpuShaderService _shaderService = GpuShaderService();
  int _selectedIndex = 0;
  double _fps = 0.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _loadShaders();
  }

  Future<void> _loadShaders() async {
    await _shaderService.loadAllShaders();
    if (mounted) setState(() {});
  }

  ShaderInfo? get _currentShader {
    final shaders = _shaderService.shaders;
    if (shaders.isEmpty || _selectedIndex >= shaders.length) return null;
    return shaders[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Shader canvas
            GpuShaderCanvas(
              shaderInfo: _currentShader,
              onFpsUpdate: (fps) {
                if (mounted) setState(() => _fps = fps);
              },
            ),

            // FPS counter
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_fps.toStringAsFixed(1)} FPS',
                  style: TextStyle(
                    color: _fps >= 30 ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Controls overlay
            if (_showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final shaders = _shaderService.shaders;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shader info
              if (_currentShader != null) ...[
                Text(
                  _currentShader!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentShader!.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],

              // Shader selector
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shaders.length,
                  itemBuilder: (context, index) {
                    final shader = shaders[index];
                    final isSelected = index == _selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              shader.name,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
