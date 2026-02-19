---
name: Predictive Analytics
description: Skill for predictive analytics — covering forecasting methods, classification, regression, time series analysis, customer analytics (churn, LTV, segmentation), and model deployment.
---

# Predictive Analytics Skill

## Overview
**Predictive analytics** uses historical data, statistical algorithms, and ML to predict future outcomes. This skill covers common business prediction use cases with practical implementations.

---

## Common Use Cases

| Domain | Prediction | Technique |
|--------|-----------|-----------|
| **Customer** | Churn prediction | Classification (RF, XGBoost) |
| **Sales** | Revenue forecasting | Time series (ARIMA, Prophet) |
| **Marketing** | Lead scoring | Classification + ranking |
| **Finance** | Fraud detection | Anomaly detection, classification |
| **Inventory** | Demand forecasting | Time series, regression |
| **HR** | Employee attrition | Classification |
| **Operations** | Equipment failure | Survival analysis |

---

## Time Series Forecasting

### Facebook Prophet
```python
from prophet import Prophet
import pandas as pd

# Prepare data (must have 'ds' and 'y' columns)
df = pd.DataFrame({
    'ds': pd.date_range('2023-01-01', periods=365, freq='D'),
    'y': daily_revenue_values,
})

# Train model
model = Prophet(
    yearly_seasonality=True,
    weekly_seasonality=True,
    daily_seasonality=False,
    changepoint_prior_scale=0.05,
)

# Add custom seasonality (e.g., Ramadan effect)
model.add_seasonality(name='monthly', period=30.5, fourier_order=5)

# Add regressors
model.add_regressor('is_holiday')
model.add_regressor('promotion_active')

model.fit(df)

# Forecast next 90 days
future = model.make_future_dataframe(periods=90)
forecast = model.predict(future)

# Results
forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail(10)
model.plot(forecast)
model.plot_components(forecast)
```

### ARIMA / SARIMA
```python
from statsmodels.tsa.statespace.sarimax import SARIMAX
from sklearn.metrics import mean_absolute_error, mean_squared_error

# SARIMA with seasonal component
model = SARIMAX(
    train_data,
    order=(1, 1, 1),          # (p, d, q)
    seasonal_order=(1, 1, 1, 12),  # (P, D, Q, m) — monthly seasonality
)
results = model.fit(disp=False)
forecast = results.forecast(steps=30)

# Evaluate
mae = mean_absolute_error(test_data, forecast)
rmse = mean_squared_error(test_data, forecast, squared=False)
mape = (abs(test_data - forecast) / test_data).mean() * 100
print(f"MAE: {mae:.2f}, RMSE: {rmse:.2f}, MAPE: {mape:.1f}%")
```

---

## Customer Churn Prediction

```python
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, roc_auc_score
import shap

# Feature engineering
features = pd.DataFrame({
    'days_since_last_login': ...,
    'login_frequency_30d': ...,
    'total_orders': ...,
    'avg_order_value': ...,
    'support_tickets_30d': ...,
    'feature_usage_score': ...,
    'contract_remaining_days': ...,
    'payment_failures': ...,
})

target = df['churned']  # 1 = churned, 0 = active

# Train
X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, stratify=target)

model = GradientBoostingClassifier(
    n_estimators=200, max_depth=5, learning_rate=0.1,
    subsample=0.8, random_state=42
)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:, 1]
print(classification_report(y_test, y_pred))
print(f"AUC-ROC: {roc_auc_score(y_test, y_proba):.4f}")

# Explainability with SHAP
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)
shap.summary_plot(shap_values, X_test)
```

---

## Customer Lifetime Value (CLV)

```python
from lifetimes import BetaGeoFitter, GammaGammaFitter

# RFM calculation
rfm = df.groupby('customer_id').agg({
    'order_date': lambda x: (max_date - x.max()).days,  # Recency
    'order_id': 'count',                                 # Frequency
    'amount': 'mean',                                    # Monetary
}).rename(columns={'order_date': 'recency', 'order_id': 'frequency', 'amount': 'monetary'})

# BG/NBD model (purchase frequency)
bgf = BetaGeoFitter(penalizer_coef=0.01)
bgf.fit(rfm['frequency'], rfm['recency'], rfm['T'])

# Predict future purchases
rfm['predicted_purchases_90d'] = bgf.predict(90, rfm['frequency'], rfm['recency'], rfm['T'])

# Gamma-Gamma model (monetary value)
ggf = GammaGammaFitter(penalizer_coef=0.01)
ggf.fit(rfm['frequency'], rfm['monetary'])

# Calculate CLV (12-month horizon)
rfm['clv_12m'] = ggf.customer_lifetime_value(
    bgf, rfm['frequency'], rfm['recency'], rfm['T'], rfm['monetary'],
    time=12, discount_rate=0.01
)
```

---

## Model Deployment Patterns

```
1. REST API (Real-time): FastAPI + model → predict per request
2. Batch Prediction: Scheduled job → predict for all users → store results
3. Embedded: Model runs in-browser (TensorFlow.js, ONNX)
4. Streaming: Kafka → Model → Output topic (near real-time)
```

## Evaluation Metrics

| Task | Metric | Good Value |
|------|--------|-----------|
| Churn | AUC-ROC | > 0.80 |
| Forecast | MAPE | < 10% |
| Lead Scoring | Precision@K | > 0.60 |
| Fraud | Recall | > 0.95 |
| CLV | MAE | Business-dependent |

## Best Practices
1. **Baseline first** — compare ML model against simple heuristics
2. **Feature > Algorithm** — invest in feature engineering
3. **Explainability** — use SHAP/LIME for stakeholder buy-in
4. **Monitor drift** — retrain when data distribution shifts
5. **Business metrics > ML metrics** — AUC doesn't pay bills; revenue impact does
