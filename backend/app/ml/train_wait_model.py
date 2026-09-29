import os
import json
import pickle
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from xgboost import XGBRegressor

from backend.app.data.synthetic_generator import generate_synthetic_dataset

def build_features(df: pd.DataFrame):
    """Derives cyclical time features and interaction terms."""
    df_feat = df.copy()
    # Queue ratio: vehicles waiting per available charger plug
    df_feat["queue_ratio"] = df_feat["queue_len"] / np.maximum(1, df_feat["chargers_total"])
    
    # Cyclical hour representation
    df_feat["sin_hour"] = np.sin(2 * np.pi * df_feat["hour"] / 24.0)
    df_feat["cos_hour"] = np.cos(2 * np.pi * df_feat["hour"] / 24.0)
    
    # Grid load stress interaction
    df_feat["grid_stress_flag"] = (df_feat["grid_load"] > 0.8).astype(int)
    
    feature_cols = [
        "queue_len",
        "chargers_total",
        "queue_ratio",
        "power_kw",
        "hour",
        "sin_hour",
        "cos_hour",
        "day_of_week",
        "is_weekend",
        "grid_load",
        "grid_stress_flag",
        "weather_temp_c",
        "is_raining"
    ]
    return df_feat[feature_cols], df_feat["wait_time_minutes"], feature_cols

def train_and_evaluate():
    data_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    csv_path = os.path.join(data_dir, "charging_logs.csv")
    
    if not os.path.exists(csv_path):
        print("Charging logs CSV not found. Generating synthetic logs...")
        df = generate_synthetic_dataset(n_samples=7000, output_path=csv_path)
    else:
        df = pd.read_csv(csv_path)
        
    X, y, feature_cols = build_features(df)
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    print(f"Training set: {X_train.shape[0]} rows, Test set: {X_test.shape[0]} rows")
    
    # 1. Baseline: Linear Regression
    lr = LinearRegression()
    lr.fit(X_train, y_train)
    lr_pred = lr.predict(X_test)
    lr_mae = mean_absolute_error(y_test, lr_pred)
    lr_r2 = r2_score(y_test, lr_pred)
    
    # 2. Baseline: Random Forest
    rf = RandomForestRegressor(n_estimators=100, max_depth=6, random_state=42)
    rf.fit(X_train, y_train)
    rf_pred = rf.predict(X_test)
    rf_mae = mean_absolute_error(y_test, rf_pred)
    rf_r2 = r2_score(y_test, rf_pred)
    
    # 3. Champion Model: XGBoost Regressor
    xgb = XGBRegressor(
        n_estimators=180,
        max_depth=5,
        learning_rate=0.08,
        subsample=0.85,
        colsample_bytree=0.85,
        random_state=42,
        tree_method="hist"
    )
    xgb.fit(X_train, y_train)
    xgb_pred = xgb.predict(X_test)
    
    xgb_mae = mean_absolute_error(y_test, xgb_pred)
    xgb_rmse = np.sqrt(mean_squared_error(y_test, xgb_pred))
    xgb_r2 = r2_score(y_test, xgb_pred)
    
    print("\n--- MODEL PERFORMANCE COMPARISON ---")
    print(f"Linear Regression: MAE = {lr_mae:.2f} min, R² = {lr_r2:.4f}")
    print(f"Random Forest:     MAE = {rf_mae:.2f} min, R² = {rf_r2:.4f}")
    print(f"XGBoost Regressor: MAE = {xgb_mae:.2f} min, RMSE = {xgb_rmse:.2f} min, R² = {xgb_r2:.4f}")
    
    # Feature Importance
    importance_dict = dict(zip(feature_cols, [float(x) for x in xgb.feature_importances_]))
    sorted_importance = dict(sorted(importance_dict.items(), key=lambda item: item[1], reverse=True))
    print("\nXGBoost Top Feature Importances:")
    for k, v in list(sorted_importance.items())[:5]:
        print(f"  {k:20s}: {v*100:.1f}%")
        
    # Save Model
    model_path = os.path.join(os.path.dirname(__file__), "wait_model.pkl")
    with open(model_path, "wb") as f:
        pickle.dump({
            "model": xgb,
            "feature_cols": feature_cols,
            "metrics": {
                "algorithm": "XGBoost Regressor",
                "mae_minutes": round(float(xgb_mae), 2),
                "rmse_minutes": round(float(xgb_rmse), 2),
                "r2_score": round(float(xgb_r2), 4),
                "baseline_lr_mae": round(float(lr_mae), 2),
                "baseline_rf_mae": round(float(rf_mae), 2)
            }
        }, f)
    print(f"\nModel saved successfully to {model_path}")
    
    # Save JSON summary for API and UI dashboards
    metrics_path = os.path.join(os.path.dirname(__file__), "model_metrics.json")
    with open(metrics_path, "w") as f:
        json.dump({
            "algorithm": "XGBoost Regressor",
            "mae_minutes": round(float(xgb_mae), 2),
            "rmse_minutes": round(float(xgb_rmse), 2),
            "r2_score": round(float(xgb_r2), 4),
            "feature_importances": sorted_importance,
            "comparisons": {
                "Linear Regression": {"mae": round(float(lr_mae), 2), "r2": round(float(lr_r2), 4)},
                "Random Forest": {"mae": round(float(rf_mae), 2), "r2": round(float(rf_r2), 4)},
                "XGBoost": {"mae": round(float(xgb_mae), 2), "r2": round(float(xgb_r2), 4)}
            }
        }, f, indent=2)
    print(f"Metrics saved to {metrics_path}")

if __name__ == "__main__":
    train_and_evaluate()
