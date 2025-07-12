import 'dart:math';
import 'package:flutter/material.dart';

class EmojiBackground extends StatefulWidget {
  const EmojiBackground({super.key});

  @override
  State<EmojiBackground> createState() => _EmojiBackgroundState();
}

class _EmojiBackgroundState extends State<EmojiBackground>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojis = ['😂', '💀', '🔥'];
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: List.generate(5, (index) {
            final size = 24.0 + _random.nextInt(16);
            return Positioned(
              left: _random.nextDouble() * MediaQuery.of(context).size.width,
              top: _random.nextDouble() * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: 0.2,
                child: Text(
                  emojis[_random.nextInt(emojis.length)],
                  style: TextStyle(fontSize: size),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
