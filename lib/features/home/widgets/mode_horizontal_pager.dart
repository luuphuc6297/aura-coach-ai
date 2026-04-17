import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/swipe_dots.dart';

class ModeHorizontalPager extends StatefulWidget {
  final Widget overviewCard;
  final Widget deepDiveCard;
  final Color accentColor;

  const ModeHorizontalPager({
    super.key,
    required this.overviewCard,
    required this.deepDiveCard,
    required this.accentColor,
  });

  @override
  State<ModeHorizontalPager> createState() => _ModeHorizontalPagerState();
}

class _ModeHorizontalPagerState extends State<ModeHorizontalPager> {
  final PageController _controller = PageController();
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (_controller.page != null) {
      setState(() => _page = _controller.page!);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _page.round();

    return Stack(
      children: [
        PageView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          children: [
            widget.overviewCard,
            widget.deepDiveCard,
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(
            child: SwipeDots(
              total: 2,
              current: currentPage,
              activeColor: widget.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
