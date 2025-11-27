library(MASS)
library(gimme)
if (dir.exists("sim_data")) unlink("sim_data", recursive = TRUE)
if (dir.exists("sim_results")) unlink("sim_results", recursive = TRUE)

dir.create("sim_data", showWarnings = FALSE)
dir.create("sim_results", showWarnings = FALSE)


# 1. Helper functions

## 1.1 Generate $\Psi_i$

generate_Psi_i <- function(A_i,
                           min_k = 1,
                           max_k = 4,
                           base_var = 1.5,
                           low_cov = 0.03,
                           high_cov = 0.15) {
  
  p <- nrow(A_i)
  Psi <- diag(base_var, p, p)
  
  # candidate off-diagonal positions where A_i has zero and use only i < j to
  # enforce symmetry
  candidates <- which(A_i == 0,
                      arr.ind = TRUE)
  candidates <- candidates[candidates[,1] < candidates[,2], , drop = FALSE]
  if (nrow(candidates) == 0) return(Psi)
  
  k <- sample(min_k:max_k, 1)
  k <- min(k, nrow(candidates))
  chosen_idx <- sample(1:nrow(candidates), k, replace = FALSE)
  chosen <- candidates[chosen_idx, , drop = FALSE]
  
  # assign random covariances at those positions
  for (m in 1:nrow(chosen)) {
    i <- chosen[m, 1]
    j <- chosen[m, 2]
    val <- runif(1, low_cov, high_cov)
    Psi[i, j] <- val
    Psi[j, i] <- val
  }
  
  # ensure positive definite 
  ev <- eigen(Psi, symmetric = TRUE)$values
  if (min(ev) <= 0) {
    jitter <- (abs(min(ev)) + 1e-3)
    Psi <- Psi + jitter * diag(p)
  }
  
  return(Psi)
  
}

## 1.2 Simulate $\eta_i$
      
simulate_subject_total <- function(T_total, A, Phi, Psi) {
      
  p <- nrow(A)
  # TOTAL <- T_obs+ burn_in
  X <- matrix(NA,
              nrow = T_total,
              ncol = p)
  colnames(X) <- paste0("X", 1:p)
  
  # initial state eta_1 ~ N(0, I)
  X[1, ] <- runif(p, min = 0, max = 0.5)
  
  # (I - A)^(-1)
  M <- solve(diag(p) - A)
  
  for (t in 2:T_total) {
    # Sigma_safe <- Psi + 1e-4 * diag(p)
    zeta_t <- mvrnorm(1,
                      mu = rep(0, p),
                      Sigma = Psi) # zeta is the white noise
    X[t, ] <- M %*% (Phi %*% X[t - 1, ] + zeta_t)
  }
  
  X
  
}

## 1.3 Random K generator

random_k <- function(min_k, max_k) {
  
  if (max_k <= 0) return(0L)
  sample(min_k:max_k, size = 1)
  
}

## 1.4 Random individual edges generator

generate_random_individual_edges <- function(M_common,
                                             min_k = 0,
                                             max_k = 4,
                                             low = 0.03,
                                             high = 0.15,
                                             allow_diag = FALSE){
  
  p <- nrow(M_common)
  M <- M_common
  
  # choose how many individual edges this subject gets
  k_indiv <- random_k(min_k, max_k)
  if (k_indiv == 0) return(M)
  
  # find eligible positions; cannot overwrite group edges
  possible <- which(M_common == 0,
                    arr.ind = TRUE)
  
  # optionally remove diagonal
  if (!allow_diag) {
    possible <- possible[possible[,1] != possible[,2], , drop = FALSE]
  }
  if (nrow(possible) == 0) return(M)
  # safety: cannot choose more edges than exist
  k_indiv <- min(k_indiv,
                 nrow(possible))
  
  # randomly select k edges
  idx <- sample(seq_len(nrow(possible)),
                size = k_indiv,
                replace = FALSE)
  chosen <- possible[idx, , drop = FALSE]
  
  # fill with random values
  for (j in seq_len(nrow(chosen))) {
    to <- chosen[j, 1]
    from <- chosen[j, 2]
    M[to, from] <- runif(1,low,high)
  }
  
  # ensure no diagonals for A
  if (!allow_diag) diag(M) <- diag(M_common)
  
  M
  
}

## 1.5 Matrix comparison function

compare_mats <- function(M_true, M_est, tol = 1e-8) {
  
  # treat any nonzero entry as an edge
  true_edge <- abs(M_true) > tol
  est_edge <- abs(M_est) > tol
  
  TP <- sum(true_edge & est_edge)
  FP <- sum(!true_edge & est_edge)
  FN <- sum(true_edge & !est_edge)
  TN <- sum(!true_edge & !est_edge)
  
  data.frame(
    TP = TP,
    FP = FP,
    FN = FN,
    TN = TN,
    sensitivity = ifelse((TP + FN) == 0, NA, TP / (TP + FN)),
    specificity = ifelse((TN + FP) == 0, NA, TN / (TN + FP)),
    precision = ifelse((TP + FP) == 0, NA, TP / (TP + FP))
  )
  
}


# 2. One simulation loop

