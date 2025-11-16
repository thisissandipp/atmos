import 'package:atmos/atmos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Value Atom', () {
    test('stores initial value', () {
      final a = Atom(10);

      expect(a.initialValue, 10);
      expect(a.compute, isNull);
      expect(a.isComputed, false);
    });

    test('atom() helper creates value atom', () {
      final a = atom('hello');

      expect(a.initialValue, 'hello');
      expect(a.compute, isNull);
      expect(a.isComputed, false);
    });
  });

  group('Computed Atom', () {
    test('stores compute function', () {
      final c = computed((get) => 123);

      expect(c.compute, isNotNull);
      expect(c.initialValue, isNull);
      expect(c.isComputed, true);
    });

    test('returns same type when generic is used', () {
      final c = computed<int>((get) => 10);

      expect(c.compute, isNotNull);
      expect(c.compute is int Function(Getter), true);
    });
  });

  group('Identity and equality', () {
    test('two atoms with same initial value are NOT equal', () {
      final a1 = atom(5);
      final a2 = atom(5);

      expect(a1 == a2, false);
    });

    test('same instance is equal to itself', () {
      final a = atom(42);
      expect(a == a, true);
    });

    test('computed atoms with identical compute function are NOT equal', () {
      final c1 = computed((get) => 1);
      final c2 = computed((get) => 1);

      expect(c1 == c2, false);
    });
  });

  test('toString does not throw', () {
    final a = atom(3);
    expect(() => a.toString(), returnsNormally);
  });
}
