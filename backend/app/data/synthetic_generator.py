import os
import json
import math
import random
import pandas as pd
import numpy as np

def generate_grid_load(hour: int, is_weekend: bool) -> float:
    """
    Simulates local grid demand (base load + daily rhythm) using dual sinusoidal peaks:
    Morning peak (09:00 - 12:00) and Evening peak (18:00 - 22:00) with random grid fluctuations.
    """
    # Normalized hour angle
    # Peak 1 at 10am, Peak 2 at 20pm
    morning_peak = math.exp(-((hour - 10.5) ** 2) / 6.0)
    evening_peak = 1.2 * math.exp(-((hour - 19.5) ** 2) / 7.0)
    base_load = 0.35 if not is_weekend else 0.28
    
    load = base_load + 0.32 * morning_peak + 0.38 * evening_peak
    # Add random grid spike or dip
    load += random.uniform(-0.06, 0.08)
    return round(float(np.clip(load, 0.15, 0.98)), 3)

def generate_synthetic_dataset(n_samples: int = 5000, output_path: str = None) -> pd.DataFrame:
    """
    Generates historical EV charging sessions across stations with realistic
    queue buildup, charging speeds, grid load constraints, and weather effects.
    """
    seed_stations_path = os.path.join(os.path.dirname(__file__), "stations_seed.json")
    with open(seed_stations_path, "r") as f:
        stations = json.load(f)
    
    rows = []
    days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    for i in range(n_samples):
        st = random.choice(stations)
        st_id = st["id"]
        chargers_total = st["chargers_total"]
        power_kw = st["power_kw"]
        
        day_idx = random.randint(0, 6)
        day_str = days[day_idx]
        is_weekend = 1 if day_idx >= 5 else 0
        hour = random.randint(0, 23)
        minute = random.choice([0, 15, 30, 45])
        
        # Grid load profile
        grid_load = generate_grid_load(hour, bool(is_weekend))
        
        # Weather simulation (Bengaluru climate)
        # Higher temperatures in afternoon
        temp_c = round(22.0 + 12.0 * math.sin(math.pi * (hour - 6) / 14) + random.uniform(-2, 3), 1)
        temp_c = max(18.0, min(40.0, temp_c))
        is_raining = 1 if (random.random() < 0.15 and hour >= 15) else 0
        
        # Arrival rate driven by hour of day and location
        peak_factor = 1.0
        if 8 <= hour <= 11 or 17 <= hour <= 21:
            peak_factor = random.uniform(1.6, 2.8)
        elif 0 <= hour <= 5:
            peak_factor = random.uniform(0.1, 0.4)
        
        # Queue length depends on peak factor and available chargers
        queue_expected = (chargers_total * 0.45 * peak_factor)
        queue_len = int(np.clip(np.random.poisson(queue_expected), 0, chargers_total * 3))
        
        # Available chargers right now
        chargers_busy = min(chargers_total, int(queue_len * 0.8 + random.randint(1, 3)))
        chargers_avail = max(0, chargers_total - chargers_busy)
        
        # Charging session average duration (minutes) depends on power_kw
        # 120kW DC takes ~20 min; 60kW takes ~35 min; 30kW takes ~55 min
        avg_session_min = 1200.0 / power_kw  # approx minutes per vehicle
        
        # Wait time physics:
        # If chargers are available, wait is 0 to 2 minutes
        # If queue > 0, wait time = (queue_len / chargers_total) * avg_session_min
        if queue_len == 0 and chargers_avail > 0:
            actual_wait = round(random.uniform(0.0, 1.8), 1)
        else:
            effective_capacity = max(1.0, float(chargers_total))
            
            # Grid throttle effect: When grid_load > 0.75, chargers throttle speed by 15-30%
            grid_throttle = 1.0 + (max(0.0, grid_load - 0.75) * 1.5)
            
            # Rain slows down operations slightly (connecting cables in rain)
            rain_delay = 1.15 if is_raining else 1.0
            
            base_wait = (queue_len / effective_capacity) * avg_session_min * grid_throttle * rain_delay
            noise = random.gauss(0, 1.2)
            actual_wait = round(max(0.0, base_wait + noise), 1)
        
        rows.append({
            "station_id": st_id,
            "hour": hour,
            "minute": minute,
            "day_of_week": day_idx,
            "day_name": day_str,
            "is_weekend": is_weekend,
            "chargers_total": chargers_total,
            "chargers_available": chargers_avail,
            "queue_len": queue_len,
            "power_kw": power_kw,
            "grid_load": grid_load,
            "weather_temp_c": temp_c,
            "is_raining": is_raining,
            "wait_time_minutes": actual_wait
        })
        
    df = pd.DataFrame(rows)
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        df.to_csv(output_path, index=False)
        print(f"Generated {len(df)} synthetic charging sessions saved to {output_path}")
    return df

if __name__ == "__main__":
    out = os.path.join(os.path.dirname(__file__), "charging_logs.csv")
    df = generate_synthetic_dataset(n_samples=6000, output_path=out)
    print("Summary stats of wait_time_minutes:")
    print(df["wait_time_minutes"].describe())
