from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class ConnectorInfo(BaseModel):
    type: str  # CCS2, CHAdeMO, Type 2 AC, Bharat DC-001
    power_kw: float
    total: int
    available: int

class Station(BaseModel):
    id: int
    name: str
    address: str
    city: str = "Bengaluru"
    lat: float
    lon: float
    chargers_total: int
    chargers_available: int
    status: str = "active"  # active, busy, full, inactive, maintenance
    grid_load: float = Field(..., ge=0.0, le=1.0, description="Local grid stress from 0.0 (idle) to 1.0 (overload)")
    power_kw: float = 60.0
    connector_types: List[str] = ["CCS2", "Type 2 AC"]
    price_per_kwh: float = 14.5
    queue_length: int = 0
    predicted_wait_min: float = 0.0
    operator: str = "GridFlow Hub"
    distance_km: Optional[float] = None

class StationListResponse(BaseModel):
    total: int
    stations: List[Station]

class PredictWaitRequest(BaseModel):
    station_id: int
    queue_length: float = Field(..., ge=0)
    chargers_total: int = Field(..., ge=1)
    time_of_day: str = "18:30"  # HH:MM format
    day_of_week: str = "Tue"   # Mon, Tue, Wed, Thu, Fri, Sat, Sun
    grid_load: Optional[float] = 0.5
    weather_temp_c: Optional[float] = 28.0
    is_raining: Optional[bool] = False

class PredictWaitResponse(BaseModel):
    station_id: int
    predicted_wait_min: float
    confidence_interval: List[float]
    model_used: str = "XGBoost Regressor v2.1"
    features_used: dict

class RecommendRequest(BaseModel):
    user_id: Optional[str] = "user_001"
    lat: float = 12.9716
    lon: float = 77.5946
    battery_pct: float = Field(..., ge=0.0, le=100.0)
    vehicle_type: str = "Sedan"  # Ambulance, Sedan, SUV, Hatchback, Auto/2W
    membership: str = "normal"   # normal, premium, emergency_priority
    target_charge_pct: Optional[float] = 80.0
    max_radius_km: Optional[float] = 15.0

class StationScoreBreakdown(BaseModel):
    station_id: int
    station_name: str
    total_score: float
    distance_km: float
    distance_score: float
    wait_time_min: float
    wait_score: float
    grid_load: float
    grid_penalty: float
    battery_urgency_boost: float
    priority_tier: str

class RecommendResponse(BaseModel):
    recommended_station: Station
    score_breakdown: StationScoreBreakdown
    alternative_stations: List[Station]
    priority_level: str  # NORMAL, PREMIUM, URGENT_LEAPFROG
    ai_rationale: str

class ReservationRequest(BaseModel):
    user_id: str
    station_id: int
    slot_time: str  # ISO string or YYYY-MM-DD HH:MM
    vehicle_type: str = "Sedan"
    battery_pct: float = 20.0
    membership: str = "normal"
    duration_minutes: int = 30

class ReservationResponse(BaseModel):
    reservation_id: str
    user_id: str
    station_id: int
    station_name: str
    slot_time: str
    status: str  # confirmed, urgent_leapfrog, waitlisted, completed
    priority_tier: str
    charger_id: int
    duration_minutes: int
    estimated_arrival_window: str
    qr_pass_code: str
    message: str

class V2VPeer(BaseModel):
    user_id: str
    vehicle_model: str
    battery_pct: float
    lat: float
    lon: float
    distance_km: float
    role: str  # donor, receiver
    max_shareable_kwh: float

class V2VMatchRequest(BaseModel):
    user_id: str
    lat: float
    lon: float
    battery_pct: float
    vehicle_type: str
    role: str  # donor, receiver
    radius_km: float = 5.0

class V2VTransferRequest(BaseModel):
    donor_user_id: str
    receiver_user_id: str
    kwh_amount: float = Field(..., ge=1.0, le=50.0)
    transfer_power_kw: float = 22.0  # V2V mobile DC rate

class V2VTransferResponse(BaseModel):
    session_id: str
    status: str  # completed, in_progress, simulated
    donor_user_id: str
    receiver_user_id: str
    kwh_transferred: float
    donor_initial_pct: float
    donor_final_pct: float
    receiver_initial_pct: float
    receiver_final_pct: float
    duration_minutes: float
    green_credits_earned: int
    carbon_offset_kg: float
    message: str

class GridMetrics(BaseModel):
    average_grid_stress: float
    peak_stress_stations: List[str]
    load_variance_smoothed_pct: float
    ai_queue_reduction_pct: float
    total_active_chargers: int
    co2_saved_today_kg: float
