// lib/screens/counter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/counter_services.dart';
import 'package:islamic_app/widgets/counter/counter_widgets.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  final CounterService _service = CounterService();
  int _counter = 0;
  bool _isPressed = false;
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF8B0000);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    _counter = await _service.loadCounter();
    setState(() => _isLoading = false);
  }

  Future<void> _incrementCounter() async {
    setState(() {
      _counter++;
      _isPressed = true;
    });

    await _service.saveCounter(_counter);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  Future<void> _resetCounter() async {
    setState(() => _counter = 0);
    await _service.saveCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: primaryColor,
        title: Text(
          Globals.languageState! ? "Counter" : "تسابيح",
          style: TextStyle(
            color: Colors.white,
            fontSize: isPortrait ? size.width * 0.06 : size.height * 0.06,
            fontWeight: FontWeight.bold,
            fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.jpg'),
                    fit: BoxFit.cover,
                    opacity: 0.9,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Counter display
                        Container(
                          width: isPortrait ? size.width * 0.6 : size.height * 0.6,
                          height: isPortrait ? size.width * 0.6 : size.height * 0.6,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(scale: animation, child: child),
                              child: Text(
                                key: ValueKey<int>(_counter),
                                Globals.languageState!
                                    ? '$_counter'
                                    : CounterService.toArabicNumber(_counter.toString()),
                                style: TextStyle(
                                  fontSize: isPortrait
                                      ? size.width * 0.2
                                      : size.height * 0.2,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms).scale(),

                        SizedBox(height: isPortrait ? size.height * 0.05 : size.width * 0.05),

                        // Increment button
                        CounterButton(
                          isPressed: _isPressed,
                          onTap: _incrementCounter,
                          size: isPortrait ? size.width * 0.5 : size.height * 0.5,
                          color: primaryColor,
                        ),

                        SizedBox(height: isPortrait ? size.height * 0.03 : size.width * 0.03),

                        // Reset button
                        TextButton(
                          onPressed: _resetCounter,
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryTextColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isPortrait ? size.width * 0.1 : size.height * 0.1,
                              vertical: isPortrait ? size.height * 0.02 : size.width * 0.02,
                            ),
                          ),
                          child: Text(
                            Globals.languageState! ? 'Reset' : 'اعادة',
                            style: TextStyle(
                              fontSize: isPortrait ? size.width * 0.045 : size.height * 0.045,
                              fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
