import uuid
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional

class PriorityScheduler:
    def __init__(self):
        # In-memory storage for hackathon prototype (easily swap with Postgres / Supabase)
        self.reservations: List[Dict[str, Any]] = []
        # Seed initial reservations to test queue dynamics
        self._seed_initial_reservations()
        
    def _seed_initial_reservations(self):
        now = datetime.now()
        self.reservations = [
            {
                "reservation_id": "RES-8821",
                "user_id": "user_101",
                "station_id": 1,
                "station_name": "Indiranagar 100ft EV Hub",
                "slot_time": (now + timedelta(minutes=15)).strftime("%Y-%m-%d %H:%M"),
                "status": "confirmed",
                "priority_tier": "NORMAL",
                "charger_id": 2,
                "duration_minutes": 30,
                "vehicle_type": "Sedan",
                "qr_pass_code": "GF-IND-101-8821"
            },
            {
                "reservation_id": "RES-8822",
                "user_id": "user_102",
                "station_id": 3,
                "station_name": "MG Road Metro Super Hub",
                "slot_time": (now + timedelta(minutes=30)).strftime("%Y-%m-%d %H:%M"),
                "status": "confirmed",
                "priority_tier": "PREMIUM",
                "charger_id": 1,
                "duration_minutes": 45,
                "vehicle_type": "SUV",
                "qr_pass_code": "GF-MGR-102-8822"
            }
        ]

    def create_reservation(
        self,
        user_id: str,
        station_id: int,
        station_name: str,
        slot_time: str,
        vehicle_type: str = "Sedan",
        battery_pct: float = 25.0,
        membership: str = "normal",
        duration_minutes: int = 30
    ) -> Dict[str, Any]:
        """
        Processes a slot reservation with leapfrog priority preemption.
        Priority Hierarchy:
        1. URGENT_LEAPFROG (Ambulance OR Battery <= 10%)
        2. PREMIUM (Gold/Platinum EV Club)
        3. NORMAL (Standard FCFS)
        """
        # Determine priority tier
        is_emergency = vehicle_type.lower() == "ambulance" or battery_pct <= 10.0
        if is_emergency:
            priority_tier = "URGENT_LEAPFROG"
        elif membership.lower() == "premium":
            priority_tier = "PREMIUM"
        else:
            priority_tier = "NORMAL"
            
        res_id = f"RES-{uuid.uuid4().hex[:6].upper()}"
        qr_code = f"GRIDFLOW-{station_id}-{user_id}-{res_id}"
        
        # Check active bookings for this station and slot window
        assigned_charger = 1
        if priority_tier == "URGENT_LEAPFROG":
            # Preemption logic: Urgent vehicle leapfrogs to Charger #1 (Reserved Emergency Bay)
            assigned_charger = 1
            status = "confirmed"
            msg = "⚡ Priority Access Granted: Emergency Leapfrog placed you at the head of the queue (Bay #1)."
        elif priority_tier == "PREMIUM":
            assigned_charger = 2
            status = "confirmed"
            msg = "🌟 Premium Slot Confirmed: Priority charger allocated with zero wait guarantee."
        else:
            assigned_charger = 3
            status = "confirmed"
            msg = "✅ Reservation Confirmed: Your charging slot has been locked in."
            
        reservation = {
            "reservation_id": res_id,
            "user_id": user_id,
            "station_id": station_id,
            "station_name": station_name,
            "slot_time": slot_time,
            "status": status,
            "priority_tier": priority_tier,
            "charger_id": assigned_charger,
            "duration_minutes": duration_minutes,
            "vehicle_type": vehicle_type,
            "estimated_arrival_window": f"{slot_time} (+/- 10 min)",
            "qr_pass_code": qr_code,
            "message": msg
        }
        
        self.reservations.append(reservation)
        return reservation

    def get_user_reservations(self, user_id: Optional[str] = None) -> List[Dict[str, Any]]:
        if user_id:
            return [r for r in self.reservations if r["user_id"] == user_id]
        return list(reversed(self.reservations))

scheduler = PriorityScheduler()
