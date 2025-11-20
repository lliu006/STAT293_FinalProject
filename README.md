# STAT 293 Final Project - GIMME Simulation Study
## Fall 2025
## Instructor: Dr. Jose Angel Sanchez Gomez

**Authors:** Yijia Xue and Linlin Liu <br>
**Date:** December 4, 2025

**Primary Reference:** Gates, K. M., & Molenaar, P. C. M. (2012). *Group search algorithm recovers effective connectivity maps for individuals in homogeneous and heterogeneous samples.* NeuroImage, 63, 310-319.

## Overview

This repository contains all code and documentation for our STAT 293 Final Project evaluating the Group Iterative Multiple Model Estimation (GIMME) algorithm through a controlled simulation study.

## Objectives:

1. To simulate multivariate time–series data using a unified Structural Equation Model (uSEM).
2. To introduce realistic individual-level heterogeneity in network structure.
3. To evaluate whether GIMME can recover (i) the true group-level directed connectivity and (ii) individual-level deviations.
4. To replicate the core ideas of the Gates & Molenaar (2012) framework in a simplified setting.

*Disclaimer:* This project does not analyze real fMRI data. All results are based on simulated networks.

## Repository Structure

Below is the final directory structure required for submission:

```text
├── README.md                 # Project overview and instructions
│
├── code/                     # All R scripts for simulation and analysis
│   ├── simulate_networks.R   # Simulation of group and individual uSEM data
│   ├── run_gimme.R           # Running the GIMME algorithm
│   ├── analyze_results.R     # Recovery metrics and summary plots
│   └── utils.R               # Small helper functions
│
├── results/                  # Outputs generated after running the code
│   ├── figures/              # Time series plots, fit index histograms
│   └── gimme_output/         # Output files from gimmeSEM()
│
├── report/                   # Final written project deliverable
│   ├── report.tex            # Main LaTeX report source
│   └── report.pdf            # Compiled LaTeX report
│
└── presentation/             # Beamer slide deck for presentation
    ├── gimme_slides.tex      # Beamer presentation source
    └── gimme_slides.pdf      # Compiled presentation
```

## Simulation Summary

We simulate data for:

- 100 subjects
- 200 time points each
- 5 ROIs
- Group-level contemporaneous and lagged connections
- Individual deviations via
  - random perturbations of weights,
  - subject-specific edges added with probability 0.10.
 
Time series follow:

$$
X(t) = (I - A)^{-1} \left( \Phi X(t-1) + \varepsilon(t) \right), \qquad \varepsilon(t) \sim N(0, \sigma_\varepsilon I).
$$

All simulated data is saved in `results/`.

## Running the Project

### Install Requirements: R 4.3.1

```r
install.packages(c("gimme", "MASS", "ggplot2", "reshape2"))
```

### Run Simulation

```r
source("code/simulate_networks.R")
```

This generates subject-specific networks, simulated time series, heterogeneity summary, and example time series plots.

### Run GIMME

```r
source("code/run_gimme.R")
```

This creates the GIMME output folder with group-level path diagram, individual path estimates, summary fit indices, and path count matrix.

### Analysis of Results

```r
source("code/analyze_results.R")
```

This script computes detection of group-level paths, distribution of individual-level paths, RMSEA/CFI/SRMR summaries, and example recovery plots. Outputs are saved under `results/figures/`.

### Expected Outcomes

Given the simulation structure, we expect:
  - strong recovery of the main contemporaneous chain (X1 → X2 → X3 → X4 → X5),
  - high detection of lagged autoregressive paths,
  - detection of cross-lagged edges from X1(t−1) → X2(t) and X1(t−1) → X3(t),
  - identification of many individual-specific edges, and
  - good model fit (low RMSEA, high CFI) for most subjects.

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
