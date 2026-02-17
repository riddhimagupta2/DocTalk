import 'package:flutter/material.dart';
import '../resources/AppTheme.dart';

class QuickReplyChips extends StatefulWidget {
  final List<String> options;
  final Function(String) onSelected;

  const QuickReplyChips({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<QuickReplyChips> createState() => _QuickReplyChipsState();
}

class _QuickReplyChipsState extends State<QuickReplyChips>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOption != null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnim,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.options.map((option) {
          return GestureDetector(
            onTap: () {
              setState(() => _selectedOption = option);
              widget.onSelected(option);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}