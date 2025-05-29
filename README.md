<div align="center">
    <br/>
    <p>
        <img src="https://github.com/neon443/NearFuture/blob/main/Resources/Assets.xcassets/AppIcon.appiconset/NearFutureIcon.png?raw=true" title="dockphobia" alt="dockphobia icon" width="100" />
    </p>
      <h3>Near Future</h3>
	    <p>
        <a href="https://apps.apple.com/us/app/near-future-event-tracker/id6744963429">
            download
            <img alt="GitHub Release" src="https://img.shields.io/itunes/v/6744963429">
        </a>
    </p>
    <p>
        make your Dock scared of the mouse
        <br/>
        <a href="https://neon443.github.io">
            made by neon443
        </a>
    </p>
    <br/>
</div>

**Near Future** is a SwiftUI App to help people track upcoming events - Holidays, Trips, Birthdays, Weddings, Anniversaries.

## Roadmap
- [x] Add and delete events
- [x] Descriptions
- [x] Icons
- [x] Event colors
- [x] Recurrence
- [x] Search
- [ ] Notifications
- [ ] Apple Watch App
- [x] Home Screen Widgets
- [ ] Lock Screen Widgets
- [ ] Later Box
- [ ] Sort by
- [ ] Reorder Events
- [ ] Archive
- [ ] Collaboration
- [ ] Autocomplete tasks
- [ ] Settings

## Features
- **Event Creation**: Create events with a name, description, date, recurrence, and an icon
- **Symbol Picker**: Choose an icon for your event using an SF Symbol Picker
- **Recurring Events**: Set events to repeat daily, weekly, monthly, or yearly
- **Search Functionality**: Quickly find events using the search bar
- **Persistence**: Events are saved locally and loaded on app launch via UserDefaults
- **Animations**: Smooth animations - what more can I say lol

## Compiling
### Prerequisites
- **Xcode 15+**
- **iOS 17+** (if planning to install to a physical device)
1. Fork and Clone the repository and open the `.xcodeproj`:
   ```bash
   git clone https://github.com/your-username/NearFuture.git
   cd NearFuture
   open NearFuture.xcodeproj
   ```
2. In the Project, Under Targets and under Signing & Capabilities, select your Team ID and change the Bundle ID
3. In `Product > Destination` Select your iOS device or Simulator
4. Hit `Command + R` to Build and Run the Project

## Contributing
Contributions are welcome! Just follow these steps:
1. Follow [#Compiling] to get a copy on your machine
2. Optionally create a feature branch for your additions
3. Open a pull request

## Used Tools/Frameworks
- Swift & SwiftUI by Apple
- **SFSymbolsPicker** by [alessiorubicini/SFSymbolsPickerForSwiftUI].
