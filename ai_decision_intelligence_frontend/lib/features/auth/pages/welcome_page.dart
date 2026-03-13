import 'package:flutter/material.dart';

import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _dragPosition = 0;
  final double _buttonWidth = 300;
  final double _thumbSize = 56;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Illustration
              Center(
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
                      child: const Icon(
                        Icons.image_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              // Title
              const Text(
                'AI Decision\nIntelligence System',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Unlock data-driven insights and automate your decision-making process with our advanced AI analytics platform.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Slide to Get Started Button
              Center(
                child: Container(
                  width: _buttonWidth,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(_thumbSize / 2),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'Slide to Get Started',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                            if (_dragPosition > _buttonWidth * 0.7) {
                              setState(() {
                                _dragPosition = _buttonWidth - _thumbSize;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              ).then((_) {
                                setState(() {
                                  _dragPosition = 0;
                                });
                              });
                            } else {
                              setState(() {
                                _dragPosition = 0;
                              });
                            }
                          },
                          child: Container(
                            height: _thumbSize,
                            width: _thumbSize,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3B82F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
