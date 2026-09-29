from fastapi import APIRouter
from backend.app.models.schemas import RecommendRequest, RecommendResponse, Station, StationScoreBreakdown
from backend.app.engine.recommender import recommender

router = APIRouter(prefix="", tags=["Recommendation"])

@router.post("/recommend", response_model=RecommendResponse)
def recommend_station(req: RecommendRequest):
    """
    Recommends the best EV charging station considering user battery level,
    distance, predicted wait, local grid stress, and priority (Ambulance / Emergency leapfrog).
    """
    result = recommender.recommend(
        user_lat=req.lat,
        user_lon=req.lon,
        battery_pct=req.battery_pct,
        vehicle_type=req.vehicle_type,
        membership=req.membership,
        max_radius_km=req.max_radius_km or 20.0
    )
    
    return RecommendResponse(
        recommended_station=Station(**result["recommended_station"]),
        score_breakdown=StationScoreBreakdown(**result["score_breakdown"]),
        alternative_stations=[Station(**s) for s in result["alternative_stations"]],
        priority_level=result["priority_level"],
        ai_rationale=result["ai_rationale"]
    )
