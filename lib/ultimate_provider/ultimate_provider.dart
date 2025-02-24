import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final secondaryProvider = SecondaryProvider();
final ultimateProvider = UltimateProvider()..title = 'Ultimate Root Provider';

/*
Here is an outline of the what the project is gonna be about.
we need to create a provider that will manage the state of the app.
here is the structure of the provider




 */

class UltimateProvider extends ChangeNotifier {
  int counter = 0;
  String title = '';
  static int childrenCount = 0;
  int timestamp = 0;

  List<UltimateProvider> children = [];

  UltimateProvider() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      timestamp++;
      notifyListeners();
    });
  }

  void addChild(String title) {
    childrenCount++;
    children.add(UltimateProvider()..title = title);
    notifyListeners();
  }

  void passToSecProvider() {
    secondaryProvider.copyTheValue(counter);
  }

  void removeChild(UltimateProvider child) {
    childrenCount--;
    children.remove(child);
    notifyListeners();
  }

  void increment() {
    counter++;
    notifyListeners();
  }

  void decrement() {
    counter--;
    notifyListeners();
  }
}

//a secondary provider to which we can copy the value of the counter and will have a timer for incrementing the timestamp int

class SecondaryProvider extends ChangeNotifier {
  int counter = 0;
  int timestamp = 0;

  //start a never ending timer that will increment the timestamp every 100 milliseconds
  SecondaryProvider() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      incrementTimestamp();
    });
  }

  void copyTheValue(int value) {
    counter = value;
    notifyListeners();
  }

  void incrementTimestamp() {
    timestamp++;
    notifyListeners();
  }
}

//!ui section

class UltimateProviderScreen extends StatefulWidget {
  final UltimateProvider provider;
  final String title;

  const UltimateProviderScreen({
    super.key,
    required this.provider,
    this.title = 'Ultimate Provider',
  });

  @override
  State<UltimateProviderScreen> createState() => _UltimateProviderScreenState();
}

class _UltimateProviderScreenState extends State<UltimateProviderScreen> {
  late UltimateProvider _provider;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = widget.provider;
    _titleController.text = '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addChild() {
    if (_titleController.text.isNotEmpty) {
      _provider.addChild(_titleController.text);
      _titleController.clear();
    }
  }

  void _navigateToChild(UltimateProvider childProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: childProvider,
          child: UltimateProviderScreen(
            provider: childProvider,
            title: childProvider.title,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<UltimateProvider>(
            builder: (_, ultimateProvider, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    // Access secondaryProvider directly, not through Consumer
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sec: ${secondaryProvider.counter}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Time: ${secondaryProvider.timestamp}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Children: ${UltimateProvider.childrenCount}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Add child input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Child Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(width: 0.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addChild,
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Child',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current provider counter and controls
              Consumer<UltimateProvider>(
                builder: (_, provider, __) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            '${provider.counter}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: provider.decrement,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: provider.increment,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.greenAccent.withOpacity(0.1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: provider.passToSecProvider,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          ),
                          tooltip: 'Copy to Secondary',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Children list
              Expanded(
                child: Consumer<UltimateProvider>(
                  builder: (_, provider, __) => provider.children.isEmpty
                      ? Center(
                          child: Text(
                            'No children added yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.children.length,
                          itemBuilder: (context, index) {
                            final childProvider = provider.children[index];
                            return ChangeNotifierProvider.value(
                              value: childProvider,
                              child: ProviderCard(
                                onDelete: () {
                                  provider.removeChild(childProvider);
                                },
                                onNavigate: () => _navigateToChild(childProvider),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onNavigate;

  const ProviderCard({
    super.key,
    required this.onDelete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UltimateProvider>(
      builder: (_, provider, __) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purpleAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Counter: ${provider.counter}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Children: ${provider.children.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: provider.increment,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: provider.decrement,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: provider.passToSecProvider,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete', style: TextStyle(fontSize: 12)),
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Open', style: TextStyle(fontSize: 12)),
                    onPressed: onNavigate,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main app class
class UltimateProviderApp extends StatelessWidget {
  const UltimateProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: ultimateProvider..title = 'Root Provider',
        ),
        ChangeNotifierProvider.value(
          value: secondaryProvider,
        ),
      ],
      child: MaterialApp(
        title: 'Ultimate Provider',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          cardTheme: CardTheme(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: UltimateProviderScreen(
          provider: ultimateProvider,
        ),
      ),
    );
  }
}
