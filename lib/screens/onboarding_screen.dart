import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              buildPage(
                color: Colors.blue.shade100,
                icon: Icons.search,
                title: 'Find and Block',
                subtitle: 'Easily find any country and disable specific mobile operators to avoid unwanted roaming charges.',
              ),
              buildPage(
                color: Colors.orange.shade100,
                icon: Icons.edit,
                title: 'Editable Prices',
                subtitle: 'Operator prices are for guidance only and may not be exact. Tap on any price to enter the correct rate from your operator.',
              ),
              buildPage(
                color: Colors.green.shade100,
                icon: Icons.shield,
                title: 'Full Control',
                subtitle: 'Use the buttons to disable all expensive networks based on your prices, or disable all countries at once for complete peace of mind.',
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: isLastPage
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(60),
                      ),
                      child: const Text('Get Started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showHome', true);

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(onPressed: () => controller.jumpToPage(2), child: const Text('SKIP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Center(
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: 3,
                            effect: WormEffect(
                              spacing: 16,
                              dotColor: Colors.black26,
                              activeDotColor: Colors.teal,
                            ),
                            onDotClicked: (index) => controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            ),
                          ),
                        ),
                        TextButton(onPressed: () => controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut), child: const Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) =>
      Container(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: Colors.teal),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(color: Colors.teal, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ],
        ),
      );
}