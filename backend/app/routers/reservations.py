from fastapi import APIRouter
from typing import List, Optional
from backend.app.models.schemas import ReservationRequest, ReservationResponse
from backend.app.engine.priority_scheduler import scheduler
from backend.app.engine.recommender import recommender

router = APIRouter(prefix="", tags=["Reservations"])

@router.post("/reserve", response_model=ReservationResponse)
def reserve_slot(req: ReservationRequest):
    """
    Book a charging slot with priority hierarchy and overbooking protection.
    Emergency vehicles & battery <= 10% receive URGENT_LEAPFROG preemption.
    """
    # Lookup station name
    station_name = f"Station #{req.station_id}"
    for s in recommender.stations:
        if s["id"] == req.station_id:
            station_name = s["name"]
            break
            
    res = scheduler.create_reservation(
        user_id=req.user_id,
        station_id=req.station_id,
        station_name=station_name,
        slot_time=req.slot_time,
        vehicle_type=req.vehicle_type,
        battery_pct=req.battery_pct,
        membership=req.membership,
        duration_minutes=req.duration_minutes
    )
    return ReservationResponse(**res)

@router.get("/reservations", response_model=List[ReservationResponse])
def get_reservations(user_id: Optional[str] = None):
    """
    List active reservations or filter by user.
    """
    items = scheduler.get_user_reservations(user_id)
    return [ReservationResponse(**item) for item in items]
