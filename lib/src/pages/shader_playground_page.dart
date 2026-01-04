/// Main shader playground page.
/// 
/// Responsive layout with shader canvas and editor panels.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Main shader playground page with responsive layout.
class ShaderPlaygroundPage extends ConsumerStatefulWidget {
  const ShaderPlaygroundPage({super.key});

  @override
  ConsumerState<ShaderPlaygroundPage> createState() =>
      _ShaderPlaygroundPageState();
}

class _ShaderPlaygroundPageState extends ConsumerState<ShaderPlaygroundPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  //Duration _lastElapsed = Duration.zero;
  final Stopwatch _stopwatch = Stopwatch();
  int _frameCount = 0;
  double _fps = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeEngine();
    _ticker = createTicker(_onTick);
    _stopwatch.start();
  }

  Future<void> _initializeEngine() async {
    // Defer state modification to after build
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await ref.read(shaderStateProvider.notifier).initialize();
      await ref.read(shaderStateProvider.notifier).compileShader();
      ref.read(shaderStateProvider.notifier).startRendering();
      _ticker.start();
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final state = ref.read(shaderStateProvider);
    if (!state.isRunning) return;

    final double time = elapsed.inMicroseconds / 1000000.0;

    // Update time uniform using post frame callback to avoid build issues
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(shaderStateProvider.notifier).updateTime(time);
    });

    // Calculate FPS
    _frameCount++;
    if (_stopwatch.elapsedMilliseconds >= 1000) {
      _fps = _frameCount * 1000.0 / _stopwatch.elapsedMilliseconds;
      _frameCount = 0;
      _stopwatch.reset();
      _stopwatch.start();

      // Update FPS in provider using post frame callback
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(shaderStateProvider.notifier).updateFps(_fps);
      });
    }
    
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              return _buildWideLayout();
            } else {
              return _buildNarrowLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Shader canvas
        const Expanded(
          flex: 2,
          child: Column(
            children: [
              _Header(),
              Expanded(child: ShaderCanvas()),
              FpsCounter(),
            ],
          ),
        ),
        // Editor panel
        Expanded(
          child: Container(
            color: Colors.grey[850],
            child: const Column(
              children: [
                ShaderPresetsPanel(),
                Expanded(child: ShaderEditor()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return const Column(
      children: [
        _Header(),
        Expanded(
          flex: 3,
          child: ShaderCanvas(),
        ),
        FpsCounter(),
        ShaderPresetsPanel(),
        Expanded(
          flex: 2,
          child: ShaderEditor(),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[850],
      child: const Row(
        children: [
          Icon(Icons.brush, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Shader Playground',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
