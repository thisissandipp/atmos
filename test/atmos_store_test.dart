import 'package:atmos/atmos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtmosStore', () {
    group('value atom', () {
      test('reads initial value of a value atom', () {
        final count = atom(10);
        expect(AtmosStore.instance.read(count), 10);
      });

      test('writes value and reads updated value', () {
        final count = atom(0);
        AtmosStore.instance.write(count, 5);
        expect(AtmosStore.instance.read(count), 5);
      });
    });

    group('computed atom', () {
      test('evaluates based on dependencies', () {
        final a = atom(2);
        final b = computed((get) => get(a) * 3);
        expect(AtmosStore.instance.read(b), 6);
      });

      test('recomputes when dependency changes', () {
        final a = atom(2);
        final b = computed((get) => get(a) * 3);

        expect(AtmosStore.instance.read(b), 6);

        AtmosStore.instance.write(a, 5);
        expect(AtmosStore.instance.read(b), 15);
      });

      test('computed atom depends on another computed atom', () {
        final a = atom(1);
        final b = computed((get) => get(a) + 1);
        final c = computed((get) => get(b) * 10);

        expect(AtmosStore.instance.read(c), 20);

        AtmosStore.instance.write(a, 5);
        expect(AtmosStore.instance.read(c), 60);
      });
    });

    group('listener', () {
      test('is called when value atom changes', () {
        final a = atom(1);
        var called = false;

        AtmosStore.instance.subscribe(a, () {
          called = true;
        });

        AtmosStore.instance.write(a, 2);
        expect(called, true);
      });

      test('fires for computed atom when dependency changes', () {
        final a = atom(1);
        final b = computed((get) => get(a) * 2);

        AtmosStore.instance.read(b);

        var called = false;

        AtmosStore.instance.subscribe(b, () {
          called = true;
        });

        AtmosStore.instance.write(a, 3);
        expect(called, true);
      });

      test('unsubscribe stops listener triggers', () {
        final a = atom(1);

        var count = 0;
        void listener() => count++;

        AtmosStore.instance.subscribe(a, listener);

        AtmosStore.instance.write(a, 2);
        AtmosStore.instance.unsubscribe(a, listener);
        AtmosStore.instance.write(a, 3);

        expect(count, 1);
      });
    });

    group('lazy evaluation', () {
      test('computed value is not cached unless store writes it', () {
        var computeRuns = 0;

        final a = atom(1);
        final b = computed((get) {
          computeRuns++;
          return get(a) * 2;
        });

        AtmosStore.instance.read(b);
        AtmosStore.instance.read(b);

        // Should run twice because we do not cache computed values
        expect(computeRuns, 2);
      });
    });

    group('dependency tracking', () {
      test('is reset on recomputation', () {
        final toggle = atom(true);
        final a = atom(1);
        final b = atom(2);

        // Computed depends on either a or b, depending on toggle
        final c = computed((get) => get(toggle) ? get(a) : get(b));

        expect(AtmosStore.instance.read(c), 1);

        // Switch dependency to b
        AtmosStore.instance.write(toggle, false);

        expect(AtmosStore.instance.read(c), 2);
      });
    });
  });
}
