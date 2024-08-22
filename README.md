# PowerfulGPT

Realtime curation of profound nuggets of GPT wisdom

## Project Overview

This project is designed to capture, categorize, and store profound and insightful excerpts from AI interactions. The system includes:
- **Text Analysis**: Extracts and categorizes insights from text inputs.
- **Database Management**: Stores insights and provides methods for retrieval and updating.
- **API**: A FastAPI-based interface for interacting with the insights.

## Features

- Extract meaningful insights from text using NLP.
- Categorize insights based on keywords.
- Rank insights based on predefined criteria.
- API endpoints for adding, retrieving, and updating insights.

## Installation

### 1. Pre-installation

Before running the project, make sure to install the system-level dependencies by executing the `pre-install.sh` script.

```bash
bash pre-install.sh

2. Set Up Python Environment

It is recommended to create a virtual environment for the project to avoid conflicts with other Python packages.

# Create a virtual environment
virtualenv venv

# Activate the virtual environment
source venv/bin/activate

3. Install Python Packages

Install the required Python packages using pip and the requirements.txt file.

pip install -r requirements.txt

4. Project Setup

Run the setup_project.sh script to set up the project directory structure, install additional dependencies, and populate the code files.

bash setup_project.sh

Usage

Running the FastAPI Server

After the setup is complete, you can start the FastAPI server to interact with the API.

uvicorn api.main:app --reload

The server will be accessible at http://localhost:8000.

API Documentation

The API provides endpoints to add, retrieve, and update insights.

POST /insights/

Add a new insight to the database.

	•	Body: JSON object with text, category, ranking_score, and source.

Example:

curl -X POST "http://localhost:8000/insights/" -H "Content-Type: application/json" -d '{"text": "AI is the future", "category": "AI", "ranking_score": 0.9}'

GET /insights/

Retrieve insights, optionally filtering by category or retrieving top-ranked insights.

	•	Query Parameters:
	•	category: Filter by the category of the insight.
	•	top: Retrieve the top N insights based on their ranking score.

Example:

curl -X GET "http://localhost:8000/insights/?category=AI&top=5"

PUT /insights/{insight_id}

Update an existing insight in the database.

	•	Path Parameter: insight_id - ID of the insight to update.
	•	Body: JSON object with updated text, category, ranking_score, and/or source.

Example:

curl -X PUT "http://localhost:8000/insights/1" -H "Content-Type: application/json" -d '{"text": "AI will change the world", "ranking_score": 0.95}'

Running Tests

Unit tests are included to verify the functionality of the TextAnalyzer, DatabaseManager, and API routes.

To run the tests, execute the following command:

python -m unittest discover -s tests

Contributing

If you would like to contribute to the project, please fork the repository and submit a pull request. Contributions are welcome!

License

This project is licensed under the MIT License.

### Summary

- **`pre-install.sh`**: Installs system-level dependencies.
- **`requirements.txt`**: Lists Python packages required for the project.
- **`README.md`**: Provides comprehensive documentation for setting up, using, and contributing to the project.

You can create these files in your local environment and follow the steps outlined to set up the project. Let me know if you need any further assistance!
