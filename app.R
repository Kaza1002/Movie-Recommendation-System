# app.R — Movie Recommender (Content-based + optional IBCF)

suppressPackageStartupMessages({
  library(shiny); library(DT)
  library(dplyr); library(stringr); library(tibble)
  library(data.table); library(tm); library(slam)
  library(Matrix)
})

# ---------- locate artifacts (works with relative or your absolute Windows path) ----------
find_first <- function(paths) paths[which(file.exists(paths))[1]]

content_artifact <- find_first(c(
  "artifacts/content_dtm_model.rds",
  "C:/Users/Lenovo/Documents/Movie Recommendation/artifacts/content_dtm_model.rds"
))
stopifnot(!is.na(content_artifact))

ibcf_artifact <- find_first(c(
  "models/ibcf_artifact.rds",
  "C:/Users/Lenovo/Documents/Movie Recommendation/models/ibcf_artifact.rds"
))

links_csv <- find_first(c(
  "data/links.csv",
  "C:/Users/Lenovo/Documents/Movie Recommendation/data/links.csv"
))

merged_csv <- find_first(c(
  "data/merged_data_final.csv",
  "C:/Users/Lenovo/Documents/Movie Recommendation/data/merged_data_final.csv"
))

# ---------- load content-based model (DTM + row norms + idx_map) ----------
art <- readRDS(content_artifact)
dtm <- art$dtm
row_norms <- art$row_norms
idx_map <- art$idx_map

# Ensure required columns exist in idx_map
stopifnot(all(c("row_id","movieId","title","year") %in% names(idx_map)))

# Optionally enrich idx_map with ratings aggregates for Must-Watch tab
if (!is.na(merged_csv)) {
  merged <- fread(merged_csv, select = c("movieId","avg_rating","rating_count"), showProgress = FALSE)
  if (all(c("movieId","avg_rating","rating_count") %in% names(merged))) {
    idx_map <- idx_map %>%
      left_join(merged %>% distinct(movieId, avg_rating, rating_count), by = "movieId")
  }
}

# optional external links (safe guards added)
links <- if (!is.na(links_csv)) fread(links_csv) else NULL
if (!is.null(links)) {
  idx_map <- idx_map %>% left_join(links %>% select(movieId, imdbId, tmdbId), by = "movieId")
}
if (!"imdbId" %in% names(idx_map)) idx_map$imdbId <- NA_integer_
if (!"tmdbId" %in% names(idx_map)) idx_map$tmdbId <- NA_character_

# ---------- try to load IBCF (optional) ----------
ibcf_art <- if (!is.na(ibcf_artifact)) readRDS(ibcf_artifact) else NULL

# ---------- cosine helper (supports tm::simple_triplet_matrix and Matrix::dgCMatrix) ----------
cosine_row <- function(r_idx){
  if (inherits(dtm, "simple_triplet_matrix")) {
    sims <- as.numeric(slam::tcrossprod_simple_triplet_matrix(dtm[r_idx, ], dtm))
  } else if (inherits(dtm, "dgCMatrix")) {
    sims <- as.numeric(dtm %*% Matrix::t(dtm[r_idx, ]))
  } else {
    stop("Unsupported DTM class: ", class(dtm)[1])
  }
  sims[r_idx] <- 0
  denom <- (row_norms[r_idx] * row_norms) + 1e-12
  sims / denom
}

# ---------- SAFE content-based recommender ----------
get_recs_cb <- function(seed_row_id, k = 10){
  if (is.null(seed_row_id) || is.na(seed_row_id)) return(tibble(note = "Pick a movie"))
  if (length(row_norms) != nrow(dtm)) return(tibble(note = "Artifact mismatch (norms vs DTM)."))
  
  r <- as.integer(seed_row_id)
  
  s <- tryCatch({
    if (inherits(dtm, "simple_triplet_matrix")) {
      sims <- as.numeric(slam::tcrossprod_simple_triplet_matrix(dtm[r, ], dtm))
    } else if (inherits(dtm, "dgCMatrix")) {
      sims <- as.numeric(dtm %*% Matrix::t(dtm[r, ]))
    } else stop("Unsupported DTM class: ", class(dtm)[1])
    sims[r] <- 0
    sims / ((row_norms[r] * row_norms) + 1e-12)
  }, error = function(e) {
    rep(NA_real_, nrow(idx_map))
  })
  
  if (all(!is.finite(s))) return(tibble(note = "Could not compute similarities."))
  
  ord <- head(order(s, decreasing = TRUE), min(k, length(s)))
  out <- tibble(
    row_id = ord,
    similarity = round(s[ord], 3)
  ) %>%
    left_join(idx_map, by = "row_id") %>%
    arrange(desc(similarity)) %>%
    transmute(
      title = as.character(title),
      year  = as.integer(year),
      genres = as.character(genres),
      similarity
    )
  
  as.data.frame(out, stringsAsFactors = FALSE)
}

