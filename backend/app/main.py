import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.config import settings
from backend.app.routers import stations, prediction, recommendation, reservations, v2v, analytics

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="End-to-End AI-powered EV charging network optimization platform."
)

# Enable CORS for Flutter mobile app, web preview, and local debugging
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount all API routers
app.include_router(stations.router)
app.include_router(prediction.router)
app.include_router(recommendation.router)
app.include_router(reservations.router)
app.include_router(v2v.router)
app.include_router(analytics.router)

@app.get("/")
def root():
    return {
        "platform": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "online",
        "docs_url": "/docs",
        "endpoints": {
            "stations": "/stations",
            "predict_wait": "/predict_wait",
            "recommend": "/recommend",
            "reserve": "/reserve",
            "reservations": "/reservations",
            "v2v_peers": "/v2v/peers",
            "v2v_transfer": "/v2v/transfer",
            "grid_overview": "/analytics/grid/overview",
            "simulation_benchmark": "/analytics/simulation/benchmark",
            "ml_metrics": "/analytics/model/metrics"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app.main:app", host="0.0.0.0", port=8000, reload=True)
