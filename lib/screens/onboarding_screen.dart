import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/operator_guard_provider.dart';
import '../translations.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                title: l10n.translate('onboarding1Title'),
                subtitle: l10n.translate('onboarding1Subtitle'),
              ),
              buildPage(
                color: Colors.orange.shade100,
                icon: Icons.edit,
                title: l10n.translate('onboarding2Title'),
                subtitle: l10n.translate('onboarding2Subtitle'),
              ),
              buildPage(
                color: Colors.green.shade100,
                icon: Icons.shield,
                title: l10n.translate('onboarding3Title'),
                subtitle: l10n.translate('onboarding3Subtitle'),
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
                      child: Text(l10n.translate('getStarted'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('showHome', true);

                        if (!mounted) return;
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
                        TextButton(onPressed: () => controller.jumpToPage(2), child: Text(l10n.translate('skip'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
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
                        TextButton(onPressed: () => controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut), child: Text(l10n.translate('next'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
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