## 0.1.0-dev.0

This is the first preview release — expect breaking changes as the API evolves!

- Introduced **core reactive primitives**:
  - `Atom<T>` for value atoms  
  - `computed` atoms for derived state  
- Added **global AtmosStore**:
  - `read`, `write`, `subscribe`, `unsubscribe`
  - Dependency tracking + recomputation
- Added **AtomBuilder** widget:
  - Automatically rebuilds on atom updates
  - Provides current value + setter
- Implemented dependency graph for computed atoms
