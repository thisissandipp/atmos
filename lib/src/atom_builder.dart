import 'package:flutter/widgets.dart';
import 'atom.dart';
import 'atmos_store.dart';

/// {@template atom_builder}
/// A widget that rebuilds whenever the given [atom] changes.
///
/// `AtomBuilder` is the primary way to consume atoms in Flutter UI.
/// It listens to the atom, updates when its value changes, and provides:
///
/// - the current value
/// - a setter function for writable atoms
///
/// Example:
///
/// ```dart
/// final counterAtom = atom(0);
///
/// AtomBuilder(
///   atom: counterAtom,
///   builder: (context, count, setCount) {
///     return Column(
///       children: [
///         Text('Count: $count'),
///         ElevatedButton(
///           onPressed: () => setCount(count + 1),
///           child: Text('Increment'),
///         ),
///       ],
///     );
///   },
/// );
/// ```
///
/// For computed atoms, the setter will still be provided, but writing to
/// them has no effect (computed atoms cannot store values).
/// {@endtemplate}
class AtomBuilder<T> extends StatefulWidget {
  /// {@macro atom_builder}
  const AtomBuilder({
    super.key,
    required this.atom,
    required this.builder,
  });

  /// The atom whose value should be observed and provided to the [builder].
  final Atom<T> atom;

  /// A function that builds the widget tree using:
  ///
  /// - the current value of the atom
  /// - a setter function to write a new value
  ///
  /// The setter writes directly into [AtmosStore], notifying all listeners.
  final Widget Function(
    BuildContext context,
    T value,
    void Function(T) setValue,
  ) builder;

  @override
  State<AtomBuilder<T>> createState() => _AtomBuilderState<T>();
}

class _AtomBuilderState<T> extends State<AtomBuilder<T>> {
  /// The last known value of the atom, kept locally to trigger widget rebuilds.
  late T value;

  @override
  void initState() {
    super.initState();
    // Read atom initial value and subscribe to updates.
    value = AtmosStore.instance.read(widget.atom);
    AtmosStore.instance.subscribe(widget.atom, _handleUpdate);
  }

  @override
  void dispose() {
    AtmosStore.instance.unsubscribe(widget.atom, _handleUpdate);
    super.dispose();
  }

  // Triggers a rebuild with the latest value.
  void _handleUpdate() {
    setState(() {
      value = AtmosStore.instance.read(widget.atom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      value,
      (v) => AtmosStore.instance.write(widget.atom, v),
    );
  }
}