run_one_sim <- function(T_obs,
                        N = 100,
                        p = 8,
                        group_cutoff = 0.65,
                        seed = NULL,
                        burn_in = 100){
  
  # if (is.null(burn_in)) burn_in <- 0
  if (!is.null(seed)) set.seed(seed)
  
  T_total <- T_obs + burn_in
  
  # define group-level A_common
  A_common <- matrix(0, p, p)
  for (j in 1:(p - 1)) {
    A_common[j + 1, j] <- runif(1, 0.2, 0.35)
  }
  diag(A_common) <- 0
  
  # define group-level Phi_common
  Phi_common <- matrix(0, p, p)
  diag(Phi_common) <- runif(p,
                            min = 0.1,
                            max = 0.2)
  
  # first off-diagonal band
  for (j in 1:(p - 1)) {
    Phi_common[j + 1, j] <- runif(1, 0.2, 0.3)
  }
  
  # second off-diagonal band
  for (j in 1:(p - 2)) {
    Phi_common[j + 2, j] <- runif(1, 0.1, 0.2)
  }
  
  # a few extra random group edges
  extra_edges <- 3
  for (k in 1:extra_edges) {
    r <- sample(1:p, 1)
    c <- sample(setdiff(1:p, r), 1)
    Phi_common[r, c] <- runif(1, 0.03, 0.08)
  }
  
  # simulate N subjects
  A_list <- vector("list", N)
  Phi_list <- vector("list", N)
  Psi_list <- vector("list", N)
  X_list <- vector("list", N)
  
  for (s in 1:N) {
    
    # A_i: contemporaneous, no diag, few individual edges
    A_i <- generate_random_individual_edges(
      M_common = A_common,
      min_k = 0,
      max_k = 2,
      low = 0.03,
      high = 0.12,
      allow_diag = FALSE
    )
    
    # enforce: no bidirectional contemporaneous edges
    for (i in 1:p) {
      for (j in 1:p) {
        if (i < j && A_i[i, j] != 0 && A_i[j, i] != 0) {
          A_i[j, i] <- 0
        }
      }
    }
    
    # Phi_i: lagged, diag allowed, more individual edges
    Phi_i <- generate_random_individual_edges(
      M_common = Phi_common,
      min_k = 2,
      max_k = 5,
      low = 0.05,
      high = 0.15,
      allow_diag = TRUE
    )
    
    # Psi_i: structured noise, off-diagonal only where A_i == 0
    Psi_i <- generate_Psi_i(
      A_i,
      min_k = 1,
      max_k = 4,
      base_var = 1,
      low_cov = 0.01,
      high_cov = 0.05
    )
    
    A_list[[s]] <- A_i
    Phi_list[[s]] <- Phi_i
    Psi_list[[s]] <- Psi_i
    
    X_full <- simulate_subject_total(
      T_total = T_total,
      A = A_i,
      Phi = Phi_i,
      Psi = Psi_i
    )
    
    X_list[[s]] <- X_full[(T_total - T_obs + 1):T_total, , drop = FALSE]
    
  }
  
  # write sim_data for this run
  for (s in seq_len(N)) {
    
    fname <- file.path("sim_data",
                       paste0("sub", s, ".txt"))
    write.table(
      X_list[[s]],
      file = fname,
      row.names = FALSE,
      col.names = TRUE,
      sep = " "
    )
    
  }
  
  # run GIMME
  fit <- gimme(
    data = "sim_data",
    out = "sim_results",
    sep = "",
    header = TRUE,
    ar = TRUE,
    plot = FALSE,
    subgroup = FALSE,
    paths = NULL,
    groupcutoff = group_cutoff,
    subcutoff   = .50,
    standardize = TRUE
  )
  
  # extract group-level estimated A and Phi
  PCM <- as.matrix(read.csv(
    "sim_results/summaryPathCountsMatrix.csv",
    check.names = FALSE
  ))
  
  p_mat <- nrow(PCM)
  lag_cols <- grep("lag", colnames(PCM))
  Phi_counts <- PCM[, lag_cols, drop = FALSE]
  A_counts <- PCM[, -lag_cols, drop = FALSE]
  N_subj <- max(PCM)
  
  Phi_est <- (Phi_counts >= group_cutoff * N_subj)
  A_est <- (A_counts >= group_cutoff * N_subj)
  Phi_est <- +Phi_est
  A_est <- +A_est
  
  rownames(A_est) <- rownames(PCM)
  colnames(A_est) <- gsub("lag", "", colnames(A_counts))
  rownames(Phi_est) <- rownames(PCM)
  colnames(Phi_est) <- gsub("lag", "", colnames(Phi_counts))
  diag(A_est) <- 0
  
  # compare true vs estimated (A and Phi)
  resA <- compare_mats(A_common, A_est)
  resPhi <- compare_mats(Phi_common, Phi_est)
  
  # add FPR, matrix label, T, and rep placeholders
  resA$FPR <- with(resA, FP / (FP + TN))
  resPhi$FPR <- with(resPhi, FP / (FP + TN))
  
  resA$matrix <- "A"
  resPhi$matrix <- "Phi"
  
  resA$T_obs <- T_obs
  resPhi$T_obs <- T_obs
  
  rbind(resA, resPhi)
  
}