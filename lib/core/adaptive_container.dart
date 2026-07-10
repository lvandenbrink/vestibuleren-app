import 'package:flutter/material.dart';

/// Below this width, content renders full-bleed (matches phone portrait).
/// At/above it, content is centered in a fixed-width column, so phone
/// landscape widths never land in a thin, glitchy-looking margin.
const double _wideBreakpoint = 600;
const double _contentMaxWidth = 480;

/// Constrains [child] to a centered column on wide screens (tablets, phone
/// landscape, desktop/web), while staying full-bleed on narrow screens
/// (phone portrait). Meant to wrap a [Scaffold]'s `body`, not the whole
/// screen, so the app bar and bottom nav stay full-bleed.
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  const AdaptiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < _wideBreakpoint) return child;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: SafeArea(child: child),
      ),
    );
  }
}
