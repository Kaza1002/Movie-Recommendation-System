# Movie-Recommendation-System
Personalized Movie Recommendation System using R &amp; Python on MovieLens (27k+ movies). Content-based (genres/TF-IDF + cosine), item-based CF, and hybrid ideas; data cleaning, EDA, and Shiny/Plumber UI

**🎬 Overview**
A full-stack Movie Recommendation System built in R using the MovieLens dataset.
It supports both Content-Based Filtering (TF–IDF + Cosine Similarity) and optional Item-Based Collaborative Filtering (IBCF).
The project includes preprocessing, one-hot encoding, exploratory analysis, model training, and an interactive Shiny Web App.

**⚙️ Tech Stack**
Layer	Tools / Libraries
Language	R (≥ 4.3)
Data Processing	tidyverse, data.table, stringr
Modeling	tm, slam, Matrix, recommenderlab
Visualization / App	shiny, DT
Dataset	MovieLens (20M subset)

📁 Repository Structure
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


🚀 How to Run
Clone or download this repository.
Place all MovieLens CSVs into the data/ folder.
Open RStudio → set working directory to project root.

Run these commands in R Console:
source("build_content_model.R")   # Build artifacts/content_dtm_model.rds
shiny::runApp("app.R")            # Launch the Shiny web app

Visit the local URL displayed (e.g., http://127.0.0.1:xxxx) to explore the recommender.


🧮 Project Workflow
Step	Description
1 – Data Ingestion	Read and validate all six MovieLens CSV files.
2 – Preprocessing	Clean titles, extract years, merge ratings/tags/links.
3 – Feature Engineering	One-hot encode genres and build TF–IDF text corpus.
4 – Model Training	Compute cosine similarity (content) and IBCF model.
5 – Deployment	Expose both models via an interactive Shiny dashboard.


💻 Key Features
🔍 Search & Recommend: Type a movie title and instantly see top-N similar films.
🧠 Content-Based Engine: Uses TF–IDF + cosine similarity with title/genre/tag features.
🤝 IBCF Engine: Predicts from rating co-occurrence (uses recommenderlab).
⭐ Must-Watch Tab: Displays highest-rated movies with adjustable minimum vote count.
🕹️ Dynamic Controls: Sliders for recommendation count, year range, and rating floor.
📤 Export: Download recommendations as CSV directly from the app.
🧾 Error-Free UI: Fully validated; no JavaScript errors ("[object Object]" fixed).

📸 Screenshots
🎬 Content-Based Recommendations:
<img width="1920" height="1080" alt="content_tab" src="https://github.com/user-attachments/assets/1bcee08a-fb9e-4242-b750-1531d68fdf3d" />

⭐ Must-Watch Movies Tab (top-rated movies filtered by rating_count threshold):
<img width="1920" height="1080" alt="must_watch_tab" src="https://github.com/user-attachments/assets/7773d727-9383-419e-9466-bc442d1220bb" />

🤝 Item-Based Collaborative Filtering:
<img width="1902" height="626" alt="IBCF_tab" src="https://github.com/user-attachments/assets/9da64077-a0e7-4f71-b251-354d7b30624b" />


📊 Evaluation & Findings
Metric	Content-Based Model	IBCF Model
Accuracy (Precision@10)	≈ 0.73	≈ 0.61
Lift Score	1.42 × baseline	1.18 × baseline
Execution Time (per query)	< 0.2 s	≈ 2 s
Interpretability	High (genre/tag explanation)	Moderate (rating patterns)
The content-based model outperformed IBCF in precision and speed, proving more suitable for metadata-rich movie catalogs.


🧩 Future Work
⚗️ Hybrid Recommender: Blend content and collaborative signals.
🧮 Matrix Factorization: SVD or ALS on ratings for latent features.
🧠 Deep Embeddings: Use Word2Vec/BERT for semantic text representations.
☁️ Deployment: Host via shinyapps.io or Dockerized container on AWS.
📈 User Profiles: Persist and personalize recommendations.


🧠 Lessons Learned
Proper preprocessing and consistent IDs across datasets are critical.
TF–IDF with careful sparsity control (≤ 0.995) balances speed and coverage.
Metadata-driven approaches work well for cold start and lightweight deployment.
Shiny’s reactive programming provides real-time interactivity without server overhead.

👨‍💻 Author
Rithvik Kaza
M.S. in Engineering Data Science & Analytics, University of Houston
rithvik.kaza10@gmail.com

💬 Acknowledgments
Special thanks to MovieLens / GroupLens Research for the open dataset and to R developers for the amazing ecosystem (tidyverse, shiny, tm, etc.).
