/// GPU Shader Canvas - renders shaders on the GPU at full speed
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/gpu_shader_service.dart';

/// High-performance GPU shader canvas
class GpuShaderCanvas extends StatefulWidget {
  final ShaderInfo? shaderInfo;
  final ValueChanged<double>? onFpsUpdate;

  const GpuShaderCanvas({
    super.key,
    this.shaderInfo,
    this.onFpsUpdate,
  });

  @override
  State<GpuShaderCanvas> createState() => _GpuShaderCanvasState();
}

class _GpuShaderCanvasState extends State<GpuShaderCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _time = 0.0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _fps = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    setState(() {
      _time = elapsed.inMicroseconds / 1000000.0;
    });

    // Calculate FPS
    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastFpsUpdate).inMilliseconds;
    if (diff >= 500) {
      _fps = _frameCount * 1000.0 / diff;
      _frameCount = 0;
      _lastFpsUpdate = now;
      widget.onFpsUpdate?.call(_fps);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = widget.shaderInfo?.shader;

    if (shader == null) {
      return Container(
        color: const Color(0xFF111111),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading shader...',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return CustomPaint(
      painter: _GpuShaderPainter(
        shader: shader,
        time: _time,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _GpuShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  _GpuShaderPainter({
    required this.shader,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Set uniforms: uResolution (vec2), uTime (float)
    shader.setFloat(0, size.width);   // uResolution.x
    shader.setFloat(1, size.height);  // uResolution.y
    shader.setFloat(2, time);         // uTime

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_GpuShaderPainter old) => true;
}
