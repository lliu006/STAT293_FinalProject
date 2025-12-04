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
├── README.md                                 # Project description and workflow
│
├── 01_DataSimulation.R                       # All helper functions, singl-run simullation, and GIMME wrapper
├── 11_Method.Rmd                             # Runs all simulations and writes combine results
├── 21_Example_and_Analysis.Rmd               # Loads results and creates final summary tables and plots
├── 31_Full_Code.Rmd                          # GIMME code in its entirety
│
├── sim_data/                                 # Auto-generated simulated time series (100 .txt files per run)
├── sim_results/                              # Auto-generated GIMME output (path counts, plots, model files)
├── results/                                  # Combined metrics and saved figures
│   ├── all_results.csv
│   ├── TPR_vs_T_A_Phi.png             
│   ├── TPR_A_errorbars.png            
│   ├── TPR_vs_T_A_Phi_analysis.png     
│   ├── TPR_A_errorbars_analysis.png   
│   └── network plot figures
|
├── STAT293_FinalProject.Rproj                 # RStudio project file
├── STAT_293_Final_Project_Presentation.zip    # Prensetation source file
├── STAT_293_Final_Project_Presentation.pdf    # Compiled presentation PDF
├── STAT_293_Final_Project_Report.tex          # Report source file    
└── STAT_293_Final_Project_Report.pdf          # Compiled report PDF           
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
source("00_requirements.Rmd")
```

This will:
- check R version,
- install, if needed, and load required packages, and
- create the directory structure `data/`, `data/simulated/`, and `data/results/`.
  
### Simulation Functions

```r
source("01_DataSimulation.R")
```

This files defines:
- `generate_Psi_i()`: uilds subject-specific noise covariance matrices $\Psi_i$,
- `simulate_subject_total()`: simulates multivariate time series given $A_i$, $\Phi_i$, and $\Psi_i$,
- `generate_random_individual_edges()`: adds subject-specific edges to a group-level matrix,
- `compare_mats()`: computes TP, FP, FN, TN and derived accuracy metrics, and
- `run_one_sim()`: one complete simulation and GIMME run for a given4 $T_{obs}$, returning performance metrics.

This script does not produce files by itself. It just defines the functions.

### Full Simuation and GIMME Pipeline

```r
knit("11_Method.Rmd")
```

This file:
- sources `01_DataSimulation.R`,
- clears/creates folders `sim_data/` and `sim_results/`,
- runs 60 total simulations (3 T values $\times$ 20 reps each),
- calls `run_one_sim()` for each setting,
- combines the metrics into a single `all_res` data frame, and
- writes the combined metrics to `results/all_results.csv`.

### Final Summary and Visualization

```r
knit("21_Example_and_Analysis.Rmd")
```

This file:
- loads `all_res.csv` from the `results/` folder,
- computes summary tables for A and $\Phi$ (TPR, FPR, specificity, etc.),
- creates final figures `TPR_vs_T_A_Phi_analysis.png` and `TPR_A_errorbars_analysis.png`, and
- generates network plots using `qgraph`, comparing true vs. estimated A and $\Phi$ matrices at T = 50, 150, 300.
These visuals are used in the final report/presentation.

## Quantitative Evaluation

For each of the 60 replications, we compute:
- TP, FP, FN, TN
- Sensitivity (TPR)
- Specificity
- Precision
- FPR
- FNR

We then average these metrics across 20 replications for each T value.

Key trends observed:
- Higher T improves recovery, especially for $\Phi$.
- A (contemporaneous edges) is harder to detect at low T.
- FPR decreases steadily as T increases.
- GIMME consistently recovers the main group-level patterns.

## Network Visualization

Using `qgraph`, we plot:
1. True vs. Estimated A networks for T = 50, 150, 300
2. True vs Estimated $\Phi$ networks for T = 50, 150, 300

These figures illustrate GIMME’s behavior visually, complementing quantitative accuracy.

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
- The developers of `gimme`, `qgraph`, and `tidyverse`

Last Updated: December 2025
