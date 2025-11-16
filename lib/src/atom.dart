/// Signature used inside computed atoms to read the value of another [Atom].
///
/// Example:
/// ```dart
/// final doubleCounter = computed((get) => get(counterAtom) * 2);
/// ```
typedef Getter = T Function<T>(Atom<T> atom);

/// A reactive state primitive representing a single unit of state.
///
/// An [Atom] can be one of two types:
///
/// 1. **Value Atom** — created using [Atom] or [atom], which holds an initial
///    mutable value.
/// 
/// 2. **Computed Atom** — created using [Atom.compute] or [computed], which
///    derives its value from other atoms using a compute function.
///
/// [Atom] itself does not store the current value; the store manages:
/// - updates
/// - dependency tracking
/// - recomputation
///
/// Example:
/// ```dart
/// final counter = atom(0);
/// final doubled = computed((get) => get(counter) * 2);
/// ```
class Atom<T> {
  final T? _initialValue;
  final T Function(Getter get)? _compute;

  /// Creates a value atom with the given [initialValue].
  ///
  /// This atom holds a mutable state managed by the store.
  const Atom(T initialValue)
      : _initialValue = initialValue,
        _compute = null;

  /// Creates a computed atom derived from other atoms using the [compute]
  /// function.
  ///
  /// The compute function is executed lazily when the atom is first read, and
  /// re-executed when any of its dependencies change.
  const Atom.compute(T Function(Getter get)? compute)
      : _initialValue = null,
        _compute = compute;

  /// The initial value provided for a value atom.
  ///
  /// This is `null` for computed atoms.
  T? get initialValue => _initialValue;

  /// The compute function used to evaluate a computed atom.
  ///
  /// This is `null` for value atoms.
  T Function(Getter get)? get compute => _compute;

  /// Whether this atom is a computed atom.
  bool get isComputed => _compute != null;

  @override
  String toString() => 'Atom(initialValue: $_initialValue, compute: $_compute)';
}

/// This is a shorthand helper constructor for:
/// ```dart
/// final todoAtom = atom([]);
/// ```
Atom<T> atom<T>(T value) => Atom(value);

/// Creates a computed atom whose value is derived from other atoms using
/// the [compute] function.
///
/// Example:
/// ```dart
/// final nameAtom = atom('Alice');
/// final greetingAtom = computed((get) => 'Hi ${get(nameAtom)}');
/// ```
Atom<T> computed<T>(T Function(Getter get) compute) => Atom.compute(compute);
