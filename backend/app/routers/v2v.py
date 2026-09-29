from fastapi import APIRouter
from typing import List
from backend.app.models.schemas import V2VPeer, V2VMatchRequest, V2VTransferRequest, V2VTransferResponse
from backend.app.engine.v2v_simulator import v2v_simulator

router = APIRouter(prefix="/v2v", tags=["Vehicle-to-Vehicle Energy Sharing"])

@router.post("/peers", response_model=List[V2VPeer])
def find_v2v_peers(req: V2VMatchRequest):
    """
    Locates nearby EV energy donors or receivers within the specified radius.
    """
    peers = v2v_simulator.get_nearby_peers(
        user_lat=req.lat,
        user_lon=req.lon,
        user_role=req.role
    )
    return [V2VPeer(**p) for p in peers]

@router.post("/transfer", response_model=V2VTransferResponse)
def execute_v2v_transfer(req: V2VTransferRequest):
    """
    Executes a virtual peer-to-peer energy transfer simulation between two vehicles.
    Updates battery SOC percentages, calculates charging duration, and awards green credits.
    """
    res = v2v_simulator.execute_virtual_transfer(
        donor_id=req.donor_user_id,
        receiver_id=req.receiver_user_id,
        kwh_amount=req.kwh_amount,
        donor_battery_pct=90.0,
        receiver_battery_pct=10.0,
        battery_capacity_kwh=60.0,
        transfer_power_kw=req.transfer_power_kw
    )
    return V2VTransferResponse(**res)

@router.get("/history", response_model=List[V2VTransferResponse])
def get_v2v_history():
    """
    Retrieve historical peer energy transfer logs.
    """
    return [V2VTransferResponse(**h) for h in v2v_simulator.transfer_history]
