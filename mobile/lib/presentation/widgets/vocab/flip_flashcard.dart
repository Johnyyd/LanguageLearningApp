import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../domain/entities/vocab_item.dart';
import '../../../../core/theme/app_theme.dart';

class FlipFlashcard extends StatefulWidget {
    final VocabItem item;
    final Function(int quality)? onSrsReviewed;

    const FlipFlashcard({
        super.key,
        required this.item,
        this.onSrsReviewed,
    });

    @override
    State<FlipFlashcard> createState() => _FlipFlashcardState();
}

class _FlipFlashcardState extends State<FlipFlashcard> with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _animation;
    bool _isFront = true;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
        _animation = Tween<double>(begin: 0, end: pi).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
    }

    void _flipCard() {
        if (_isFront) {
            _controller.forward();
        } else {
            _controller.reverse();
        }
        setState(() {
            _isFront = !_isFront;
        });
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                            final angle = _animation.value;
                            final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle);

                            return Transform(
                                transform: transform,
                                alignment: Alignment.center,
                                child: angle < pi / 2 ? _buildFront() : Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildBack(),
                                ),
                            );
                        },
                    ),
                ),
                const SizedBox(height: 20),
                if (!_isFront && widget.onSrsReviewed != null) _buildSrsButtons(),
            ],
        );
    }

    Widget _buildFront() {
        return Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.deepIndigo, AppColors.softIndigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                    BoxShadow(color: AppColors.deepIndigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
            ),
            child: Stack(
                alignment: Alignment.center,
                children: [
                    Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.sakuraPink,
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                                widget.item.type,
                                style: const TextStyle(color: AppColors.deepIndigo, fontWeight: FontWeight.bold),
                            ),
                        ),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                                widget.item.character,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                                "Chạm để lật & xem nghĩa",
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                        ],
                    ),
                ],
            ),
        );
    }

    Widget _buildBack() {
        return Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.sakuraPink, width: 2),
                boxShadow: [
                    BoxShadow(color: AppColors.sakuraPink.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                ],
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                        widget.item.romaji,
                        style: const TextStyle(
                            color: AppColors.sakuraPink,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        widget.item.meaning,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.deepIndigo,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                        ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                            "Ví dụ: ${widget.item.example}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.slateGray, fontSize: 16),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget _buildSrsButtons() {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
                children: [
                    Expanded(child: _buildQualityBtn("Quên\n(Again)", AppColors.errorRed, 1)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQualityBtn("Khó\n(Hard)", AppColors.warningOrange, 2)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQualityBtn("Nhớ\n(Good)", AppColors.successGreen, 4)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQualityBtn("Dễ\n(Easy)", AppColors.sakuraPink, 5, isLightText: false)),
                ],
            ),
        );
    }

    Widget _buildQualityBtn(String label, Color color, int quality, {bool isLightText = true}) {
        return ElevatedButton(
            onPressed: () {
                _flipCard();
                widget.onSrsReviewed?.call(quality);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: isLightText ? Colors.white : AppColors.deepIndigo,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
        );
    }
}
