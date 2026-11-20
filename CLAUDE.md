# Architecture

SwiftUI app (MVVM) that shows architectural landmarks on a map.

## Rules

- Views never hold or receive model objects (e.g. `Landmark`). They only talk to view models.
- A view that owns a view model creates it once, in its `init`, as `@State`. Never in `body`, which re-runs often and would drop loaded state.
- Keep MapKit out of the model and out of view models where possible. Put MapKit-dependent code in extensions (e.g. `Landmark+MapItem.swift`) or in separate view models (e.g. `LookAroundViewModel`), and add a comment saying why.
