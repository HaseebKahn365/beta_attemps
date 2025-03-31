import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaimon/gaimon.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double sliderValue = 0.5;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Expanded(
                        child: ListView(
                          // shrinkWrap: true,
                          children: [
                            TextButton(
                              onPressed: () => Gaimon.selection(),
                              child: const Text('👆 Selection'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.error(),
                              child: const Text('❌ Error'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.success(),
                              child: const Text('✅ Success'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.warning(),
                              child: const Text('🚨 Warning'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.heavy(),
                              child: const Text('💪 Heavy'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.medium(),
                              child: const Text('👊 Medium'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.light(),
                              child: const Text('🐥 Light'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.rigid(),
                              child: const Text('🔨 Rigid'),
                            ),
                            TextButton(
                              onPressed: () => Gaimon.soft(),
                              child: const Text('🧽 Soft'),
                            ),
                            Slider(
                              value: sliderValue,
                              onChanged: (value) {
                                setState(() {
                                  sliderValue = value;
                                });
                              },
                              min: 0,
                              max: 1,
                            ),

                            // Display current intensity value
                            Text('Intensity: ${sliderValue.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16)),

                            // Play button with intensity from slider
                            TextButton(
                              onPressed: () {
                                // Create amplitude array scaled by slider value
                                List<int> amplitudes = [0, 1, 2, 3, 4, 35, 6, 7, 8, 9];

                                // Create time array (keeping original timing)
                                List<int> timePoints = [0, 1, 2, 3, 4, 115, 6, 7, 8, 9];

                                // Play the haptic pattern with intensity from slider
                                Gaimon.patternFromWaveForm(
                                  timePoints,
                                  amplitudes,
                                  true,
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                backgroundColor: Colors.blue.shade100,
                              ),
                              child: const Text('💥 Impact', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patterns',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final String response =
                                    await rootBundle.loadString('assets/haptics/rumble.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('📳 Rumble'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response =
                                    await rootBundle.loadString('assets/haptics/heartbeats.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('💗 Heartbeat'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response =
                                    await rootBundle.loadString('assets/haptics/gravel.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('🪨 Gravel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final String response =
                                    await rootBundle.loadString('assets/haptics/inflate.ahap');
                                Gaimon.patternFromData(response);
                              },
                              child: const Text('😮‍💨 Inflate'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
