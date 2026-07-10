import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedCoinCounter extends StatefulWidget {
  final int coins;
  final double iconSize;
  final TextStyle? textStyle;

  const AnimatedCoinCounter({
    super.key,
    required this.coins,
    this.iconSize = 22.0,
    this.textStyle,
  });

  @override
  State<AnimatedCoinCounter> createState() => _AnimatedCoinCounterState();
}

class _AnimatedCoinCounterState extends State<AnimatedCoinCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late int _displayCoins;
  
  @override
  void initState() {
    super.initState();
    _displayCoins = widget.coins;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedCoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      _animateCoinDiff(oldWidget.coins, widget.coins);
    }
  }

  void _animateCoinDiff(int oldVal, int newVal) async {
    _controller.forward(from: 0.0);
    
    // Smooth integer counting
    final steps = (newVal - oldVal).abs();
    if (steps == 0) return;

    final durationPerStep = Duration(milliseconds: (400 / steps).round().clamp(5, 50));
    final increment = newVal > oldVal ? 1 : -1;
    
    for (int i = 0; i < steps; i++) {
      if (!mounted) return;
      await Future.delayed(durationPerStep);
      setState(() {
        _displayCoins += increment;
      });
    }
    
    // Hard check at the end
    setState(() {
      _displayCoins = newVal;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spinning / Floating Gaming coin
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            ),
            child: Icon(
              Icons.monetization_on,
              color: AppTheme.accentColor,
              size: widget.iconSize,
            ),
          ),
          const SizedBox(width: 8),
          
          // Ticker text
          Text(
            _displayCoins.toString(),
            style: widget.textStyle ?? const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
