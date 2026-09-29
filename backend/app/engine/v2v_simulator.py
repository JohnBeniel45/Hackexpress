import uuid
import math
from typing import List, Dict, Any

class V2VSimulator:
    def __init__(self):
        # Simulated active peers parked or cruising in Bengaluru
        self.active_peers = [
            {
                "user_id": "peer_donor_01",
                "vehicle_model": "Hyundai Ioniq 5 (72.6 kWh)",
                "battery_pct": 92.0,
                "lat": 12.9720,
                "lon": 77.5950,
                "distance_km": 0.4,
                "role": "donor",
                "max_shareable_kwh": 25.0
            },
            {
                "user_id": "peer_donor_02",
                "vehicle_model": "Tata Curvv EV (55 kWh)",
                "battery_pct": 84.0,
                "lat": 12.9780,
                "lon": 77.6010,
                "distance_km": 1.2,
                "role": "donor",
                "max_shareable_kwh": 18.0
            },
            {
                "user_id": "peer_receiver_01",
                "vehicle_model": "Tata Nexon EV (40.5 kWh)",
                "battery_pct": 8.0,
                "lat": 12.9690,
                "lon": 77.5930,
                "distance_km": 0.6,
                "role": "receiver",
                "max_shareable_kwh": 0.0
            }
        ]
        self.transfer_history: List[Dict[str, Any]] = []

    def get_nearby_peers(self, user_lat: float, user_lon: float, user_role: str = "receiver") -> List[Dict[str, Any]]:
        """
        If user is receiver, find nearby donors.
        If user is donor, find nearby stranded receivers.
        """
        target_role = "donor" if user_role == "receiver" else "receiver"
        results = []
        for p in self.active_peers:
            if p["role"] == target_role:
                p_copy = dict(p)
                # Compute distance
                dlat = (p["lat"] - user_lat) * 111.0
                dlon = (p["lon"] - user_lon) * 111.0 * math.cos(math.radians(user_lat))
                p_copy["distance_km"] = round(math.sqrt(dlat**2 + dlon**2), 2)
                results.append(p_copy)
        results.sort(key=lambda x: x["distance_km"])
        return results

    def execute_virtual_transfer(
        self,
        donor_id: str,
        receiver_id: str,
        kwh_amount: float = 10.0,
        donor_battery_pct: float = 90.0,
        receiver_battery_pct: float = 10.0,
        battery_capacity_kwh: float = 60.0,
        transfer_power_kw: float = 22.0
    ) -> Dict[str, Any]:
        """
        Simulates peer-to-peer V2V energy transfer.
        Updates SOC states and grants EcoCredits.
        """
        pct_delta = round((kwh_amount / battery_capacity_kwh) * 100.0, 1)
        
        donor_new = max(20.0, round(donor_battery_pct - pct_delta, 1))
        receiver_new = min(100.0, round(receiver_battery_pct + pct_delta, 1))
        
        # Duration: hours = kWh / kW -> minutes = (kWh / kW) * 60
        duration_minutes = round((kwh_amount / max(5.0, transfer_power_kw)) * 60.0, 1)
        
        # Incentives: 15 EcoCredits per kWh shared + 0.82 kg CO2 avoided by preventing diesel tow
        credits_earned = int(kwh_amount * 15)
        carbon_offset_kg = round(kwh_amount * 0.82, 2)
        
        session_id = f"V2V-{uuid.uuid4().hex[:6].upper()}"
        
        result = {
            "session_id": session_id,
            "status": "completed",
            "donor_user_id": donor_id,
            "receiver_user_id": receiver_id,
            "kwh_transferred": kwh_amount,
            "donor_initial_pct": donor_battery_pct,
            "donor_final_pct": donor_new,
            "receiver_initial_pct": receiver_battery_pct,
            "receiver_final_pct": receiver_new,
            "duration_minutes": duration_minutes,
            "green_credits_earned": credits_earned,
            "carbon_offset_kg": carbon_offset_kg,
            "message": f"Successfully transferred {kwh_amount} kWh in {duration_minutes} min. Donor awarded {credits_earned} Green Credits!"
        }
        
        self.transfer_history.append(result)
        return result

v2v_simulator = V2VSimulator()
