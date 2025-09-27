import 'package:flutter/material.dart';
import '../../utils/colors.dart' as app_colors;

/// Widget de chargement réutilisable
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? app_colors.AppColor.yAccentColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: app_colors.AppColor.yTextColor.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de chargement compact pour les listes
class CompactLoadingWidget extends StatelessWidget {
  final Color? color;

  const CompactLoadingWidget({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? app_colors.AppColor.yAccentColor,
          ),
        ),
      ),
    );
  }
}

/// Widget de chargement avec animation
class AnimatedLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;

  const AnimatedLoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  State<AnimatedLoadingWidget> createState() => _AnimatedLoadingWidgetState();
}

class _AnimatedLoadingWidgetState extends State<AnimatedLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.color ?? app_colors.AppColor.yAccentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 14,
                color: app_colors.AppColor.yTextColor.withAlpha(200),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}