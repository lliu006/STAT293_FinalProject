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
├── README.md              # Project overview and instructions
│
├── 00_requirements.R      # Installs and loads required R packages
├── 01_DataSimulation.R    # Simulation of group and individual uSEM data
│
├── 11_Method1.R           # Main implementation of GIMME
├── 12_Method1_aux.R       # Auxiliary/helper functions for GIMME
│
├── FinalReport.tex        # Final LaTeX report source
├── FinalReport.pdf        # Compiled report
│
├── data/                  # Data generated/used in the project
│   ├── simulated/         # Raw simulated datasets
│   └── results/           # Processed results
│
└── presentation/          # Slides for the final presentation
    ├── presentation.tex   # Beamer presentation source
    └── presentation.pdf   # Compiled presentation
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

Simulated data and analysis outputs are saved in `data/`.

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
