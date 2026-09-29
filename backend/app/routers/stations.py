from fastapi import APIRouter, Query
from typing import List, Optional
from backend.app.models.schemas import Station, StationListResponse
from backend.app.engine.recommender import recommender

router = APIRouter(prefix="", tags=["Stations"])

@router.get("/stations", response_model=StationListResponse)
def get_stations(
    lat: Optional[float] = Query(default=None, description="User latitude"),
    lon: Optional[float] = Query(default=None, description="User longitude"),
    radius: Optional[float] = Query(default=25.0, description="Radius in km")
):
    """
    List nearby EV charging stations with availability status, queue length, and grid load.
    """
    raw_stations = recommender.get_stations(lat=lat, lon=lon, radius_km=radius)
    stations_obj = [Station(**s) for s in raw_stations]
    return StationListResponse(total=len(stations_obj), stations=stations_obj)

@router.get("/stations/{station_id}", response_model=Station)
def get_station_by_id(station_id: int):
    """
    Get detailed telemetry for a specific charging station.
    """
    stations = recommender.stations
    for s in stations:
        if s["id"] == station_id:
            return Station(**s)
    # Default to first station if not found
    return Station(**stations[0])
