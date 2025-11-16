import 'package:atmos/atmos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  group('AtomBuilder', () {
    late Atom<int> counter;
    late AtmosStore store;

    setUp(() {
      store = AtmosStore.instance;
      store.reset();
      counter = atom(0);
    });

    testWidgets('reads the initial atom value', (tester) async {
      int? builderValue;

      await tester.pumpWidget(
        AtomBuilder(
          atom: counter,
          builder: (_, value, __) {
            builderValue = value;
            return Placeholder();
          },
        ),
      );

      expect(builderValue, 0);
    });

    testWidgets('rebuilds when atom changes', (tester) async {
      final logs = <int>[];

      await tester.pumpWidget(
        AtomBuilder(
          atom: counter,
          builder: (_, value, __) {
            logs.add(value);
            return Placeholder();
          },
        ),
      );

      expect(logs, equals([0]));

      // Write a new value
      store.write(counter, 10);
      await tester.pump();

      expect(logs, equals([0, 10]));
    });

    testWidgets('setValue writes to AtmosStore', (tester) async {
      await tester.pumpWidget(
        AtomBuilder(
          atom: counter,
          builder: (_, value, setValue) {
            if (value == 0) {
              setValue(5);
            }
            return Placeholder();
          },
        ),
      );

      expect(store.read(counter), 5);
    });

    testWidgets('unsubscribe happens on dispose', (tester) async {
      int rebuilds = 0;

      Widget build() {
        return AtomBuilder(
          atom: counter,
          builder: (_, __, ___) {
            rebuilds++;
            return Placeholder();
          },
        );
      }

      await tester.pumpWidget(build());
      expect(rebuilds, 1);

      // Remove the AtomBuilder
      await tester.pumpWidget(Placeholder());
      await tester.pump();

      // Writing should NOT trigger rebuilds anymore
      store.write(counter, 33);
      await tester.pump();

      expect(rebuilds, 1);
    });

    testWidgets('builder always receives latest value', (tester) async {
      final seenValues = <int>[];

      await tester.pumpWidget(
        AtomBuilder(
          atom: counter,
          builder: (_, value, __) {
            seenValues.add(value);
            return Placeholder();
          },
        ),
      );

      store.write(counter, 1);
      await tester.pump();

      store.write(counter, 2);
      await tester.pump();

      store.write(counter, 3);
      await tester.pump();

      expect(seenValues, equals([0, 1, 2, 3]));
    });
  });
}
