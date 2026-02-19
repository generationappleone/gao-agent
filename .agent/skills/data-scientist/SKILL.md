---
name: Data Scientist
description: Skill for data science workflows — covering exploratory data analysis, statistical methods, feature engineering, model training, evaluation metrics, experiment tracking, and deployment patterns.
---

# Data Scientist Skill

## Overview
A **Data Scientist** extracts insights from data using statistics, machine learning, and domain expertise. This skill covers the end-to-end data science workflow from problem definition to model deployment.

---

## Data Science Workflow

```
1. Problem Definition → Define business question, success metrics
2. Data Collection    → Gather data from databases, APIs, files
3. EDA               → Explore distributions, correlations, outliers
4. Feature Engineering→ Create, select, transform features
5. Model Training     → Train, tune hyperparameters
6. Evaluation         → Metrics, validation, bias checks
7. Deployment         → API serving, batch prediction
8. Monitoring         → Drift detection, performance tracking
```

---

## Exploratory Data Analysis (EDA)

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def eda_report(df: pd.DataFrame) -> dict:
    """Generate comprehensive EDA summary"""
    report = {
        'shape': df.shape,
        'dtypes': df.dtypes.value_counts().to_dict(),
        'missing': df.isnull().sum().to_dict(),
        'missing_pct': (df.isnull().sum() / len(df) * 100).round(2).to_dict(),
        'duplicates': df.duplicated().sum(),
        'numeric_stats': df.describe().to_dict(),
        'categorical_unique': {col: df[col].nunique() for col in df.select_dtypes(include='object').columns},
    }
    return report

# Correlation heatmap
def plot_correlation(df: pd.DataFrame):
    numeric_cols = df.select_dtypes(include='number')
    plt.figure(figsize=(12, 8))
    sns.heatmap(numeric_cols.corr(), annot=True, cmap='coolwarm', center=0)
    plt.title('Correlation Matrix')
    plt.tight_layout()
    plt.savefig('correlation_matrix.png', dpi=150)

# Distribution plots
def plot_distributions(df: pd.DataFrame, columns: list[str]):
    fig, axes = plt.subplots(len(columns), 2, figsize=(14, 4 * len(columns)))
    for i, col in enumerate(columns):
        sns.histplot(df[col], ax=axes[i][0], kde=True)
        sns.boxplot(x=df[col], ax=axes[i][1])
        axes[i][0].set_title(f'{col} - Distribution')
        axes[i][1].set_title(f'{col} - Box Plot')
    plt.tight_layout()
    plt.savefig('distributions.png', dpi=150)
```

---

## Feature Engineering

```python
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
from sklearn.feature_selection import SelectKBest, f_classif

class FeatureEngineer:
    def create_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df.copy()
        
        # Time-based features
        df['hour'] = df['timestamp'].dt.hour
        df['day_of_week'] = df['timestamp'].dt.dayofweek
        df['is_weekend'] = df['day_of_week'] >= 5
        df['month'] = df['timestamp'].dt.month
        df['quarter'] = df['timestamp'].dt.quarter
        
        # Aggregation-based features
        df['customer_total_orders'] = df.groupby('customer_id')['order_id'].transform('count')
        df['customer_avg_spend'] = df.groupby('customer_id')['amount'].transform('mean')
        
        # Interaction features
        df['price_per_unit'] = df['total_price'] / df['quantity'].clip(lower=1)
        
        # Binning
        df['age_group'] = pd.cut(df['age'], bins=[0, 18, 25, 35, 50, 65, 100],
                                  labels=['<18', '18-25', '26-35', '36-50', '51-65', '65+'])
        
        # Log transform (for skewed distributions)
        df['log_income'] = np.log1p(df['income'])
        
        return df

    def select_features(self, X: pd.DataFrame, y: pd.Series, k: int = 20) -> list[str]:
        selector = SelectKBest(f_classif, k=k)
        selector.fit(X, y)
        return X.columns[selector.get_support()].tolist()
```

---

## Model Training Pipeline

```python
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

def train_model(X: pd.DataFrame, y: pd.Series):
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    # Define models to compare
    models = {
        'RandomForest': RandomForestClassifier(n_estimators=100, random_state=42),
        'GradientBoosting': GradientBoostingClassifier(n_estimators=100, random_state=42),
    }
    
    results = {}
    for name, model in models.items():
        # Cross-validation
        cv_scores = cross_val_score(model, X_train, y_train, cv=5, scoring='roc_auc')
        
        # Train
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        y_proba = model.predict_proba(X_test)[:, 1]
        
        results[name] = {
            'cv_mean': cv_scores.mean(),
            'cv_std': cv_scores.std(),
            'test_auc': roc_auc_score(y_test, y_proba),
            'report': classification_report(y_test, y_pred, output_dict=True),
            'model': model,
        }
        print(f"{name}: CV AUC = {cv_scores.mean():.4f} ± {cv_scores.std():.4f}, Test AUC = {results[name]['test_auc']:.4f}")
    
    return results
```

---

## Experiment Tracking (MLflow)

```python
import mlflow
import mlflow.sklearn

mlflow.set_experiment("customer_churn_prediction")

with mlflow.start_run(run_name="random_forest_v1"):
    mlflow.log_params({"n_estimators": 100, "max_depth": 10, "min_samples_split": 5})
    mlflow.log_metrics({"auc": 0.87, "accuracy": 0.82, "f1": 0.79})
    mlflow.sklearn.log_model(model, "model")
    mlflow.log_artifact("feature_importance.png")
```

---

## Evaluation Metrics

| Task | Metrics | When |
|------|---------|------|
| Classification | Accuracy, Precision, Recall, F1, AUC-ROC | Balanced/imbalanced classes |
| Regression | MAE, MSE, RMSE, R², MAPE | Continuous target |
| Clustering | Silhouette, Davies-Bouldin, Inertia | Unsupervised grouping |
| Ranking | NDCG, MAP, MRR | Recommendation, search |

## Best Practices
1. **Understand the business problem first** — ML is not always the answer
2. **Start simple** — baseline model before complex architectures
3. **Feature engineering > model selection** — features matter most
4. **Cross-validate** — never evaluate on training data
5. **Track experiments** — use MLflow, W&B, or similar
6. **Version data and models** — DVC, MLflow Model Registry
7. **Monitor in production** — data drift, model degradation
8. **Document assumptions** — what data, what biases, what limitations
