from fastapi import APIRouter
from backend.app.models.schemas import PredictWaitRequest, PredictWaitResponse
from backend.app.ml.wait_predictor import wait_predictor

router = APIRouter(prefix="", tags=["ML Prediction"])

@router.post("/predict_wait", response_model=PredictWaitResponse)
def predict_wait_time(req: PredictWaitRequest):
    """
    Predicts station queue delay in minutes using the trained XGBoost model.
    """
    res = wait_predictor.predict(
        station_id=req.station_id,
        queue_len=req.queue_length,
        chargers_total=req.chargers_total,
        time_of_day=req.time_of_day,
        day_of_week=req.day_of_week,
        grid_load=req.grid_load or 0.5,
        weather_temp_c=req.weather_temp_c or 28.0,
        is_raining=req.is_raining or False
    )
    return PredictWaitResponse(
        station_id=req.station_id,
        predicted_wait_min=res["predicted_wait_min"],
        predicted_wait=res["predicted_wait_min"],
        confidence_interval=res["confidence_interval"],
        model_used=res["model_used"],
        features_used=res["features_used"]
    )
