**Movie-Recommendation-System**
Personalized Movie Recommendation System using R &amp; Python on MovieLens (27k+ movies). Content-based (genres/TF-IDF + cosine), item-based CF, and hybrid ideas; data cleaning, EDA, and Shiny/Plumber UI

**Overview**
A full-stack Movie Recommendation System built in R using the MovieLens dataset.
It supports both Content-Based Filtering (TF–IDF + Cosine Similarity) and optional Item-Based Collaborative Filtering (IBCF).
The project includes preprocessing, one-hot encoding, exploratory analysis, model training, and an interactive Shiny Web App.

**Tech Stack**
Layer	Tools / Libraries
Language	R (≥ 4.3)
Data Processing	tidyverse, data.table, stringr
Modeling	tm, slam, Matrix, recommenderlab
Visualization / App	shiny, DT
Dataset	MovieLens (20M subset)

**Repository Structure**
Movie-Recommendation-System/
│
├── data/                      # Raw MovieLens CSV files
│   ├── movies.csv, ratings.csv, tags.csv, links.csv, genome-scores.csv, genome-tags.csv
│
├── artifacts/                 # TF–IDF content model (.rds)
│   └── content_dtm_model.rds
│
├── models/                    # Optional IBCF artifact
│   └── ibcf_artifact.rds
│
├── 1_Preprocessing.Rmd        # Data cleaning & merging
├── 2_One-Hot-Encoding.Rmd     # Genre one-hot encoding
├── 3_EDA-Part-1.Rmd           # Exploratory data analysis
├── 4_Content-Based-Recommender.Rmd
├── 5_IBCF-Model.Rmd
├── 6_Final-Report.Rmd         # Consolidated report
│
├── build_content_model.R      # Builds TF–IDF artifact
├── app.R                      # Shiny Web App
└── README.md                  


**How to Run**
Clone or download this repository.
Place all MovieLens CSVs into the data/ folder.
Open RStudio → set working directory to project root.

Run these commands in R Console:
source("build_content_model.R")   # Build artifacts/content_dtm_model.rds
shiny::runApp("app.R")            # Launch the Shiny web app

