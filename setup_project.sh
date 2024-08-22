#!/bin/bash

# Create the directory structure
mkdir -p my_project/{data,models,scripts,api,core,tests}

# Install necessary Python packages
pip install sqlalchemy spacy fastapi uvicorn pydantic

# Download the spaCy language model
python -m spacy download en_core_web_sm

# Populate the `core/text_analyzer.py`
cat > my_project/core/text_analyzer.py <<EOL
import spacy

class TextAnalyzer:
    def __init__(self):
        self.nlp = spacy.load('en_core_web_sm')

    def extract_insights(self, text):
        doc = self.nlp(text)
        insights = [sent.text for sent in doc.sents if len(sent) > 10]
        return insights

    def categorize_insight(self, insight):
        if "AI" in insight:
            return "AI"
        elif "technology" in insight:
            return "Technology"
        else:
            return "General"

    def rank_insight(self, insight):
        return len(insight) / 100.0
EOL

# Populate the `core/database_manager.py`
cat > my_project/core/database_manager.py <<EOL
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, desc
from core.models import Base, Insight, Category, Source

class DatabaseManager:
    def __init__(self, db_url='sqlite:///data/database.db'):
        self.engine = create_engine(db_url)
        Base.metadata.create_all(self.engine)
        self.Session = sessionmaker(bind=self.engine)

    def store_insight(self, insight):
        session = self.Session()
        session.add(insight)
        session.commit()

    def retrieve_insights(self, filters=None):
        session = self.Session()
        query = session.query(Insight)
        if filters:
            if 'category' in filters:
                query = query.filter(Insight.category == filters['category'])
            if 'top' in filters:
                query = query.order_by(desc(Insight.ranking_score)).limit(filters['top'])
        return query.all()

    def update_insight(self, insight_id, data):
        session = self.Session()
        insight = session.query(Insight).get(insight_id)
        for key, value in data.items():
            setattr(insight, key, value)
        session.commit()
EOL

# Populate the `api/main.py`
cat > my_project/api/main.py <<EOL
from fastapi import FastAPI
from api.routes import router

app = FastAPI()

app.include_router(router)
EOL

# Populate the `api/routes.py`
cat > my_project/api/routes.py <<EOL
from fastapi import APIRouter
from api.schemas import InsightCreate
from core.database_manager import DatabaseManager
from core.models import Insight

router = APIRouter()
db_manager = DatabaseManager()

@router.post("/insights/")
def add_insight(insight: InsightCreate):
    new_insight = Insight(
        text=insight.text,
        category=insight.category,
        ranking_score=insight.ranking_score,
        source=insight.source
    )
    db_manager.store_insight(new_insight)
    return {"message": "Insight added successfully"}

@router.get("/insights/")
def get_insights(category: str = None, top: int = None):
    filters = {}
    if category:
        filters['category'] = category
    if top:
        filters['top'] = top
    insights = db_manager.retrieve_insights(filters)
    return insights

@router.put("/insights/{insight_id}")
def update_insight(insight_id: int, insight: InsightCreate):
    db_manager.update_insight(insight_id, insight.dict())
    return {"message": "Insight updated successfully"}
EOL

# Populate the `api/schemas.py`
cat > my_project/api/schemas.py <<EOL
from pydantic import BaseModel
from typing import Optional

class InsightCreate(BaseModel):
    text: str
    category: Optional[str] = None
    ranking_score: Optional[float] = None
    source: Optional[str] = None
EOL

# Populate the `core/models.py`
cat > my_project/core/models.py <<EOL
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Insight(Base):
    __tablename__ = 'insights'
    id = Column(Integer, primary_key=True)
    text = Column(String, nullable=False)
    category = Column(String, nullable=False)
    ranking_score = Column(Float, nullable=False)
    timestamp = Column(DateTime, nullable=False)
    source_id = Column(Integer, ForeignKey('sources.id'))

class Category(Base):
    __tablename__ = 'categories'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(String)

class Source(Base):
    __tablename__ = 'sources'
    id = Column(Integer, primary_key=True)
    source_name = Column(String, nullable=False)
    metadata = Column(String)
    insights = relationship('Insight', backref='source')
EOL

# Populate the `tests/test_text_analyzer.py`
cat > my_project/tests/test_text_analyzer.py <<EOL
import unittest
from core.text_analyzer import TextAnalyzer