# ---------- IBCF ----------
get_recs_ibcf <- function(titles_csv, n = 5){
  req(!is.null(ibcf_art))
  model <- ibcf_art$model
  item_labels <- ibcf_art$item_labels  # character vector of movieIds the model knows
  
  liked_titles <- str_split(titles_csv, ",")[[1]] %>% str_squish()
  liked_lc <- tolower(liked_titles)
  idx_lc   <- tolower(idx_map$title)
  
  liked_ids <- idx_map$movieId[idx_lc %in% liked_lc] %>% as.character()
  if (!length(liked_ids)) return(tibble(note="No typed titles matched the dataset."))
  
  vec <- rep(NA_real_, length(item_labels)); names(vec) <- item_labels
  ids_in_model <- intersect(liked_ids, item_labels)
  if (!length(ids_in_model)) return(tibble(note="Your liked titles are not in the CF model. Try others."))
  vec[ids_in_model] <- 5
  mat <- Matrix(vec, nrow = 1, sparse = TRUE)
  rownames(mat) <- "synthetic_user"
  new_user <- new("realRatingMatrix", data = drop0(mat))
  
  preds <- predict(model, new_user, type = "topNList", n = n)
  items <- as(preds, "list")[[1]]
  if (is.null(items) || !length(items)) return(tibble(note="No CF recs. Try different titles."))
  
  tibble(movieId = as.numeric(items)) %>%
    left_join(idx_map %>% select(movieId, title, year, genres), by = "movieId") %>%
    select(title, year, genres)
}

# ---------- UI ----------
ui <- fluidPage(
  titlePanel("🎬 Movie Recommender"),
  tabsetPanel(
    tabPanel(
      "Content-based",
      sidebarLayout(
        sidebarPanel(
          selectizeInput("seed", "Pick a movie (type to search):",
                         choices = NULL,
                         options = list(placeholder = "Start typing…")),
          sliderInput("k", "How many recommendations?", 5, 30, 10, step = 1),
          helpText("Fast TF–IDF on genres/tags. Similarity computed on the fly.")
        ),
        mainPanel(
          h3("Recommendations"),
          DT::DTOutput("tbl_cb")
        )
      )
    ),
    if (!is.null(ibcf_art)) tabPanel(
      "Item-based CF",
      sidebarLayout(
        sidebarPanel(
          textInput("liked", "Enter titles you like (comma-separated):",
                    "Toy Story, The Matrix"),
          sliderInput("k_cf", "How many recommendations?", 3, 20, 5),
          helpText("Builds a synthetic user from your typed titles; predicts with IBCF.")
        ),
        mainPanel(
          h3("Recommendations"),
          DT::DTOutput("tbl_cf")
        )
      )
    ),
    tabPanel(
      "⭐ Must-Watch",
      sidebarLayout(
        sidebarPanel(
          uiOutput("mw_controls")  # dynamic sliders (max from data)
        ),
        mainPanel(
          h3("Top-Rated (with vote floor)"),
          DT::DTOutput("tbl_must")
        )
      )
    )
  )
)

# ---------- server ----------
server <- function(input, output, session){
  
  # Use row_id as values; title as labels (avoids duplicates)
  default_sel <- {
    i <- which(tolower(idx_map$title) == "toy story")[1]
    if (length(i) == 1 && !is.na(i)) idx_map$row_id[i] else idx_map$row_id[1]
  }
  
  updateSelectizeInput(
    session, "seed",
    choices = setNames(idx_map$row_id, idx_map$title),
    server = TRUE,
    selected = default_sel
  )
  
  # Content-based table (validated to avoid JS "[object Object]" error)
  output$tbl_cb <- DT::renderDT({
    req(input$seed)
    res <- get_recs_cb(input$seed, input$k)
    if ("note" %in% names(res)) {
      validate(need(FALSE, res$note[1]))
    }
    res
  }, options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
  
  # Optional IBCF
  if (!is.null(ibcf_art)) {
    output$tbl_cf <- DT::renderDT({
      req(input$liked)
      get_recs_ibcf(input$liked, input$k_cf)
    }, options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
  }
  
  # --- Dynamic sliders for Must-Watch (max = true dataset max) ---
  output$mw_controls <- renderUI({
    rc <- if ("rating_count" %in% names(idx_map)) idx_map$rating_count else numeric()
    rc <- rc[is.finite(rc)]
    max_votes <- if (length(rc)) max(rc, na.rm = TRUE) else 500
    max_votes <- if (is.finite(max_votes) && max_votes > 0) max_votes else 500
    
    tagList(
      sliderInput("min_votes", "Minimum rating_count:",
                  min = 5,
                  max = max_votes,
                  value = min(50, max_votes),
                  step = max(1, round(max_votes/100))),
      sliderInput("top_n", "How many to show?",
                  min = 5, max = 50, value = 10, step = 1),
      helpText("Shows highest-rated movies with at least N ratings.")
    )
  })
  
  output$tbl_must <- DT::renderDT({
    if (!all(c("avg_rating","rating_count") %in% names(idx_map)))
      return(tibble(note="avg_rating / rating_count not available in artifact/merged CSV."))
    req(input$min_votes, input$top_n)
    idx_map %>%
      filter(!is.na(avg_rating), !is.na(rating_count), rating_count >= input$min_votes) %>%
      arrange(desc(avg_rating), desc(rating_count)) %>%
      transmute(title, year, avg_rating = round(avg_rating, 2), rating_count, genres) %>%
      slice_head(n = input$top_n)
  }, options = list(pageLength = 10, dom = "tip"), rownames = FALSE)
}

shinyApp(ui, server)
