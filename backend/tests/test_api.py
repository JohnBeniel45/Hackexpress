import unittest
from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

class TestGridFlowAPI(unittest.TestCase):
    def test_root_endpoint(self):
        response = client.get("/")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "online")

    def test_get_stations(self):
        response = client.get("/stations")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertGreater(data["total"], 0)
        self.assertIn("name", data["stations"][0])

    def test_predict_wait_xgboost(self):
        payload = {
            "station_id": 1,
            "queue_length": 3,
            "chargers_total": 8,
            "time_of_day": "18:30",
            "day_of_week": "Tue",
            "grid_load": 0.65,
            "weather_temp_c": 28.0,
            "is_raining": False
        }
        response = client.post("/predict_wait", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("predicted_wait_min", data)
        self.assertGreater(data["predicted_wait_min"], 0)
        self.assertEqual(data["model_used"], "XGBoost Regressor v2.1")

    def test_recommendation_normal_user(self):
        payload = {
            "user_id": "test_user_01",
            "lat": 12.9716,
            "lon": 77.5946,
            "battery_pct": 45.0,
            "vehicle_type": "Sedan",
            "membership": "normal"
        }
        response = client.post("/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("recommended_station", data)
        self.assertIn("score_breakdown", data)
        self.assertEqual(data["priority_level"], "NORMAL")

    def test_recommendation_emergency_leapfrog(self):
        # Critical battery (5%) or Ambulance should trigger URGENT_LEAPFROG
        payload = {
            "user_id": "emergency_ambulance_1",
            "lat": 12.9716,
            "lon": 77.5946,
            "battery_pct": 5.0,
            "vehicle_type": "Ambulance",
            "membership": "emergency_priority"
        }
        response = client.post("/recommend", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["priority_level"], "URGENT_LEAPFROG")
        self.assertIn("Emergency Leapfrog", data["ai_rationale"])

    def test_reservation_flow(self):
        payload = {
            "user_id": "driver_42",
            "station_id": 2,
            "slot_time": "2026-10-07 18:00",
            "vehicle_type": "SUV",
            "battery_pct": 20.0,
            "membership": "premium",
            "duration_minutes": 30
        }
        response = client.post("/reserve", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "confirmed")
        self.assertEqual(data["priority_tier"], "PREMIUM")
        self.assertIn("RES-", data["reservation_id"])

    def test_v2v_energy_transfer(self):
        payload = {
            "donor_user_id": "peer_donor_01",
            "receiver_user_id": "peer_receiver_01",
            "kwh_amount": 10.0,
            "transfer_power_kw": 22.0
        }
        response = client.post("/v2v/transfer", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "completed")
        self.assertEqual(data["kwh_transferred"], 10.0)
        self.assertGreater(data["green_credits_earned"], 0)

    def test_simulation_benchmark_37pct_reduction(self):
        response = client.get("/analytics/simulation/benchmark")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        reduction = data["impact_metrics"]["queue_reduction_percentage"]
        # Validates queue cut around ~37% as in simulation literature
        self.assertGreater(reduction, 25.0)
        self.assertLess(reduction, 55.0)

if __name__ == "__main__":
    unittest.main()