class TestTextAnalyzer(unittest.TestCase):
    def setUp(self):
        self.analyzer = TextAnalyzer()

    def test_extract_insights(self):
        text = "This is a test text for insight extraction. AI is transforming the world."
        insights = self.analyzer.extract_insights(text)
        self.assertIsInstance(insights, list)
        self.assertGreater(len(insights), 0)

    def test_categorize_insight(self):
        insight = "AI is transforming the world."
        category = self.analyzer.categorize_insight(insight)
        self.assertEqual(category, 'AI')

    def test_rank_insight(self):
        insight = "AI is transforming the world."
        ranking_score = self.analyzer.rank_insight(insight)
        self.assertIsInstance(ranking_score, float)
        self.assertGreater(ranking_score, 0.0)

if __name__ == '__main__':
    unittest.main()
EOL

# Populate the `tests/test_database_manager.py`
cat > my_project/tests/test_database_manager.py <<EOL
import unittest
from core.database_manager import DatabaseManager
from core.models import Insight

class TestDatabaseManager(unittest.TestCase):
    def setUp(self):
        self.db_manager = DatabaseManager(db_url='sqlite:///:memory:')

    def test_store_insight(self):
        insight = Insight(text="Test insight", category="Test", ranking_score=0.5)
        self.db_manager.store_insight(insight)
        retrieved_insights = self.db_manager.retrieve_insights()
        self.assertEqual(len(retrieved_insights), 1)

    def test_retrieve_insights(self):
        insight = Insight(text="Test insight", category="Test", ranking_score=0.5)
        self.db_manager.store_insight(insight)
        filters = {'category': 'Test'}
        insights = self.db_manager.retrieve_insights(filters)
        self.assertEqual(len(insights), 1)

    def test_update_insight(self):
        insight = Insight(text="Test insight", category="Test", ranking_score=0.5)
        self.db_manager.store_insight(insight)
        updated_data = {"text": "Updated insight", "ranking_score": 0.8}
        self.db_manager.update_insight(insight.id, updated_data)
        updated_insight = self.db_manager.retrieve_insights()[0]
        self.assertEqual(updated_insight.text, "Updated insight")
        self.assertEqual(updated_insight.ranking_score, 0.8)

if __name__ == '__main__':
    unittest.main()
EOL

# Populate the `tests/test_api.py`
cat > my_project/tests/test_api.py <<EOL
from fastapi.testclient import TestClient
import unittest
from api.main import app

client = TestClient(app)

class TestAPI(unittest.TestCase):

    def test_add_insight(self):
        response = client.post("/insights/", json={"text": "New insight", "category": "General"})
        self.assertEqual(response.status_code, 200)
        self.assertIn("Insight added successfully", response.json()['message'])

    def test_get_insights(self):
        response = client.get("/insights/")
        self.assertEqual(response.status_code, 200)
        self.assertIsInstance(response.json(), list)

    def test_update_insight(self):
        # Assuming an insight with ID 1 exists
        response = client.put("/insights/1", json={"text": "Updated insight", "ranking_score": 0.8})
        self.assertEqual(response.status_code, 200)
        self.assertIn("Insight updated successfully", response.json()['message'])

if __name__ == '__main__':
    unittest.main()
EOL

# Documentation update in README.md
cat > my_project/README.md <<EOL
# Project Setup Instructions

## API Documentation

### Endpoints

#### POST /insights/
Add a new insight to the database.
- **Body**: JSON object with `text`, `category`, `ranking_score`, and `source`.

#### GET /insights/
Retrieve insights, optionally filtering by category or retrieving top-ranked insights.
- **Query Parameters**:
  - `category`: Filter by the category of the insight.
  - `top`: Retrieve the top N insights based on their ranking score.

#### PUT /insights/{insight_id}
Update an existing insight in the database.
- **Path Parameter**: `insight_id` - ID of the insight to update.
- **Body**: JSON object with updated `text`, `category`, `ranking_score`, and/or `source`.

## Example Usage

1. **Add an Insight**:
   ```bash
   curl -X POST "http://localhost:8000/insights/" -H "Content-Type: application/json" -d '{"text": "AI is the future", "category": "AI", "ranking_score": 0.9}'
