import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HandwritingCanvas extends StatefulWidget {
    final String targetCharacter;
    final VoidCallback? onClear;

    const HandwritingCanvas({
        super.key,
        required this.targetCharacter,
        this.onClear,
    });

    @override
    State<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
    final List<Offset?> _points = [];

    @override
    void didUpdateWidget(covariant HandwritingCanvas oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (oldWidget.targetCharacter != widget.targetCharacter) {
            _points.clear();
        }
    }

    @override
    Widget build(BuildContext context) {
        final strokeColor = Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo;
        return Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: strokeColor.withValues(alpha: 0.2), width: 2),
                boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
            ),
            child: Stack(
                alignment: Alignment.center,
                children: [
                    // Background Guide Character (Watermark)
                    Text(
                        widget.targetCharacter,
                        style: TextStyle(
                            fontSize: 160,
                            color: AppColors.sakuraPink.withValues(alpha: 0.15),
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                    // Drawing Gesture Detector & Custom Painter
                    GestureDetector(
                        onPanUpdate: (details) {
                            setState(() {
                                RenderBox renderBox = context.findRenderObject() as RenderBox;
                                _points.add(renderBox.globalToLocal(details.globalPosition));
                            });
                        },
                        onPanEnd: (details) => _points.add(null),
                        child: CustomPaint(
                            painter: _StrokePainter(points: _points, strokeColor: strokeColor),
                            size: Size.infinite,
                        ),
                    ),
                    // Clear Button
                    Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                            icon: Icon(Icons.refresh, color: strokeColor),
                            onPressed: () {
                                setState(() {
                                    _points.clear();
                                });
                                widget.onClear?.call();
                            },
                        ),
                    ),
                ],
            ),
        );
    }
}

class _StrokePainter extends CustomPainter {
    final List<Offset?> points;
    final Color strokeColor;

    _StrokePainter({required this.points, required this.strokeColor});

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
            ..color = strokeColor
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 10.0;

        for (int i = 0; i < points.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
                canvas.drawLine(points[i]!, points[i + 1]!, paint);
            }
        }
    }

    @override
    bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
