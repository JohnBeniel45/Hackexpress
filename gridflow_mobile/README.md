# GridFlow AI - Flutter Mobile Application

Smart EV Charging & Peer-to-Peer (V2V) Energy Network Mobile Client.

---

## ⚡ Features
- **Live Battery SOC Management**: Interactive circular gauge with real-time battery slider (0–100%) and vehicle profile configuration (Sedan, SUV, Hatchback, Emergency Ambulance).
- **Emergency Leapfrog Queue Preemption**: Instantly activates whenever battery $\le 10\%$ or vehicle is an Ambulance, bumping the driver to the front of the queue at Emergency Bay #1.
- **Interactive Charger Map**: Radar-styled map view with color-coded station pins (Green = Available, Yellow = Busy, Red = Full), fast charging filters, and live station telemetry.
- **AI Recommendation Engine**: Weighted multi-factor scoring powered by trained XGBoost wait-time forecasting, proximity, grid transformer stress avoidance, and membership priority.
- **15-Minute Slot Reservation**: Digital charging pass ticket with QR code verification, arrival time windows, and overbooking prevention.
- **Vehicle-to-Vehicle (V2V) Energy Sharing Simulator**: Animated car-to-car power beam, peer discovery, SOC adjustment, and EcoCredits green rewards system.
- **Grid Analytics Dashboard**: Real-time validation of the **37.1% average wait-time reduction**, peak load smoothing, and transformer overload prevention.

---

## 🚀 How to Run the Flutter App

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- Android Studio / Xcode / Chrome for Web

### Steps

1. **Start the FastAPI Backend First**:
   ```bash
   cd c:\Users\user\Hackexpress
   python -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Run Flutter App**:
   ```bash
   cd c:\Users\user\Hackexpress\gridflow_mobile
   flutter pub get
   flutter run
   ```

   - To run on Android Emulator:
     ```bash
     flutter run -d emulator
     ```
   - To run on Chrome (Flutter Web):
     ```bash
     flutter run -d chrome
     ```
   - To run on Windows Desktop:
     ```bash
     flutter run -d windows
     ```

### Network Configuration for Emulator vs Real Device
In `lib/services/api_service.dart`:
- For **Android Emulator**: uses `http://10.0.2.2:8000`
- For **iOS Simulator / Desktop / Web**: uses `http://127.0.0.1:8000`
- For **Physical Mobile Phone on WiFi**: set `ApiService.setBaseUrl("http://<YOUR_LAN_IP>:8000")`
- *Note: If backend is unreachable, the app operates gracefully with built-in realistic offline data and state simulation.*