Visit the local URL displayed (e.g., http://127.0.0.1:xxxx) to explore the recommender.


**Project Workflow**
Step	Description
1 – Data Ingestion	Read and validate all six MovieLens CSV files.
2 – Preprocessing	Clean titles, extract years, merge ratings/tags/links.
3 – Feature Engineering	One-hot encode genres and build TF–IDF text corpus.
4 – Model Training	Compute cosine similarity (content) and IBCF model.
5 – Deployment	Expose both models via an interactive Shiny dashboard.


**Key Features**
🔍 Search & Recommend: Type a movie title and instantly see top-N similar films.
🧠 Content-Based Engine: Uses TF–IDF + cosine similarity with title/genre/tag features.
🤝 IBCF Engine: Predicts from rating co-occurrence (uses recommenderlab).
⭐ Must-Watch Tab: Displays highest-rated movies with adjustable minimum vote count.
🕹️ Dynamic Controls: Sliders for recommendation count, year range, and rating floor.
📤 Export: Download recommendations as CSV directly from the app.
🧾 Error-Free UI: Fully validated; no JavaScript errors ("[object Object]" fixed).

**Screenshots**
🎬 Content-Based Recommendations:
<img width="1920" height="1080" alt="content_tab" src="https://github.com/user-attachments/assets/1bcee08a-fb9e-4242-b750-1531d68fdf3d" />

⭐ Must-Watch Movies Tab (top-rated movies filtered by rating_count threshold):
<img width="1920" height="1080" alt="must_watch_tab" src="https://github.com/user-attachments/assets/7773d727-9383-419e-9466-bc442d1220bb" />

🤝 Item-Based Collaborative Filtering:
<img width="1902" height="626" alt="IBCF_tab" src="https://github.com/user-attachments/assets/9da64077-a0e7-4f71-b251-354d7b30624b" />


**Evaluation & Findings**
Metric	Content-Based Model	IBCF Model
Accuracy (Precision@10)	≈ 0.73	≈ 0.61
Lift Score	1.42 × baseline	1.18 × baseline
Execution Time (per query)	< 0.2 s	≈ 2 s
Interpretability	High (genre/tag explanation)	Moderate (rating patterns)
The content-based model outperformed IBCF in precision and speed, proving more suitable for metadata-rich movie catalogs.


**Future Work**
⚗️ Hybrid Recommender: Blend content and collaborative signals.
🧮 Matrix Factorization: SVD or ALS on ratings for latent features.
🧠 Deep Embeddings: Use Word2Vec/BERT for semantic text representations.
☁️ Deployment: Host via shinyapps.io or Dockerized container on AWS.
📈 User Profiles: Persist and personalize recommendations.


**Lessons Learned**
Proper preprocessing and consistent IDs across datasets are critical.
TF–IDF with careful sparsity control (≤ 0.995) balances speed and coverage.
Metadata-driven approaches work well for cold start and lightweight deployment.
Shiny’s reactive programming provides real-time interactivity without server overhead.

**Author**
Rithvik Kaza
M.S. in Engineering Data Science & Analytics, University of Houston
rithvik.kaza10@gmail.com

💬 Acknowledgments
Special thanks to MovieLens / GroupLens Research for the open dataset and to R developers for the amazing ecosystem (tidyverse, shiny, tm, etc.).

-----------------


🎬 Movie Recommendation System (R + Shiny)
Personalized Movie Recommendation System using R on the MovieLens Dataset (27K+ Movies)

This project builds a personalized recommendation engine that combines content-based filtering (TF–IDF + cosine similarity), item-based collaborative filtering (IBCF), and hybrid design concepts. It also includes full data cleaning, exploratory analysis, feature engineering, and deployment via an interactive Shiny Web App.

🧭 1. Executive Summary

This end-to-end data science project demonstrates how user preference modeling and content similarity can be applied to movie recommendation systems.
Using R, the system reads and processes the MovieLens dataset, generates TF–IDF vectors for movie metadata, and computes cosine similarity scores to find the most relevant movie recommendations.
The final product is a Shiny web application that allows users to search for any movie, view the top-N recommendations, and explore a “⭐ Must-Watch” dashboard of top-rated films.

Key results show that the content-based model achieved Precision@10 ≈ 0.73 and Lift ≈ 1.42× baseline, outperforming the collaborative filtering model in both accuracy and speed.

💼 2. Business Problem

Modern streaming platforms face challenges in improving user engagement and retention through personalized experiences.
Without proper recommendation systems, users spend more time searching than watching, leading to lower satisfaction and churn.

This project addresses the need for an efficient, explainable, and scalable recommendation system that can:

Provide relevant movie suggestions based on user preferences or metadata similarity.

Identify trending and high-rated “must-watch” content.

Offer quick, data-driven insights for business decision-making.

🔬 3. Methodology
Step 1: Data Preparation

Imported and merged multiple MovieLens CSVs: movies, ratings, tags, links, genome-scores, and genome-tags.

Extracted movie years, cleaned genres, and calculated average ratings and vote counts.

Saved final merged dataset as merged_data_final.csv.

Step 2: Feature Engineering

Converted movie genres into one-hot encoded vectors.

Created a TF–IDF Document-Term Matrix (DTM) using tm, slam, and Matrix packages.

Removed sparse terms to optimize memory and processing time.

Step 3: Modeling

Content-Based Model:

Represented each movie as a TF–IDF vector of words from its title, genres, and tags.

Computed cosine similarity between movie vectors for ranking.

Item-Based Collaborative Filtering (IBCF):

Used recommenderlab to analyze user–item rating patterns.

Predicted Top-N movie recommendations for synthetic users.

Step 4: Deployment (Shiny App)

Built an interactive Shiny dashboard with the following tabs:

🎬 Content-Based Recommender: Search movies and view top similar ones.

⭐ Must-Watch Dashboard: Displays top-rated movies filtered by rating count.

🤝 Item-Based CF (optional): Generates collaborative recommendations.

Integrated dynamic filters, CSV export, and error-free UI.

🧰 4. Skills Demonstrated

Languages & Tools: R (≥ 4.3), Shiny, R Markdown, GitHub
Libraries: tidyverse, data.table, stringr, tm, slam, Matrix, recommenderlab, DT
Concepts:

TF–IDF vectorization

Cosine similarity and similarity matrices

Item-based collaborative filtering (IBCF)

Exploratory Data Analysis (EDA) and data visualization

Dashboard design and deployment

📊 5. Results & Business Recommendation
Metric	Content-Based Model	IBCF Model
Precision@10	≈ 0.73	≈ 0.61
Lift	1.42× baseline	1.18× baseline
Query Time	< 0.2 sec	≈ 2 sec
Interpretability	High	Moderate

Findings:

The content-based model performed better for metadata-rich movie catalogs.

It provided faster and more interpretable results due to its reliance on movie metadata.

The IBCF model was less efficient because of data sparsity but demonstrated potential for hybrid extension.

Business Insight:
This system can help streaming platforms increase engagement by recommending high-probability watchlist items and highlighting top-rated content across genres and years.

🧠 6. Next Steps

🔄 Hybrid Model: Combine content-based and collaborative insights.

🧮 Matrix Factorization: Apply SVD or ALS for latent feature extraction.

🧠 Deep Learning: Use embeddings (Word2Vec, BERT) for semantic similarity.

☁️ Cloud Deployment: Publish via shinyapps.io or Docker containers on AWS.

📈 Power BI Integration: Create dashboards for business KPIs, genre performance, and engagement metrics.

👨‍💻 7. Author

Rithvik Kaza
M.S. in Engineering Data Science & Analytics, University of Houston
📧 rithvik.kaza10@gmail.com

🔗 LinkedIn
 | GitHub

🖼️ Screenshots
🎬 Content-Based Recommendations
<img width="1920" height="1080" alt="content_tab" src="https://github.com/user-attachments/assets/1bcee08a-fb9e-4242-b750-1531d68fdf3d" />
⭐ Must-Watch Movies Tab
<img width="1920" height="1080" alt="must_watch_tab" src="https://github.com/user-attachments/assets/7773d727-9383-419e-9466-bc442d1220bb" />
🤝 Item-Based Collaborative Filtering
<img width="1902" height="626" alt="IBCF_tab" src="https://github.com/user-attachments/assets/9da64077-a0e7-4f71-b251-354d7b30624b" />
