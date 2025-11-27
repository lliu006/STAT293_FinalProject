# STAT 293 Final Project - GIMME Simulation Study
## Fall 2025
## Instructor: Dr. Jose Angel Sanchez Gomez

**Authors:** Yijia Xue and Linlin Liu <br>
**Date:** December 4, 2025

**Primary Reference:** Gates, K. M., & Molenaar, P. C. M. (2012). *Group search algorithm recovers effective connectivity maps for individuals in homogeneous and heterogeneous samples.* NeuroImage, 63, 310-319.

## Overview

This repository contains the full reproducible workflow for our STAT 293 Final Project, where we evaluate the Group Iterative Multiple Model Estimation (GIMME) algorithm using fully simulated multivariate time-series data generated under a unified Structural Equation Model (uSEM).

Our project examines how reliably GIMME recovers:

- group-level contemporaneous paths (A),
- group-level lagged paths ($\Phi$), and
- individual-specific deviations

across a range of time-series lengths (T = 50, 150, 300) and 20 replications per condition.

## Objectives:

1. Design a generative uSEM simulation framework with structured noise, realistic heterogeneity, and directed dependencies.
2. Simulate 100 subjects with random variations in both A (contemporaneous) and $\Phi$ (lagged) networks.
3. Apply GIMME to all 60 simulated datasets.
4. Evaluate estimation performance using TP, FP, FN, TN, sensitivity, specificity, FPR, and FNR.
5. Visualize both quantitative recovery metrics and qualitative network comparisons for A and $\Phi$.

*Disclaimer:* This project does not analyze real fMRI data. All results are based on simulated networks.

## Repository Structure

This is the actual foldr and file layout used in this project:

```text
├── README.md                   # Project description and workflow
│
├── 01_DataSimulation.R         # All helper functions (A, Phi, Psi generation; uSEM simulation)
├── 01_DataSimulation.Rmd       # Narrative explanation of the simulation design
│
├── 02_Method.Rmd               # Runs all simulations and 60 GIMME replications
├── 03_Analysis.Rmd             # Loads results and creates final summary tables and plots
│
├── sim_data/                   # Auto-generated simulated time series (100 .txt files per run)
├── sim_results/                # Auto-generated GIMME output (path counts, plots, model files)
├── results/                    # Combined metrics and saved figures
│   ├── all_results.csv
│   ├── TPR_vs_T_A_Phi.png
│   ├── TPR_A_errorbars.png
│   ├── TPR_vs_T_A_Phi_analysis.png
│   └── TPR_A_errorbars_analysis.png
│
└── STAT293_FinalProject.Rproj  # RStudio project file
```

## Simulation Summary

We simulate N = 100 subjects, each with: 

- p = 8 observed variables
- Burn-in = 100, then keep the final T = 50, 150, or 300 observations
- Subject-specific A and $\Phi$ matrices:
    - A (contemporaneous): sparse, no diagonals, no bidirectional pairs
    - $\Phi$ (lagged): denser, autoregressive diagonals and 1st and 2nd bands
- Structured noise $\Psi$: random off-diagonal noise covariance
- Heterogeneity:
  - 0 - 2 extra individual edges in A
  - 2 - 5 extra individual edges in $\Phi$
  - random added edges with small weights 
 
The generative model:

$$
\eta_t = (I - A_i)^{-1} ( \Phi_i \eta_{t-1} + \xi_t), \qquad \xi_t \sim N(0, \Psi_i).
$$

This produces realistic subject-level variability similar to the original GIMME publication.

## Running the Project

### Setup Environment

```r
source("00_requirements.R")
```

This will:
- check R version,
- install, if needed, and load required packages, and
- create the directory structure `data/`, `data/simulated/`, `data/results/`, and `presentation/`.
  
### Simulate Data

```r
source("01_DataSimulation.R")
```

This will:
- define the true group-level connectivity matrices (A, $\Phi$),
- generate individual-level matrices with heterogeneity,
- simulate multivariate time series for all subjects, and
- save simulated datasets under `data/simulated/`.

### Run GIMME

```r
source("11_Method1.R")
```

This will:
- load the simulated data,
- run the GIMME algorithm on all subjects,
- write GIMME output and summaries under `data/results/`, and
- may call helper functions defined in `12_Method1_aux.R`.

### Expected Outcomes

Based on the simulation design, we expect:
  - strong recovery of the main contemporaneous chain $X_1 \to X_2 \to X_3 \to X_4 \to X_5$,
  - high detection of lagged autoregressive paths,
  - recovery of lagged edges from $X_1 (t−1) \to X_2 (t)$ and $X_1 (t−1) \to X_3 (t)$, 
  - identification of many individual-specific edges, and
  - good overall model fit (low RMSEA, high CFI) for most subjects.

Exact recovery rates vary slightly across runs but generally align with the behavior described in Gates & Molenaar (2012).

## Citations

If referencing this work:

```bibtex
@article{gates2012group,
  title={Group search algorithm recovers effective connectivity maps for individuals in homogeneous and heterogeneous samples},
  author={Gates, Kathleen M and Molenaar, Peter CM},
  journal={NeuroImage},
  volume={63},
  number={1},
  pages={310--319},
  year={2012}
}
```

## Acknowledgements

- Dr. Jose Angel Sanchez Gomez for course instruction
- Gates and Molenaar for foundational work
- The developers of the `gimme` R package

Last Updated: November 2025
