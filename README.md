# QuickCare

Find the fastest path to care. QuickCare compares nearby clinics by **total time** (drive + wait), guides you through a symptom check, predicts the best time to go, and lets you reserve a spot. A built-in **Clinic Portal** lets staff manage the queue, settings, and analytics.

This branch rebuilds the original web app as a **native Flutter app** for macOS, iOS, and Android. The original web version is kept in [`legacy-web/`](legacy-web/).

## Features

**Patient side**
- Home: clinics ranked by total time, live wait updates, scrolling ticker, filters (Open Now, Low Wait, In-Network)
- Symptom Checker: 5-step triage with escalation rules, recommended facility, navigate/reserve/share
- Best Time to Go: hourly wait predictions by clinic and day
- Profile: insurance, pharmacy, allergies, care preference, dependents (saved on device)
- Reserve a Spot, My Reservations, Telehealth waiting room (demo)
- Dark mode, smart symptom search

**Clinic Portal** (top-right "Clinic mode" button)
- Queue: move patients Pending → Confirmed → Arrived → In Room → Completed, notes, timeline
- Locations: multi-location capacity overview
- Analytics: reservations by hour, visit reasons, insurance mix, weekly trend, funnel
- Settings: open/closed, walk-ins, posted wait time, services, staffing and surge mode

## Data

Clinic data is **sample data** for now. Wait times are estimates, demo patients are added to the clinic queue each day, and anything marked "Demo" or "Est." is not real. Profile and reservations are stored only on the device.

QuickCare is not a medical diagnostic tool. In an emergency, call 911.

## Running it

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and run `flutter doctor`.
2. From this folder:
   ```
   flutter pub get
   flutter run
   ```
3. Pick **macOS** (or an iPhone simulator / Android emulator).

On macOS, if a build fails with "resource fork, Finder information, or similar detritus not allowed," run `xattr -cr .` and try again.

## Project layout

```
lib/
  main.dart              App start, themes, tabs, Patient/Clinic mode
  models/                Facility
  logic/                 Triage rules, predictions, storage, live updates, clinic settings
  screens/               Home, Triage, Best Time, Profile, Clinic Portal tabs
  widgets/               Cards, sheets, charts, ticker
legacy-web/              Original single-page web app
```

## Coming next

Real nearby clinics and the Map tab using Google Maps Platform. API keys will be kept out of the repository (see `.gitignore`).