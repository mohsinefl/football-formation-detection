import 'dart:math';
import 'package:flutter/material.dart';

class PitchPainter extends CustomPainter {
  final List players;
  final bool showEllipses;
  final bool showConvexHull;
  final bool showCentroid;
  final bool showLabels;
  final double pitchLength;
  final double pitchWidth;

  PitchPainter({
    required this.players,
    this.showEllipses = true,
    this.showConvexHull = true,
    this.showCentroid = true,
    this.showLabels = true,
    this.pitchLength = 105,
    this.pitchWidth = 68,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(22),
    );

    final pitchPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0B6B3A), Color(0xFF0F8A45)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.85)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final zonePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    final ellipsePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.16)
          ..style = PaintingStyle.fill;

    final playerPaint =
        Paint()
          ..color = const Color(0xFF00E676)
          ..style = PaintingStyle.fill;

    final playerBorderPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.75)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final hullPaint =
        Paint()
          ..color = Colors.orangeAccent
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    canvas.drawRRect(fieldRect, pitchPaint);

    canvas.save();
    canvas.clipRRect(fieldRect);

    for (int i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * size.width / 6, 0, size.width / 12, size.height),
        zonePaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
        const Radius.circular(18),
      ),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.width / 2, 12),
      Offset(size.width / 2, size.height - 12),
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      min(size.width, size.height) * 0.16,
      linePaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.white,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        12,
        size.height * 0.28,
        size.width * 0.12,
        size.height * 0.44,
      ),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width - 12 - size.width * 0.12,
        size.height * 0.28,
        size.width * 0.12,
        size.height * 0.44,
      ),
      linePaint,
    );

    final mappedPlayers =
        players.map((p) {
          final x = (p["x_norm_mean"] ?? 0).toDouble();
          final y = (p["y_norm_mean"] ?? 0).toDouble();

          final halfLength = pitchLength / 2;
          final halfWidth = pitchWidth / 2;

          final normalizedX = ((x + halfLength) / pitchLength).clamp(0.0, 1.0);

          final normalizedY = ((y + halfWidth) / pitchWidth).clamp(0.0, 1.0);

          final px = normalizedX * size.width;

          final py = size.height - (normalizedY * size.height);

          return {"raw": p, "point": Offset(px, py)};
        }).toList();

    if (showConvexHull && mappedPlayers.length >= 3) {
      final points = mappedPlayers.map((p) => p["point"] as Offset).toList();

      final hull = _convexHull(points);

      if (hull.length >= 3) {
        final path = Path()..moveTo(hull.first.dx, hull.first.dy);

        for (final point in hull.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }

        path.close();
        canvas.drawPath(path, hullPaint);
      }
    }

    if (showCentroid && mappedPlayers.isNotEmpty) {
      final cx =
          mappedPlayers
              .map((p) => (p["point"] as Offset).dx)
              .reduce((a, b) => a + b) /
          mappedPlayers.length;

      final cy =
          mappedPlayers
              .map((p) => (p["point"] as Offset).dy)
              .reduce((a, b) => a + b) /
          mappedPlayers.length;

      final center = Offset(cx, cy);

      final centroidPaint =
          Paint()
            ..color = Colors.redAccent
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx - 10, center.dy),
        Offset(center.dx + 10, center.dy),
        centroidPaint,
      );

      canvas.drawLine(
        Offset(center.dx, center.dy - 10),
        Offset(center.dx, center.dy + 10),
        centroidPaint,
      );
    }

    for (final item in mappedPlayers) {
      final p = item["raw"] as Map;
      final point = item["point"] as Offset;

      final xs = (p["x_norm_std"] ?? 1).toDouble();
      final ys = (p["y_norm_std"] ?? 1).toDouble();

      if (showEllipses) {
        canvas.drawOval(
          Rect.fromCenter(
            center: point,
            width: max(xs * 4, 18),
            height: max(ys * 4, 18),
          ),
          ellipsePaint,
        );
      }

      canvas.drawCircle(point, 10, playerPaint);
      canvas.drawCircle(point, 10, playerBorderPaint);

      if (showLabels) {
        final name = p["player_name"]?.toString() ?? "";

        final textPainter = TextPainter(
          text: TextSpan(
            text: name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: 95);

        final labelX = point.dx.clamp(12, size.width - 105);
        final labelY = point.dy.clamp(16, size.height - 30);

        final labelRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            labelX + 12,
            labelY - 10,
            textPainter.width + 10,
            textPainter.height + 6,
          ),
          const Radius.circular(6),
        );

        canvas.drawRRect(
          labelRect,
          Paint()..color = Colors.white.withOpacity(0.78),
        );

        textPainter.paint(canvas, Offset(labelX + 17, labelY - 7));
      }
    }

    canvas.restore();
  }

  List<Offset> _convexHull(List<Offset> points) {
    if (points.length <= 3) return points;

    final sorted = [...points]..sort((a, b) {
      final xCompare = a.dx.compareTo(b.dx);
      if (xCompare != 0) return xCompare;
      return a.dy.compareTo(b.dy);
    });

    double cross(Offset o, Offset a, Offset b) {
      return (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
    }

    final lower = <Offset>[];
    for (final p in sorted) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    final upper = <Offset>[];
    for (final p in sorted.reversed) {
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    lower.removeLast();
    upper.removeLast();

    return lower + upper;
  }

  @override
  bool shouldRepaint(covariant PitchPainter oldDelegate) {
    return oldDelegate.players != players ||
        oldDelegate.showEllipses != showEllipses ||
        oldDelegate.showConvexHull != showConvexHull ||
        oldDelegate.showCentroid != showCentroid ||
        oldDelegate.showLabels != showLabels;
  }
}
