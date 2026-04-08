import 'package:flutter/material.dart';

import 'package:roqia_altatil/theme.dart';

/// A reusable audio wave visualizer widget
class AudioWaveVisualizer extends StatelessWidget {
  final bool isPlaying;
  final Color? color;
  final double height;
  
  const AudioWaveVisualizer({
    super.key,
    required this.isPlaying,
    this.color,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final waveColor = color ?? AppColors.primaryTeal;
    
    if (!isPlaying) {
      return SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            20,
            (index) => Container(
              width: 3,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: waveColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          20,
          (index) => _AnimatedBar(
            delay: index * 80,
            color: waveColor,
            maxHeight: height,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final int delay;
  final Color color;
  final double maxHeight;
  
  const _AnimatedBar({
    required this.delay,
    required this.color,
    required this.maxHeight,
  });

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: widget.maxHeight * _animation.value,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

/// Circular progress indicator that wraps around the play button
class CircularAudioProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Widget child;
  final Color? color;
  final double size;
  
  const CircularAudioProgress({
    super.key,
    required this.progress,
    required this.child,
    this.color,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.primaryTeal;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressColor.withValues(alpha: 0.1),
            ),
          ),
          // Progress arc
          if (progress > 0)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
          // Child (play button)
          child,
        ],
      ),
    );
  }
}
