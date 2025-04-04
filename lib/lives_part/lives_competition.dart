import 'dart:async';

import 'package:beta_attemps/lives_part/provider_for_lives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class LivesCollection extends StatelessWidget {
  const LivesCollection({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: globalProvider,
      child: const LivesCollectionScreen(),
    );
  }
}

class AnimationData {
  final int id;
  final bool isCollecting;
  final DateTime startTime;

  AnimationData({
    required this.id,
    required this.isCollecting,
    required this.startTime,
  });
}

class LivesCollectionScreen extends StatefulWidget {
  const LivesCollectionScreen({super.key});

  @override
  State<LivesCollectionScreen> createState() => _LivesCollectionScreenState();
}

class _LivesCollectionScreenState extends State<LivesCollectionScreen> {
  Timer? _longPressTimer;
  static const _rapidFireDuration = Duration(milliseconds: 150);
  final List<AnimationData> _animations = [];
  int _nextAnimationId = 0;

  void _startRapidFire(BuildContext context, bool isCollecting) {
    _performOperation(context, isCollecting);
    _longPressTimer = Timer.periodic(_rapidFireDuration, (_) {
      _performOperation(context, isCollecting);
    });
  }

  void _stopRapidFire() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _performOperation(BuildContext context, bool isCollecting) {
    if (isCollecting && globalProvider.canCollectLives() || !isCollecting && globalProvider.canReturnLives()) {
      setState(() {
        _animations.add(AnimationData(
          id: _nextAnimationId++,
          isCollecting: isCollecting,
          startTime: DateTime.now(),
        ));
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _animations.removeWhere((anim) => DateTime.now().difference(anim.startTime).inMilliseconds >= 1200);
          });
        }
      });

      if (isCollecting) {
        globalProvider.collectLives();
      } else {
        globalProvider.returnLives();
      }
    }
  }

  @override
  void dispose() {
    _stopRapidFire();
    super.dispose();
  }

  Widget _buildAnimatingHearts() {
    return SizedBox(
      width: 100,
      height: 200,
      child: Stack(
        children: [
          ..._animations.map((anim) {
            if (anim.isCollecting) {
              return Positioned.fill(
                  // For collecting animation (hearts going up)
                  child: Animate(
                effects: const [
                  ScaleEffect(
                    begin: Offset(1.0, 1.0),
                    end: Offset(0.5, 0.5),
                    duration: Duration(milliseconds: 500),
                  ),
                  MoveEffect(begin: Offset(0, 200), end: Offset(0, 0), duration: Duration(milliseconds: 600), curve: Curves.easeInOut),
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 24).animate().moveX(begin: -100, end: 0, duration: 1000.ms, curve: Curves.easeInOut).fade(
                          begin: 0.0,
                          end: 1.0,
                          duration: 100.ms,
                        ),
                    const Icon(Icons.favorite, color: Colors.red, size: 24).animate().moveX(begin: 200, end: 0, duration: 1000.ms, curve: Curves.easeInOut).fade(
                          begin: 0.0,
                          end: 1.0,
                          duration: 100.ms,
                        ),
                  ],
                ),
              ));
            } else {
              return Positioned.fill(
                  // For returning animation (hearts going down)
                  child: Animate(
                effects: const [
                  ScaleEffect(
                    begin: Offset(0.5, 0.5),
                    end: Offset(1.0, 1.0),
                    duration: Duration(milliseconds: 500),
                  ),
                  MoveEffect(begin: Offset(0, 0), end: Offset(0, 200), duration: Duration(milliseconds: 800), curve: Curves.easeInOut),
//fade effect
                  FadeEffect(
                    begin: 1.0,
                    end: 0.0,
                    duration: Duration(milliseconds: 200),
                  ),
                ],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 24).animate().moveX(begin: 0, end: -100, duration: 1000.ms, curve: Curves.easeInOut).fade(
                          begin: 0.0,
                          end: 1.0,
                          duration: 100.ms,
                        ),
                    const Icon(Icons.favorite, color: Colors.red, size: 24).animate().moveX(begin: 0, end: 100, duration: 1000.ms, curve: Curves.easeInOut).fade(
                          begin: 0.0,
                          end: 1.0,
                          duration: 100.ms,
                        ),
                  ],
                ),
              ));
            }
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = globalProvider;
    return Scaffold(
      body: SizedBox(
        // color: Colors.blue.withOpacity(0.1),
        width: double.infinity,
        height: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Main content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Control buttons and central heart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _performOperation(context, true),
                            onLongPress: () => _startRapidFire(context, true),
                            onLongPressUp: _stopRapidFire,
                            onTapUp: (_) => _stopRapidFire(),
                            child: _buildControlButton(Icons.upload, provider.canCollectLives()),
                          ),
                          const SizedBox(width: 16),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.favorite, size: 100, color: Theme.of(context).colorScheme.primary),
                              Text(
                                '${provider.collectedLives}',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTapDown: (_) => _performOperation(context, false),
                            onLongPress: () => _startRapidFire(context, false),
                            onLongPressUp: _stopRapidFire,
                            onTapUp: (_) => _stopRapidFire(),
                            child: _buildControlButton(Icons.download, provider.canReturnLives()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Player profiles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              PlayerProfile(imageUrl: 'https://picsum.photos/200', lives: provider.myLives),
                              const SizedBox(height: 8),
                              Text(
                                provider.myLives.toString(),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              PlayerProfile(imageUrl: 'https://picsum.photos/201', lives: provider.johnLives),
                              const SizedBox(height: 8),
                              (provider.fetchingLives)
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeCap: StrokeCap.round,
                                      ),
                                    )
                                  : Text(
                                      provider.johnLives.toString(),
                                    )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Animated hearts layer
                Positioned(
                  top: constraints.maxHeight * 0.3, // Adjust this value to position the hearts
                  left: 0,
                  right: 0,
                  child: _buildAnimatingHearts(),
                ),
                Positioned(
                  bottom: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.startFetchingLives();
                    },
                    child: const Text('Start fetching lives'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)),
        color: isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class PlayerProfile extends StatelessWidget {
  final String imageUrl;
  final int lives;

  const PlayerProfile({
    super.key,
    required this.imageUrl,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.grey.withOpacity(0.1),
        ),
        const SizedBox(height: 16),
        BuildLives(lives),
      ],
    );
  }
}

class BuildLives extends StatelessWidget {
  final int lives;

  const BuildLives(this.lives, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Animate(
          effects: [
            if (index < lives)
              const ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0), duration: Duration(milliseconds: 200))
            else
              const FadeEffect(
                begin: 1.0,
                end: 0.3,
                duration: Duration(milliseconds: 200),
              ),
          ],
          child: Icon(
            index < lives ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).colorScheme.primary,
            size: index < lives ? 20 : 16,
          ),
        ),
      ),
    );
  }
}
