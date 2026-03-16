import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_helper.dart';
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

    Color sliderBgColor =
        Color.lerp(Colors.grey[100], const Color(0xFF3B82F6), dragPercentage)!;
    Color thumbColor =
        Color.lerp(const Color(0xFF3B82F6), Colors.white, dragPercentage)!;
    Color iconColor =
        Color.lerp(Colors.white, const Color(0xFF3B82F6), dragPercentage)!;
    Color textColor = Color.lerp(
        Colors.grey[600], Colors.white.withOpacity(0.9), dragPercentage)!;

    final bool isWide = ResponsiveHelper.isWide(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.primaryBlue.withOpacity(0.02),
              AppTheme.accentIndigo.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, child) {
                              if (isWide) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _buildIllustrationSection(),
                                    ),
                                    const SizedBox(width: 60),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLogoHeader(),
                                          const SizedBox(height: 40),
                                          _buildTitleSection(),
                                          const SizedBox(height: 16),
                                          _buildSubtitleSection(),
                                          const SizedBox(height: 48),
                                          _buildSlider(sliderBgColor, isPast75, textColor,
                                              thumbColor, iconColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildLogoHeader(),
                                  const Spacer(),
                                  _buildIllustrationSection(),
                                  const Spacer(),
                                  _buildTitleSection(),
                                  const SizedBox(height: 16),
                                  _buildSubtitleSection(),
                                  const SizedBox(height: 48),
                                  _buildSlider(sliderBgColor, isPast75, textColor,
                                      thumbColor, iconColor),
                                  const SizedBox(height: 40),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 40,
          errorBuilder: (context, e, s) => const Icon(
            LucideIcons.brainCircuit,
            color: AppTheme.primaryBlue,
            size: 40,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'AI Data Analysts',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppTheme.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationSection() {
    return Center(
      child: Opacity(
        opacity: _illustrationFade.value,
        child: Transform.scale(
          scale: _illustrationScale.value,
          child: Image.asset(
            'assets/images/illustration.jpg',
            height: ResponsiveHelper.isWide(context) ? 450 : 350,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: ResponsiveHelper.isWide(context) ? 450 : 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    const Icon(LucideIcons.image, size: 100, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Opacity(
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
    );
  }

  Widget _buildSubtitleSection() {
    return Opacity(
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
    );
  }

  Widget _buildSlider(Color sliderBgColor, bool isPast75, Color textColor,
      Color thumbColor, Color iconColor) {
    return Opacity(
      opacity: _sliderFade.value,
      child: Transform.translate(
        offset: Offset(0, _sliderSlide.value),
        child: Align(
          alignment: ResponsiveHelper.isWide(context)
              ? Alignment.centerLeft
              : Alignment.center,
          child: Container(
            width: _buttonWidth,
            height: _thumbSize,
            decoration: BoxDecoration(
              color: sliderBgColor,
              borderRadius: BorderRadius.circular(_thumbSize / 2),
              border: Border.all(
                color: isPast75 ? Colors.transparent : Colors.grey[300]!,
              ),
              boxShadow: isPast75
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ]
                  : [],
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
                        fontWeight:
                            isPast75 ? FontWeight.bold : FontWeight.w500,
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
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
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
    );
  }
}
