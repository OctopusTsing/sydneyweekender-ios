# Sydney Weekender iOS

Sydney Weekender is a SwiftUI iOS app for planning practical one-day weekend trips around Sydney. It combines local venue data, weather-aware recommendations, optional AI itinerary generation, saved trip history, and a check-in map for visited places.

The app is designed with international students and budget-conscious explorers in mind: choose a date, group size, and interests, then generate a Sydney day plan with real venues, notes, transport tips, and weather context.

## Features

- **Personalized itinerary generation** based on date, group size, selected interests, and Sydney weather.
- **Weather-aware planning** using Open-Meteo forecast data for Sydney.
- **Offline fallback mode** powered by bundled local venue data, so the app remains usable without an API key.
- **Optional AI generation** through an OpenAI-compatible chat completions endpoint.
- **Saved itinerary history** using SwiftData.
- **Check-in map** showing visited venues with MapKit annotations.
- **Configurable AI settings** for API key, base URL, and model name.
- **Rotating Sydney hero photography** on the home screen.

## Screens

- **Home**: choose travel date, group size, and interests.
- **Itinerary**: view the generated timeline, weather summary, venue details, notes, and transport tips.
- **Footprint**: see checked-in venues on a map.
- **History**: browse or delete saved itineraries.
- **Settings**: configure optional AI credentials.

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- MapKit
- URLSession async/await networking
- Open-Meteo weather API
- OpenAI-compatible chat completions API support

## Project Structure

```text
sydweekender-ios/
├── ContentView.swift
├── sydweekender_iosApp.swift
├── Core/
│   ├── Config/
│   ├── Data/
│   ├── Network/
│   └── Theme/
├── Features/
│   ├── Home/
│   ├── Itinerary/
│   ├── Map/
│   ├── History/
│   └── Settings/
├── Models/
├── Resources/
│   ├── venues.json
│   └── hero_images/
└── Assets.xcassets/
```

## Requirements

- Xcode with SwiftUI, SwiftData, and MapKit support
- iOS simulator or device compatible with the project deployment target
- Internet access for weather data and optional AI generation

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/sydweekender-ios.git
   cd sydweekender-ios
   ```

2. Open the project in Xcode:

   ```bash
   open sydweekender-ios.xcodeproj
   ```

3. Select the `sydweekender-ios` scheme.

4. Choose an iOS simulator or connected device.

5. Build and run.

The app works without AI credentials. If no API key is configured, it automatically uses the offline itinerary generator and bundled venue database.

## AI Configuration

AI generation is optional. Open the app's **Settings** tab and provide:

- **AI API Key**
- **Base URL**
- **Model Name**

By default, the app is configured for an OpenAI-compatible endpoint:

```text
https://generativelanguage.googleapis.com/v1beta/openai/
```

Default model:

```text
gemini-2.5-flash
```

The request path is normalized to `/chat/completions`, so compatible providers can be used as long as they support a chat completions-style API.

## Data Sources

- `Resources/venues.json` contains bundled Sydney venue data grouped by interest type.
- Open-Meteo is used for weather forecasts.
- User-saved itineraries and check-ins are stored locally with SwiftData.

## Privacy and Security

- API keys are entered by the user inside the app and stored locally with `AppStorage`.
- No API keys should be committed to the repository.
- Saved itineraries and check-ins are stored locally on the user's device.
- Weather requests are made to Open-Meteo.
- AI requests are only sent when an API key is configured.

## Build Verification

You can build from the command line with:

```bash
xcodebuild \
  -project sydweekender-ios.xcodeproj \
  -scheme sydweekender-ios \
  -destination generic/platform=iOS \
  build
```

For local unsigned builds, you can also use:

```bash
xcodebuild \
  -project sydweekender-ios.xcodeproj \
  -scheme sydweekender-ios \
  -destination generic/platform=iOS \
  build CODE_SIGNING_ALLOWED=NO
```

## Roadmap Ideas

- Itinerary detail pages for saved trips.
- Share/export itinerary support.
- Better check-in flows from itinerary stops.
- Venue filtering by distance, cost, and opening hours.
- More Sydney neighborhoods and seasonal recommendations.

## Contributing

Contributions are welcome. Please keep changes focused, follow the existing SwiftUI style, and test the main itinerary generation flow before opening a pull request.

## License

Add a license file before publishing if you want others to use, modify, or redistribute the project.
