import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  final double _buttonWidth = 300;
  final double _thumbSize = 56;
  
  late AnimationController _mainController;
  
  // Staggered Animations
  late Animation<double> _illustrationScale;
  late Animation<double> _illustrationFade;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _subtitleSlide;
  late Animation<double> _sliderFade;
  late Animation<double> _sliderSlide;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Illustration: 0.0 -> 0.6
    _illustrationFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _illustrationScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    // Title: 0.4 -> 0.7
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    // Subtitle: 0.5 -> 0.8
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)),
    );

    // Slider: 0.6 -> 1.0
    _sliderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _sliderSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dragPercentage = _dragPosition / (_buttonWidth - _thumbSize);
    bool isPast75 = dragPercentage >= 0.75;
    
    Color sliderBgColor = Color.lerp(Colors.grey[100], const Color(0xFF3B82F6), dragPercentage)!;
    Color thumbColor = Color.lerp(const Color(0xFF3B82F6), Colors.white, dragPercentage)!;
    Color iconColor = Color.lerp(Colors.white, const Color(0xFF3B82F6), dragPercentage)!;
    Color textColor = Color.lerp(Colors.grey[600], Colors.white.withOpacity(0.9), dragPercentage)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Illustration
                  Center(
                    child: Opacity(
                      opacity: _illustrationFade.value,
                      child: Transform.scale(
                        scale: _illustrationScale.value,
                        child: Image.asset(
                          'assets/images/illustration.jpg',
                          height: 350,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 350,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(LucideIcons.image, size: 100, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Opacity(
                    opacity: _titleFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: const Text(
                        'AI Decision\nIntelligence System',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Opacity(
                    opacity: _subtitleFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _subtitleSlide.value),
                      child: Text(
                        'Unlock data-driven insights and automate your decision-making process with our advanced AI analytics platform.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Slider
                  Opacity(
                    opacity: _sliderFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _sliderSlide.value),
                      child: Center(
                        child: Container(
                          width: _buttonWidth,
                          height: _thumbSize,
                          decoration: BoxDecoration(
                            color: sliderBgColor,
                            borderRadius: BorderRadius.circular(_thumbSize / 2),
                            border: Border.all(
                              color: isPast75 ? Colors.transparent : Colors.grey[300]!,
                            ),
                            boxShadow: isPast75 ? [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ] : [],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    isPast75 ? 'Let\'s Start! 🚀' : 'Slide to Get Started',
                                    key: ValueKey<bool>(isPast75),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: isPast75 ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: _dragPosition,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    setState(() {
                                      _dragPosition += details.delta.dx;
                                      if (_dragPosition < 0) _dragPosition = 0;
                                      if (_dragPosition > _buttonWidth - _thumbSize) {
                                        _dragPosition = _buttonWidth - _thumbSize;
                                      }
                                    });
                                  },
                                  onHorizontalDragEnd: (details) {
                                    if (_dragPosition > (_buttonWidth - _thumbSize) * 0.75) {
                                      setState(() {
                                        _dragPosition = _buttonWidth - _thumbSize;
                                      });
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => LoginPage()),
                                          ).then((_) {
                                            if (mounted) {
                                              setState(() {
                                                _dragPosition = 0;
                                              });
                                            }
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        _dragPosition = 0;
                                      });
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    height: _thumbSize,
                                    width: _thumbSize,
                                    decoration: BoxDecoration(
                                      color: thumbColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isPast75 ? LucideIcons.arrowRight : LucideIcons.chevronRight,
                                      color: iconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
