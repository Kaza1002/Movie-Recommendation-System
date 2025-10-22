# build_content_model.R (v2)
suppressPackageStartupMessages({
  library(data.table); library(dplyr); library(tm); library(slam); library(stringr)
})

merged <- fread("data/merged_data_final.csv")

# Be robust to naming across your notebooks
title_col <- if ("clean_title" %in% names(merged)) "clean_title" else "title"
year_col  <- if ("movie_year"  %in% names(merged)) "movie_year"  else "year"
for (nm in c("movieId", title_col, year_col)) stopifnot(nm %in% names(merged))

# Build compact text: genres + tags_text + top_tag (genres-only still works)
merged$genres   <- ifelse(is.na(merged$genres), "", merged$genres)
merged$tags_text <- ifelse("tags_text" %in% names(merged), merged$tags_text, "")
merged$top_tag   <- ifelse("top_tag"   %in% names(merged), merged$top_tag, "")

text_vec <- tolower(paste(
  gsub("\\|"," ", merged$genres),
  merged$tags_text,
  merged$top_tag
))

# Corpus → DTM (TF → TF-IDF)
corp <- VCorpus(VectorSource(text_vec)) |>
  tm_map(removePunctuation) |>
  tm_map(removeNumbers) |>
  tm_map(stripWhitespace)
dtm_tf  <- DocumentTermMatrix(corp, control = list(wordLengths = c(2, Inf), stopwords = TRUE))
dtm     <- weightTfIdf(dtm_tf)

# Prune very sparse terms (keeps model tiny, adjust if needed)
dtm <- removeSparseTerms(dtm, 0.9995)

# Row norms for cosine
row_norms <- sqrt(slam::row_sums(dtm * dtm)); row_norms[row_norms == 0] <- 1

# Index map (be explicit about column names you persist)
idx_map <- merged |>
  mutate(row_id = dplyr::row_number()) |>
  transmute(row_id, movieId, title = .data[[title_col]], year = .data[[year_col]], genres)

# Metadata (prevents “mismatched artifact” headaches later)
meta <- list(
  created_at = as.character(Sys.time()),
  n_docs = nrow(merged),
  n_terms = ncol(dtm),
  fields_used = c("genres", "tags_text", "top_tag"),
  sparsity_threshold = 0.9995
)

dir.create("artifacts", showWarnings = FALSE)
saveRDS(list(dtm = dtm, row_norms = row_norms, idx_map = idx_map, meta = meta,
             terms = colnames(dtm)),
        "artifacts/content_dtm_model.rds")
cat("Saved artifacts/content_dtm_model.rds  | docs:", nrow(dtm), " terms:", ncol(dtm), "\n")


# build_content_model.R (compact tweak)
suppressPackageStartupMessages({
  library(data.table); library(tm); library(slam); library(stringr)
})

merged <- fread("data/merged_data_final.csv")

merged$genres    <- ifelse(is.na(merged$genres), "", gsub("\\|"," ", tolower(merged$genres)))
merged$tags_text <- ifelse("tags_text" %in% names(merged), tolower(merged$tags_text), "")
merged$top_tag   <- ifelse("top_tag"   %in% names(merged), tolower(merged$top_tag), "")
merged$title_txt <- tolower(if ("clean_title" %in% names(merged)) merged$clean_title else merged$title)

text_vec <- paste(merged$title_txt, merged$genres, merged$tags_text, merged$top_tag)

corp   <- VCorpus(VectorSource(text_vec)) |> tm_map(removePunctuation) |> tm_map(removeNumbers) |> tm_map(stripWhitespace)
dtm_tf <- DocumentTermMatrix(corp, control=list(wordLengths=c(2, Inf), stopwords=TRUE))
dtm    <- weightTfIdf(dtm_tf)

# keep a bit denser than before so tags survive
dtm <- removeSparseTerms(dtm, 0.995)

row_norms <- sqrt(slam::row_sums(dtm * dtm)); row_norms[row_norms == 0] <- 1

idx_map <- data.table(row_id=seq_len(nrow(merged)),
                      movieId=merged$movieId,
                      title=if ("clean_title" %in% names(merged)) merged$clean_title else merged$title,
                      year=if ("movie_year" %in% names(merged)) merged$movie_year else merged$year,
                      genres=merged$genres)

dir.create("artifacts", showWarnings = FALSE)
saveRDS(list(dtm=dtm, row_norms=row_norms, idx_map=idx_map), "artifacts/content_dtm_model.rds")
cat("Rebuilt content_dtm_model.rds\n")

