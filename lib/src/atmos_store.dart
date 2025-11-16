import 'dart:collection';

import 'atom.dart';

/// A function invoked when an atom's value changes.
typedef Listener = void Function();

/// The central reactive store that holds values, manages dependencies,
/// and notifies listeners.
///
/// `AtmosStore` is responsible for:
///
/// - Storing values of writable atoms
/// - Lazily computing values of computed atoms
/// - Tracking dependencies between computed atoms and the atoms they read
/// - Recomputing and invalidating computed atoms when their dependencies change
/// - Notifying [AtomBuilder] widgets when a value they depend on changes
///
/// This is a singleton store; all atoms read and write through
/// [AtmosStore.instance].
class AtmosStore {
  AtmosStore._();

  /// The single global instance of the store.
  static final instance = AtmosStore._();

  /// Stores the latest resolved values for writable atoms.
  ///
  /// Computed atoms are not cached by default and may be re-evaluated unless
  /// explicitly cached here.
  final _values = HashMap<Atom, Object?>();

  /// Stores listeners (usually belonging to UI widgets) for each atom.
  final _listeners = HashMap<Atom, List<Listener>>();

  /// Holds the atom currently being evaluated.
  ///
  /// This is used for dependency tracking: when a computed atom reads another
  /// atom during computation, this records the relationship.
  Atom? _currentlyComputing;

  /// Tracks dependency edges:
  ///
  /// `A → {B, C}` means:
  /// - Atom A is a computed atom
  /// - Atom A depends on B and C
  ///
  /// When B or C changes, A must be invalidated and recomputed.
  final Map<Atom, Set<Atom>> _dependencies = {};

  /// Reads the current value of an [atom].
  ///
  /// - If the atom is currently being computed, this establishes a dependency.
  /// - If it's a computed atom, the compute function is executed.
  /// - If it's a writable atom, the stored value (or initial value) is returned.
  T read<T>(Atom<T> atom) {
    // Track dependencies for computed atoms
    if (_currentlyComputing != null) {
      _dependencies[_currentlyComputing]!.add(atom);
    }

    // Handle computed atoms
    if (atom.isComputed) {
      _currentlyComputing = atom;
      _dependencies.putIfAbsent(atom, () => <Atom>{});

      final value = atom.compute!.call(_readGetter);

      _currentlyComputing = null;
      return value;
    }

    // Handle normal atoms
    return (_values[atom] as T?) ?? atom.initialValue as T;
  }

  /// Writes a new [value] to the given [atom].
  ///
  /// After updating:
  /// - All computed atoms that depend on this atom are invalidated
  /// - Listeners for both the written atom and any invalidated computed atoms
  ///   are notified
  void write<T>(Atom<T> atom, T value) {
    _values[atom] = value;

    // Invalidate dependent computed atoms
    for (final entry in _dependencies.entries) {
      final computedAtom = entry.key;
      final deps = entry.value;

      if (deps.contains(atom)) {
        _values.remove(computedAtom);
        _listeners[computedAtom]?.forEach((l) => l());
      }
    }

    _listeners[atom]?.forEach((l) => l());
  }

  /// Internal getter used during computed atom evaluation.
  T _readGetter<T>(Atom<T> atom) => read(atom);

  /// Subscribes a listener to an atom.
  ///
  /// This is used primarily by UI widgets that should rebuild when
  /// an atom changes.
  void subscribe<T>(Atom<T> atom, Listener listener) {
    _listeners.putIfAbsent(atom, () => []);
    _listeners[atom]!.add(listener);
  }

  /// Removes a previously registered listener.
  void unsubscribe<T>(Atom<T> atom, Listener listener) {
    _listeners[atom]?.remove(listener);
  }

  /// Clears the store.
  void reset() {
    _values.clear();
    _listeners.clear();
  }
}
