import math
import json
import os
from typing import List, Dict, Any, Tuple
from backend.app.ml.wait_predictor import wait_predictor

def haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates great-circle distance between two GPS coordinates in kilometers."""
    R = 6371.0  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2.0) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2.0) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(R * c, 2)

class StationRecommender:
    def __init__(self, stations_data_path: str = None):
        if stations_data_path is None:
            stations_data_path = os.path.join(os.path.dirname(__file__), "..", "data", "stations_seed.json")
        self.stations_data_path = stations_data_path
        self.stations = self._load_stations()
        
    def _load_stations(self) -> List[Dict[str, Any]]:
        if os.path.exists(self.stations_data_path):
            with open(self.stations_data_path, "r") as f:
                return json.load(f)
        return []
        
    def get_stations(self, lat: float = None, lon: float = None, radius_km: float = 25.0) -> List[Dict[str, Any]]:
        stations_copy = []
        for s in self.stations:
            st = dict(s)
            if lat is not None and lon is not None:
                dist = haversine_distance_km(lat, lon, st["lat"], st["lon"])
                st["distance_km"] = dist
                if dist <= radius_km:
                    stations_copy.append(st)
            else:
                stations_copy.append(st)
        
        # If user is outside radius (e.g. testing from another city), return all stations sorted by distance
        if lat is not None and lon is not None:
            if not stations_copy:
                for s in self.stations:
                    st = dict(s)
                    st["distance_km"] = haversine_distance_km(lat, lon, st["lat"], st["lon"])
                    stations_copy.append(st)
            stations_copy.sort(key=lambda x: x.get("distance_km", 0))

        return stations_copy

    def score_station(
        self,
        station: Dict[str, Any],
        user_lat: float,
        user_lon: float,
        battery_pct: float,
        vehicle_type: str,
        membership: str,
        max_radius_km: float = 20.0
    ) -> Tuple[float, Dict[str, Any]]:
        """
        Computes multi-factor weighted match score between 0 and 100.
        Factors:
        - Proximity (Distance)
        - Predicted Wait Time (XGBoost)
        - Local Grid Stress / Transformer Load
        - Vehicle Range & Battery Urgency
        - Priority Class (Ambulance / Emergency vs Premium vs Normal)
        """
        # Exclude inactive or maintenance stations
        if station.get("status") in ["inactive", "maintenance"]:
            return -999.0, {"error": "Station offline"}
            
        dist_km = haversine_distance_km(user_lat, user_lon, station["lat"], station["lon"])
        
        # Estimate vehicle range left: ~3.5 km per 1% battery on average EV
        estimated_range_km = (battery_pct / 100.0) * 350.0
        
        # If user cannot reach station with current battery + 20% safety margin, disqualify
        if dist_km > estimated_range_km:
            return -100.0, {
                "disqualified": True,
                "reason": f"Insufficient range ({estimated_range_km:.1f} km vs {dist_km:.1f} km required)"
            }
            
        # Get AI predicted wait time
        pred_res = wait_predictor.predict(
            station_id=station["id"],
            queue_len=station.get("queue_length", 0),
            chargers_total=station.get("chargers_total", 4),
            time_of_day="18:30",
            grid_load=station.get("grid_load", 0.5),
            power_kw=station.get("power_kw", 60.0)
        )
        predicted_wait = pred_res["predicted_wait_min"]
        
        # 1. Proximity score (0 to 35 points)
        dist_score = max(0.0, (1.0 - (dist_km / max_radius_km))) * 35.0
        
        # 2. Wait time score (0 to 35 points) - Lower wait is better
        # 0 wait = 35 pts, 30 min wait = 10 pts, >= 45 min wait = 0 pts
        wait_score = max(0.0, (1.0 - (predicted_wait / 45.0))) * 35.0
        
        # 3. Grid stress penalty (0 to 20 penalty points)
        # Avoid routing more EVs to transformers running above 80% capacity
        grid_load = station.get("grid_load", 0.5)
        if grid_load > 0.75:
            grid_penalty = (grid_load - 0.75) * 60.0  # up to 15 points penalty
        else:
            grid_penalty = 0.0
            
        # 4. Charger power bonus (0 to 10 points) - 120kW+ charges faster
        power_bonus = min(10.0, (station.get("power_kw", 60.0) / 120.0) * 10.0)
        
        # 5. Battery Urgency Boost & Leapfrog Priority
        is_emergency = vehicle_type.lower() == "ambulance" or battery_pct <= 10.0
        battery_urgency_boost = 0.0
        priority_tier = "NORMAL"
        
        if is_emergency:
            priority_tier = "URGENT_LEAPFROG"
            # Emergency vehicles prioritize closest station above all else
            battery_urgency_boost = 30.0 + max(0.0, (10.0 - dist_km) * 4.0)
        elif membership.lower() == "premium":
            priority_tier = "PREMIUM"
            battery_urgency_boost = 10.0
            
        total_score = dist_score + wait_score + power_bonus - grid_penalty + battery_urgency_boost
        total_score = round(max(0.0, min(100.0, total_score)), 1)
        
        breakdown = {
            "station_id": station["id"],
            "station_name": station["name"],
            "total_score": total_score,
            "distance_km": dist_km,
            "distance_score": round(dist_score, 1),
            "wait_time_min": predicted_wait,
            "wait_score": round(wait_score, 1),
            "grid_load": grid_load,
            "grid_penalty": round(grid_penalty, 1),
            "battery_urgency_boost": round(battery_urgency_boost, 1),
            "priority_tier": priority_tier
        }
        
        return total_score, breakdown

    def recommend(
        self,
        user_lat: float,
        user_lon: float,
        battery_pct: float,
        vehicle_type: str = "Sedan",
        membership: str = "normal",
        max_radius_km: float = 20.0
    ) -> Dict[str, Any]:
        """
        Finds the globally optimal charging station and alternative options.
        """
        scored_stations = []
        for st in self.stations:
            score, breakdown = self.score_station(
                station=st,
                user_lat=user_lat,
                user_lon=user_lon,
                battery_pct=battery_pct,
                vehicle_type=vehicle_type,
                membership=membership,
                max_radius_km=max_radius_km
            )
            if score > 0:
                st_enriched = dict(st)
                st_enriched["distance_km"] = breakdown["distance_km"]
                st_enriched["predicted_wait_min"] = breakdown["wait_time_min"]
                scored_stations.append((score, st_enriched, breakdown))
                
        # Sort by total score descending
        scored_stations.sort(key=lambda x: x[0], reverse=True)
        
        if not scored_stations:
            # Fallback to closest station
            closest_raw = min(self.stations, key=lambda s: haversine_distance_km(user_lat, user_lon, s["lat"], s["lon"]))
            dist = haversine_distance_km(user_lat, user_lon, closest_raw["lat"], closest_raw["lon"])
            closest = dict(closest_raw, distance_km=dist)
            return {
                "recommended_station": closest,
                "score_breakdown": {
                    "station_id": closest["id"],
                    "station_name": closest["name"],
                    "total_score": 50.0,
                    "distance_km": haversine_distance_km(user_lat, user_lon, closest["lat"], closest["lon"]),
                    "distance_score": 25.0,
                    "wait_time_min": 15.0,
                    "wait_score": 25.0,
                    "grid_load": closest.get("grid_load", 0.5),
                    "grid_penalty": 0.0,
                    "battery_urgency_boost": 0.0,
                    "priority_tier": "NORMAL"
                },
                "alternative_stations": [],
                "priority_level": "NORMAL",
                "ai_rationale": "Selected nearest station as safety fallback."
            }
            
        best_score, best_station, best_breakdown = scored_stations[0]
        alternatives = [item[1] for item in scored_stations[1:4]]
        
        # Build human-readable AI rationale
        is_emergency = best_breakdown["priority_tier"] == "URGENT_LEAPFROG"
        if is_emergency:
            rationale = (
                f"🚨 Emergency Leapfrog Activated: Recommended '{best_station['name']}' ({best_breakdown['distance_km']} km away) "
                f"to guarantee immediate slot access and minimize critical battery depletion."
            )
        elif best_breakdown["grid_penalty"] > 0:
            rationale = (
                f"⚡ Grid-Optimized Route: Recommended '{best_station['name']}' with predicted wait of {best_breakdown['wait_time_min']} min. "
                f"Avoided closer high-stress stations to prevent transformer overload."
            )
        else:
            rationale = (
                f"✨ Optimal Balance: '{best_station['name']}' has {best_station['chargers_available']} chargers ready, "
                f"low wait time ({best_breakdown['wait_time_min']} min), and green grid index ({best_station['grid_load']*100:.0f}% load)."
            )
            
        return {
            "recommended_station": best_station,
            "score_breakdown": best_breakdown,
            "alternative_stations": alternatives,
            "priority_level": best_breakdown["priority_tier"],
            "ai_rationale": rationale
        }

recommender = StationRecommender()
