## Restaurants

### Features implemented

- **Map rendering.** Apple Maps is used to draw a map as a standard and yet sufficient way to visualize a map.
- **Current location**. Showing current location on a map is required to understand what restaurants are near you.
- **Centering + Basic zooming** makes it easier to go back and forth if it's necessary to support panning gestures.
- **Showing restaurants from FourSquare** - Restaurants should shown automatically on when the map becomes visible.
- **Automatic loading restaurants on panning** - Restaurants are re-fetched with interval of 1 sec based on the map changes
- **Restaurants caching** - In-memory caching is implemented to show already fetched restaurants
- **Showing details for a picker restaurant** - Very basic details are shown: an image, title and address
- **No Location services alert** - to help with proper configuration an alert is shown when Location Services config is wrong
- **Basic error reporting** - via toast message to help a user with understanding the problem

### Known issues / TODO-list

- No locatizations - due to the limited amount of time was excluded from the scope.
- iOS 14.1 + deployment target - no real devices were available to check how it works on iOS 13.0. Checking on a Simulator is usually not sufficient when dealing with rendering and hardware features (GPS)
- Some errors aren't reported, but silently logged or ignored. Like: "quota_exceeded". More testing and precise error reporting is necessary.
- Events-handling in MapViewModel isn't well ordered. A better order/sequence might significantly improve debugging and readability
- Views could be extracted from ViewController classes into separate classes to simplify readability
- Zooming might stop working after going to background and disabling / enabling LocationServices. More time is necessary to make it work properly.
- Manual button to do / re-do search would be more convenient (as it's done in some other map-based apps)
- Loading during panning could use predictive strategy to find a potential center of not-yet visible but coming map region.
- More advanced caching strategies could be applied to annotations and search requests.
- More unit tests could be added to Service and ViewModels
- 2 locations library is used due to different requirements (periodic monitoring / one fetch), it's better to have one fully suitable for the needs
- Zoom implementation was copied as a source file and updated to Swift 5 due to lack of time and no cocoapods support in the original repo.
- Foursquare quota is consumed too quickly :) => without it more agressive loading could used without 1 sec throttling

### Architecture overview

MVVM-C - Model-View-ViewModel-Coordinator is used as a template to build a screen. The implementation provided in the source code uses a non-strict approach in defining each layer of MVVM-C. In other words, each layer is filled and created based on the actual need, to make the implementation compact and flexible. As a result, some of the layers might slightly differ between different screens and/or be skipped.

- **View** - as plain as possible UI without business logic. Represented by UIViewController + its UIView. A view can interact with ViewModel to request decisions and supply events: by triggering event-based functions/callbacks (Input) and filling UI-related closures that are called by ViewModel when necessary.
- **ViewModel** - handles View events and triggers its corresponding UI updates. Might use a Model when states, data fetching, or calculation is complicated enough. ViewModel is not responsible for actual UI displaying. Represented by 2 protocols ViewModelInputs && ViewModelOutputs. 2 protocols are chosen for flexibility and could be represented by 2 connected ViewModel classes. However, in most cases it's more than enough to have one ViewModel that conforms to these 2 protocols (Inspired by Kickstarter iOS open-source app).
- **Model** - representation of a business logic + states, complicated enough to be separated from ViewModel.
- **Services / Providers** - classes that provide an API to external services (e.g. FourSquare API), usually is an extension of a Model layer to provide additional functionality.
- **Coordinator** - represents an external UX flow (e.g. navigation between screens, opening external applications) by building a parallel to ViewController hierarchy and handling external for view UX requests.

#### Rationale to use MVVM-C

MVVM-C is chosen due to: 
- Less features density per screen, therefore fewer layers necessary.
- (C) - coordinators allow to isolate changes and move to another architecture cheaper (if it would be necessary). Plus additional testability.

### Testability

Some of the XCTestCases are implemented in integration-way fashion (e.g. Service+RequestBuilder, Coordinator + UIViewController), even though usually it's possible to make it fully decoupled (protocols). This decision is made based time and value optimization => write less tests that cover more. However, in some cases protocols are used to help with testing which otherwise is not possible.

- **Unit tests.** Default test targets: ViewModel, Coordinator, other Models, Services 
    - ViewControllers aren't covered in unit tests based on the assumption that they are part of the plain UI. It's better to cover them with XCUI tests.
- **XCUI tests.** Aren't implemented due to limited time.