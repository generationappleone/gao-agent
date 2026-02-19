---
name: Scikit-learn
description: Skill for machine learning with Scikit-learn — covering classification, regression, clustering, preprocessing, pipelines, model evaluation, and feature selection.
---

# Scikit-learn Skill

## Overview
**Scikit-learn** is the standard Python library for traditional ML (non-deep learning). It provides consistent APIs for preprocessing, model training, evaluation, and deployment. Use it for tabular data; for deep learning, see `skills/tensorflow/` or `skills/pytorch/`.

---

## Quick Reference

```python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# Scale
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)  # ✅ Only transform test

# Train
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train)

# Evaluate
y_pred = model.predict(X_test_scaled)
print(classification_report(y_test, y_pred))
```

---

## Preprocessing

```python
from sklearn.preprocessing import (
    StandardScaler,       # Mean=0, Std=1 (for linear models, SVM, KNN)
    MinMaxScaler,         # Scale to [0, 1] (for neural networks)
    RobustScaler,         # Uses median/IQR (robust to outliers)
    LabelEncoder,         # Categorical → integer (for tree models)
    OneHotEncoder,        # Categorical → binary columns (for linear models)
    OrdinalEncoder,       # Categorical → ordered integer
    PolynomialFeatures,   # Create interaction terms
)
from sklearn.impute import SimpleImputer, KNNImputer

# Column transformer for mixed types
from sklearn.compose import ColumnTransformer

preprocessor = ColumnTransformer([
    ('num', Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler()),
    ]), numeric_cols),
    ('cat', Pipeline([
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False)),
    ]), categorical_cols),
])
```

---

## Classification Models

```python
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier

models = {
    'LogReg': LogisticRegression(max_iter=1000, random_state=42),
    'RF': RandomForestClassifier(n_estimators=200, max_depth=10, random_state=42),
    'GBM': GradientBoostingClassifier(n_estimators=200, learning_rate=0.1, random_state=42),
    'SVM': SVC(kernel='rbf', probability=True, random_state=42),
    'KNN': KNeighborsClassifier(n_neighbors=5),
}

# Compare all models
from sklearn.model_selection import cross_val_score

for name, model in models.items():
    scores = cross_val_score(model, X_train, y_train, cv=5, scoring='roc_auc')
    print(f"{name}: AUC = {scores.mean():.4f} ± {scores.std():.4f}")
```

---

## Regression Models

```python
from sklearn.linear_model import LinearRegression, Ridge, Lasso, ElasticNet
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

model = GradientBoostingRegressor(n_estimators=200, learning_rate=0.1, max_depth=5)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

print(f"MAE:  {mean_absolute_error(y_test, y_pred):.2f}")
print(f"RMSE: {mean_squared_error(y_test, y_pred, squared=False):.2f}")
print(f"R²:   {r2_score(y_test, y_pred):.4f}")
```

---

## Clustering

```python
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
from sklearn.metrics import silhouette_score

# Find optimal K
inertias = []
silhouettes = []
for k in range(2, 11):
    km = KMeans(n_clusters=k, random_state=42, n_init=10)
    labels = km.fit_predict(X_scaled)
    inertias.append(km.inertia_)
    silhouettes.append(silhouette_score(X_scaled, labels))

# Train with best K
best_k = silhouettes.index(max(silhouettes)) + 2
kmeans = KMeans(n_clusters=best_k, random_state=42, n_init=10)
df['cluster'] = kmeans.fit_predict(X_scaled)
```

---

## Feature Selection

```python
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif, RFE

# 1. Statistical (filter method)
selector = SelectKBest(f_classif, k=20)
X_selected = selector.fit_transform(X, y)
selected_features = X.columns[selector.get_support()].tolist()

# 2. Model-based (embedded method)
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)
importances = pd.Series(model.feature_importances_, index=X.columns).sort_values(ascending=False)

# 3. Recursive Feature Elimination (wrapper method)
rfe = RFE(estimator=RandomForestClassifier(random_state=42), n_features_to_select=15)
rfe.fit(X, y)
selected = X.columns[rfe.support_].tolist()
```

---

## Model Evaluation

```python
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, roc_curve, confusion_matrix,
    classification_report,
)
from sklearn.model_selection import cross_validate

# Comprehensive evaluation
cv_results = cross_validate(
    model, X, y, cv=5,
    scoring=['accuracy', 'precision', 'recall', 'f1', 'roc_auc'],
    return_train_score=True,
)

for metric in ['accuracy', 'precision', 'recall', 'f1', 'roc_auc']:
    train_score = cv_results[f'train_{metric}'].mean()
    test_score = cv_results[f'test_{metric}'].mean()
    print(f"{metric}: Train={train_score:.4f}, Test={test_score:.4f}")
```

## Best Practices
1. **Pipeline everything** — chain preprocessing + model to avoid data leakage
2. **cross_val_score, not train/test only** — more reliable estimates
3. **stratify in splits** — for classification, maintain class balance
4. **Scale features** for linear models, SVM, KNN (not for trees)
5. **Handle imbalanced data** — SMOTE, class_weight, or threshold adjustment
6. **Feature engineering > model selection** — features matter most
