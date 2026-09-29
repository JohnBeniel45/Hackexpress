import os

class Settings:
    PROJECT_NAME: str = "GridFlow AI - Smart EV Charging Network"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Model configuration
    MODEL_PATH: str = os.path.join(os.path.dirname(__file__), "ml", "wait_model.pkl")
    METRICS_PATH: str = os.path.join(os.path.dirname(__file__), "ml", "model_metrics.json")
    
    # Grid limits
    GRID_STRESS_THRESHOLD: float = 0.80  # Above this, fast-charging is penalized
    EMERGENCY_BATTERY_THRESHOLD: float = 10.0  # Under 10% triggers leapfrog urgent priority
    
    # Default city coords (Bengaluru EV Corridor)
    DEFAULT_LAT: float = 12.9716
    DEFAULT_LON: float = 77.5946

settings = Settings()
