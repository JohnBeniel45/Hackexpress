# 🎤 GridFlow AI - Pitch Deck & Hackathon Demo Walkthrough

---

## 📽️ Slide Deck Outline (Ready for Presentation)

### Slide 1: Title & The Vision
- **Header**: GridFlow AI: Intelligent EV Charging & V2V Energy Coordination
- **Tagline**: Eliminating queue bottlenecks, balancing power grids, and empowering peer energy sharing.
- **Team**: Hackexpress Team
- **Key Stat**: Public EV chargers in India surged ~10× from 5,151 in 2022 to ~52,700 by 2026, yet driver charging anxiety remains the #1 barrier to EV adoption.

---

### Slide 2: The Problem: The Uncoordinated Bottleneck
- **Long Unpredictable Queues**: Drivers arrive at chargers without knowing wait times; stations suffer severe crowding.
- **Transformer & Grid Overload**: Clusters of EVs fast-charging concurrently strain local power distribution substations (DISCOMs).
- **Stranded EVs**: Drivers with low battery (<10%) or emergency vehicles (Ambulances) get stuck behind fully occupied bays.

---

### Slide 3: Our Solution: The GridFlow AI Platform
- **End-to-End Orchestration**:
  1. **XGBoost Wait-Time Prediction**: Forecasts charging delay in minutes with sub-50ms latency.
  2. **Multi-Objective Recommender**: Scores stations by distance, battery SOC, predicted wait, and local grid load.
  3. **Emergency Leapfrog Scheduling**: Guarantees preemption for ambulances & critical-battery vehicles.
  4. **Vehicle-to-Vehicle (V2V) Energy Sharing**: Peer-to-peer charging simulator for stranded vehicles.
  5. **Cross-Platform Mobile Flutter App**: Modern cyber-emerald UI for EV drivers.

---

### Slide 4: AI & ML Engine Benchmark
- **Algorithm Comparison**:
  - Linear Regression: $R^2 = 0.876$, MAE = 2.24 min
  - Random Forest: $R^2 = 0.973$, MAE = 1.03 min
  - **XGBoost Regressor (Champion)**: **$R^2 = 0.9801$**, **MAE = 0.92 min**, **RMSE = 1.25 min**
- **Top Features**: Queue-to-plug ratio (39.9%), charger power in kW (36.5%), queue length (14.5%), total plugs (6.8%).

---

### Slide 5: Simulation Results: ~37% Wait Reduction
- **500-Vehicle Monte Carlo Peak Fleet Run**:
  - **Average Wait Time**: Dropped from **24.8 min $\rightarrow$ 15.6 min** (**-37.1% cut**).
  - **95th Percentile Delay**: Cut in half from **52 min $\rightarrow$ 28 min**.
  - **Transformer Overload Incidents**: Reduced by **85%** (from 14 to 2 events/day).
  - **Grid Load Variance**: **58.4% smoother**, preventing blackout risks.

---

### Slide 6: P2P Vehicle-to-Vehicle (V2V) Energy Sharing
- When stations are congested or an EV is stranded with 8% battery:
  - Nearby Donor (e.g. Hyundai Ioniq at 92%) shares 10 kWh over mobile DC link.
  - Receiver reaches safe 27% SOC; Donor earns **150 EcoCredits** + carbon offset badge.
  - Zero diesel tow-truck needed!

---

### Slide 7: Business Model & Monetization
- **Per-Charge Commission**: 2–3% fee on slots booked through GridFlow AI.
- **Premium VIP Subscriptions**: Monthly membership for zero-wait bay guarantees.
- **Utility / DISCOM Demand-Response Incentives**: Revenue sharing with power grids for shaving peak transformer loads.

---

## 🚀 Live Demo Walkthrough Script (2–3 Minutes)

### Step 1: Open the Mobile App / Web Preview
- **Action**: Open `web_preview/index.html` or run `flutter run` on Android/Chrome.
- **Show Judges**:
  - Live **Battery Ring Gauge** at 28%.
  - Vehicle Profile: *Tata Nexon EV Max*.
  - Show the live **Nearby Stations** list showing real-time plug availability and grid stress.

### Step 2: Demonstrate Normal AI Recommendation
- **Action**: Tap **"FIND OPTIMAL CHARGER (AI)"** (or click the AI Match tab).
- **Show Judges**:
  - Top match is returned with score (e.g. 88/100).
  - Point out the **AI Rationale box**: *"Optimal Balance: 4 plugs free, low wait time (4.2 min), green grid load."*
  - Show the **Factor Breakdown bars** (Proximity + Wait Score + Grid Impact).

### Step 3: Demonstrate Emergency Leapfrog Preemption (The "Wow" Factor!)
- **Action**: Return to Home tab, drag the **Battery Slider down to 8%** (or switch Vehicle Type to *Ambulance*).
- **Notice the Instant UI Shift**:
  - Bright Red Alert appears: **"🚨 EMERGENCY LEAPFROG ACTIVE"**.
- **Action**: Tap **"FIND OPTIMAL CHARGER (AI)"**.
  - Match is tagged **"🚨 EMERGENCY LEAPFROG"** (Score jumps to 98/100).
- **Action**: Tap **"CONFIRM & LOCK THIS BAY"**.
  - Modal pops up with **Digital Pass QR Code**:
  - Status: *"Preemption Leapfrog confirmed. Bay #1 (Reserved Emergency Fast Bay) locked in!"*

### Step 4: Demonstrate V2V Energy Sharing
- **Action**: Switch to the **V2V Share** tab.
- **Show Judges**:
  - Animated electric power beam flowing between Donor (92%) and Receiver (Your EV).
  - Drag the transfer slider to 10 kWh.
  - Tap **"EXECUTE V2V POWER TRANSFER"**.
  - Watch the live battery percentage update and award +150 EcoCredits!

### Step 5: Demonstrate Grid Analytics & Impact
- **Action**: Switch to the **Analytics** tab.
- **Show Judges**:
  - The headline banner: **"37.1% WAIT-TIME REDUCTION"**.
  - The side-by-side comparison table (FCFS 24.8 min vs AI 15.6 min).
  - XGBoost accuracy metrics ($R^2 = 0.9801$, MAE = 0.92 min).
