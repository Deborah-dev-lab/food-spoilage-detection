import 'package:flutter/material.dart';

void main() {
  runApp(const FreshTrackApp());
}

class FreshTrackApp extends StatelessWidget {
  const FreshTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003D2E)),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color darkGreen = Color(0xFF003D2E);
  static const Color sageGreen = Color(0xFF9AB5A8);
  static const Color background = Color(0xFFF8F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'FreshTrack',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'FreshTrack',
                applicationVersion: '1.0',
                children: const [
                  Text('Smartphone-Based Food Spoilage Detection System'),
                ],
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: darkGreen,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: sageGreen, width: 5),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 54,
                  color: sageGreen,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'FreshTrack',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF20252B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Making Food Safety Smarter',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF667078)),
              ),

              const Spacer(flex: 2),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Onboarding screen coming next!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 19),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: Colors.white,
        selectedIndex: 1,
        indicatorColor: darkGreen,
        onDestinationSelected: (index) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('More screens coming soon!')),
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.center_focus_strong),
            label: 'Check',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
