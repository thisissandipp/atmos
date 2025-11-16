# Atmos

A minimal, Jotai-inspired state management library for Flutter.  
Simple atoms, computed atoms, and fine-grained UI updates — with zero boilerplate.

> [!WARNING] Atmos is experimental and under active development. APIs may change, break, or explode spectacularly. Use at your own risk and have fun. 😄

---

## Start with Atom

Atoms are the basic units of state. They hold values or compute values derived from other atoms.

### Value Atom

Stores a mutable value managed by the Atmos store.

```dart
final counterAtom = atom(0);
```

### Derived (Computed) Atom

Automatically derives its value using other atoms. Recomputes when dependencies change.

```dart
final doubledAtom = computed((get) => get(counterAtom) * 2);
```

## AtomBuilder

A Flutter widget that rebuilds when its atom updates. It provides the current value and a setter (for writable atoms).

```dart
AtomBuilder(
  atom: counterAtom,
  builder: (context, count, setCount) {
    return TextButton(
      onPressed: () => setCount(count + 1),
      child: Text('Count: $count'),
    );
  },
);
```

You can read computed atoms exactly the same way.

```dart
AtomBuilder(
  atom: doubledAtom,
  builder: (_, value, __) => Text('Doubled: $value'),
);
```

> [!IMPORTANT] Computed atoms cannot be written to — `setValue` is a no-op.

## The AtmosStore API

Atmos ships with a global store you rarely need to interact with directly.

```dart
final store = AtmosStore.instance;

// Read
store.read(counterAtom);

// Write
store.write(counterAtom, 42);

// Subscribe
store.subscribe(counterAtom, () => print('counter changed!'));

// Unsubscribe
store.unsubscribe(counterAtom, () {});
```

## License

The project is released under the [MIT License](LICENSE). Learn more about it, [here](https://opensource.org/license/mit/).
