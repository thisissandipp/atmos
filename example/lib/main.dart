import 'package:atmos/atmos.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

final counterAtom = atom(0);
final doubledAtom = computed((get) => get(counterAtom) * 2);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AtomBuilder(
          atom: counterAtom,
          builder: (context, value, setValue) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Count: $value', style: TextStyle(fontSize: 40)),
                AtomBuilder(
                  atom: doubledAtom,
                  builder: (context, doubleValue, _) {
                    return Text(
                      'Double Count: $doubleValue',
                      style: TextStyle(fontSize: 40),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () => setValue(value + 1),
                  child: Text("Increment"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
