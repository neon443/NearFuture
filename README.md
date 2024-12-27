# NearFuture

Near Future is a SwiftUI App to help people to track upcoming events - Holidays, Trips, Birthdays, Weddings, Anniversaries

## Roadmap
- [x] Add and delete events
- [x] Descriptions
- [x] Icons
- [x] Event colors
- [ ] Recurrence
- [x] Search
- [ ] Apple Watch App
- [ ] Home Screen Widgets
- [ ] Lock Screen Widgets

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
1. Clone the repository and open the `.xcodeproj`:
   ```bash
   git clone https://github.com/your-repo/NearFuture.git
   cd NearFuture
   open NearFuture.xcodeproj
   ```
2. In the Project, Under Targets and under Signing & Capabilities, select your Team ID and change the Bundle ID
3. In `Product > Destination` Select your iOS device or Simulator
4. Hit `Command + R` to Build and Run the Project

## Contributing
Contributions are welcome! just follow these:
1. Follow [#Compiling] to get a copy on your machine
2. Optionally create a feature branch for your additions
3. Open a pull request

## Used Tools/Frameworks
- Swift & SwiftUI by Apple
- **SFSymbolsPicker** by [alessiorubicini/SFSymbolsPickerForSwiftUI].
