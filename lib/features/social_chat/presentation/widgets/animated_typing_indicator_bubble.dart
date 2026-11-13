import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

class AnimatedTypingIndicatorBubble extends StatefulWidget {
  final String displayName;

  const AnimatedTypingIndicatorBubble({
    super.key,
    required this.displayName,
  });

  @override
  State<AnimatedTypingIndicatorBubble> createState() =>
      _AnimatedTypingIndicatorBubbleState();
}

class _AnimatedTypingIndicatorBubbleState
    extends State<AnimatedTypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
            child: Text(
              widget.displayName.isNotEmpty
                  ? widget.displayName[0].toUpperCase()
                  : 'B',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final phase = (_controller.value * 2 * math.pi) - (i * 0.9);
                        final dy = -math.sin(phase).clamp(0.0, 1.0) * 3.5;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.displayName} mengetik...',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
