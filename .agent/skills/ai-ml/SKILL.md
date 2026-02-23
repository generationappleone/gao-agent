---
name: AI/ML
description: Skill for AI and Machine Learning integration in applications — covering ML pipeline architecture, model serving, MLOps, LLM integration, vector databases, RAG patterns, and responsible AI practices.
---

# AI/ML Skill

## Overview
This skill covers integrating AI and Machine Learning capabilities into applications — from ML pipeline architecture and model serving to LLM-powered features (RAG, agents) and MLOps for production systems.

---

## ML Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    ML SYSTEM ARCHITECTURE                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Data Layer        → Feature Store    → Training Pipeline    │
│  ┌────────┐         ┌───────────┐      ┌──────────────┐     │
│  │Raw Data│→ ETL → │Features   │→   →│Train Model  │     │
│  │DB/API  │         │Online/    │      │Hyperparameter│     │
│  │Streams │         │Offline    │      │Validation   │     │
│  └────────┘         └───────────┘      └──────┬───────┘     │
│                                               │              │
│  Serving Layer      ← Model Registry ←────────┘              │
│  ┌────────────┐     ┌───────────┐                            │
│  │REST API   │←────│Versioned  │                            │
│  │Batch Pred │     │Models     │                            │
│  │Streaming  │     │Artifacts  │                            │
│  └────────────┘     └───────────┘                            │
│                                                              │
│  Monitoring Layer                                            │
│  ┌────────────────────────────────────┐                      │
│  │Data Drift │ Model Perf │ Latency  │                      │
│  └────────────────────────────────────┘                      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Model Serving Patterns

### REST API Serving
```python
from fastapi import FastAPI
import joblib
import numpy as np

app = FastAPI()
model = joblib.load('models/churn_model_v2.pkl')
scaler = joblib.load('models/scaler_v2.pkl')

class PredictionRequest(BaseModel):
    features: dict[str, float]

class PredictionResponse(BaseModel):
    prediction: int
    probability: float
    model_version: str

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    feature_array = np.array([list(request.features.values())])
    scaled = scaler.transform(feature_array)
    prediction = model.predict(scaled)[0]
    probability = model.predict_proba(scaled)[0].max()
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=float(probability),
        model_version="v2.1.0"
    )
```

### Batch Prediction
```python
def batch_predict(input_path: str, output_path: str):
    df = pd.read_parquet(input_path)
    features = preprocess(df)
    predictions = model.predict(features)
    probabilities = model.predict_proba(features)[:, 1]
    
    df['prediction'] = predictions
    df['probability'] = probabilities
    df['predicted_at'] = datetime.utcnow()
    df['model_version'] = 'v2.1.0'
    
    df.to_parquet(output_path, index=False)
```

---

## LLM Integration Patterns

### RAG (Retrieval-Augmented Generation)
```python
# Vector database + LLM for context-aware answers
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA

# 1. Index documents
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(documents, embeddings, persist_directory="./chroma_db")

# 2. Query with context
retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)

qa_chain = RetrievalQA.from_chain_type(
    llm=llm, chain_type="stuff", retriever=retriever,
    return_source_documents=True
)

result = qa_chain({"query": "How do I request a refund?"})
```

### Structured Output
```python
from pydantic import BaseModel
from openai import OpenAI

class SentimentResult(BaseModel):
    sentiment: str  # positive, negative, neutral
    confidence: float
    keywords: list[str]
    summary: str

client = OpenAI()
completion = client.beta.chat.completions.parse(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": f"Analyze sentiment: {text}"}],
    response_format=SentimentResult,
)
result: SentimentResult = completion.choices[0].message.parsed
```

---

## MLOps Lifecycle

```
1. Data Versioning    → DVC, Delta Lake
2. Experiment Tracking→ MLflow, W&B
3. Model Registry     → MLflow Model Registry
4. CI/CD for ML       → GitHub Actions + model validation
5. Model Serving      → FastAPI, TFServing, Triton
6. Monitoring         → Evidently, WhyLabs
7. Retraining         → Scheduled or trigger-based
```

---

## Responsible AI

```
□ Bias detection — test model across demographics
□ Explainability — SHAP/LIME for feature importance
□ Fairness metrics — Equal opportunity, demographic parity
□ Data privacy — PII handling per UU PDP
□ Human oversight — human-in-the-loop for high-stakes decisions
□ Model cards — document model purpose, limitations, biases
□ Audit trail — log all predictions for review
```

## Skills Integration
- **Data Scientist**: ML workflow → `skills/data-scientist/`
- **TensorFlow/PyTorch**: DL frameworks → `skills/tensorflow/`, `skills/pytorch/`
- **Gemini/OpenAI API**: LLM providers → `skills/gemini-api/`, `skills/openai-api/`
- **Predictive Analytics**: Business predictions → `skills/predictive-analytics/`
