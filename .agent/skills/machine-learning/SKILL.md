---
name: Machine Learning
description: Skill for machine learning fundamentals — covering supervised/unsupervised learning, model selection, hyperparameter tuning, cross-validation, feature pipelines, and common algorithms.
---

# Machine Learning Skill

## Overview
This skill covers ML fundamentals — algorithms, training pipelines, feature processing, evaluation, and model selection. For deep learning, see `skills/tensorflow/` and `skills/pytorch/`. For business applications, see `skills/predictive-analytics/`.

---

## Algorithm Selection Guide

```
What's your target variable?

Continuous (regression)?
├── Linear relationship? → Linear Regression, Ridge, Lasso
├── Non-linear? → Random Forest, XGBoost, SVR
├── Time-based? → ARIMA, Prophet, LSTM
└── Many features? → XGBoost, LightGBM, ElasticNet

Categorical (classification)?
├── Binary? → Logistic Regression, XGBoost, Random Forest
├── Multi-class? → Random Forest, SVM, Neural Network
├── Imbalanced? → SMOTE + XGBoost, Focal Loss
└── Text? → BERT, TF-IDF + SVM/NB

No target (unsupervised)?
├── Grouping? → K-Means, DBSCAN, Hierarchical
├── Dimensionality reduction? → PCA, t-SNE, UMAP
└── Anomaly detection? → Isolation Forest, LOF, Autoencoder
```

---

## Complete ML Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score, GridSearchCV

# Define feature groups
numeric_features = ['age', 'income', 'order_count']
categorical_features = ['gender', 'region', 'membership_type']

# Preprocessing pipelines
numeric_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler()),
])

categorical_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False)),
])

# Combine preprocessors
preprocessor = ColumnTransformer([
    ('num', numeric_pipeline, numeric_features),
    ('cat', categorical_pipeline, categorical_features),
])

# Full pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(random_state=42)),
])

# Cross-validation
scores = cross_val_score(pipeline, X_train, y_train, cv=5, scoring='roc_auc')
print(f"CV AUC: {scores.mean():.4f} ± {scores.std():.4f}")

# Fit
pipeline.fit(X_train, y_train)
```

---

## Hyperparameter Tuning

```python
from sklearn.model_selection import RandomizedSearchCV
from scipy.stats import randint, uniform

# Parameter distributions
param_distributions = {
    'classifier__n_estimators': randint(100, 500),
    'classifier__max_depth': [5, 10, 15, 20, None],
    'classifier__min_samples_split': randint(2, 20),
    'classifier__min_samples_leaf': randint(1, 10),
    'classifier__max_features': ['sqrt', 'log2', None],
}

search = RandomizedSearchCV(
    pipeline,
    param_distributions,
    n_iter=50,
    cv=5,
    scoring='roc_auc',
    random_state=42,
    n_jobs=-1,
    verbose=1,
)

search.fit(X_train, y_train)

print(f"Best AUC: {search.best_score_:.4f}")
print(f"Best params: {search.best_params_}")
best_model = search.best_estimator_
```

---

## Key Algorithms Cheat Sheet

### Supervised
| Algorithm | Type | Pros | Cons |
|-----------|------|------|------|
| Linear/Logistic Regression | Both | Simple, interpretable, fast | Assumes linearity |
| Random Forest | Both | Robust, handles nonlinear, feature importance | Slow for large data |
| XGBoost/LightGBM | Both | Best for tabular data, fast | Needs tuning |
| SVM | Both | Works in high dimensions | Slow for large data |
| KNN | Both | Simple, no training | Slow prediction, curse of dimensionality |

### Unsupervised
| Algorithm | Use | Key Parameter |
|-----------|-----|---------------|
| K-Means | Clustering (spherical) | k (clusters) |
| DBSCAN | Clustering (arbitrary shape) | eps, min_samples |
| PCA | Dimensionality reduction | n_components |
| t-SNE | Visualization (2D/3D) | perplexity |
| Isolation Forest | Anomaly detection | contamination |

---

## Handling Imbalanced Data

```python
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import RandomUnderSampler
from imblearn.pipeline import Pipeline as ImbPipeline

# SMOTE + Undersampling
resampling_pipeline = ImbPipeline([
    ('preprocessor', preprocessor),
    ('smote', SMOTE(sampling_strategy=0.5, random_state=42)),
    ('undersample', RandomUnderSampler(sampling_strategy=0.8, random_state=42)),
    ('classifier', RandomForestClassifier(random_state=42)),
])

# Alternative: Class weights
model = RandomForestClassifier(class_weight='balanced', random_state=42)
```

---

## Model Persistence

```python
import joblib

# Save
joblib.dump(best_model, 'models/churn_model_v1.pkl')

# Load
model = joblib.load('models/churn_model_v1.pkl')
prediction = model.predict(new_data)
```

## Best Practices
1. **Baseline first** — always compare against simple model (majority class, mean)
2. **Cross-validate** — never report training score as performance
3. **Pipeline everything** — preprocessing + model in one pipeline (prevents data leakage)
4. **Feature importance** — understand what drives predictions
5. **XGBoost/LightGBM for tabular** — almost always best starting point
6. **Monitor data leakage** — no future data in training, no target leakage
