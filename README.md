## Restaurants

### Features implemented

- **Map rendering.** Apple Maps are used to draw a map as the simplest and yet sufficient way to use a map on an iOS device.
- **Current location + centering**. Showing the current location on a map is required to understand what restaurants are near you. Centering makes it easier to go back and forth if it's necessary to support panning gestures.
- [Not implemented yet] **Showing restaurants from FourSquare**
- [Not implemented yet] **Showing details for a picker restaurant**

### Architecture overview

MVVM-C - Model-View-ViewModel-Coordinator is used as a template to build a screen. The implementation provided in the source code uses a non-strict approach in defining each layer of MVVM-C. In other words, each layer is filled and created based on the actual need, to make the implementation compact and flexible. As a result, some of the layers might slightly differ between different screens and/or be skipped.

- **View** - as plain as possible UI without business logic. Represented by UIViewController + its UIView. A view can interact with ViewModel to request decisions and supply events: by triggering event-based functions/callbacks (Input) and filling UI-related closures that are called by ViewModel when necessary.
- **ViewModel** - handles View events and triggers its corresponding UI updates. Might use a Model when states, data fetching, or calculation is complicated enough. ViewModel is not responsible for actual UI displaying. Represented by 2 protocols ViewModelInputs && ViewModelOutputs. 2 protocols are chosen for flexibility and could be represented by 2 connected ViewModel classes. However, in most cases it's more than enough to have one ViewModel that conforms to these 2 protocols (Inspired by Kickstarter iOS open-source app).
- **Model** - representation of a business logic + states, complicated enough to be separated from ViewModel.
- **Services** - classes that provide an API to external services (e.g. FourSquare API), usually is an extension of a Model layer to provide additional functionality.
- **Coordinator** - represents an external UX flow (e.g. navigation between screens, opening external applications)

#### Rationale to use MVVM-C

MVVM-C is chosen due to: 
- Less features density per screen, therefore fewer layers necessary.
- (C) - coordinators allow to isolate changes and move to another architecture cheaper (if it would be necessary). Plus additional testability.

### Testability

- **Unit tests.** Default test targets: ViewModel, Coordinator, other Models. 
    - ViewControllers aren't covered in unit tests based on the assumption that they are part of the plain UI. It's better to cover them with XCUI tests.
- **XCUI tests.** Aren't implemented yet.