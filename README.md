# Eurozone Youth Unemployment Analysis (Spain vs. The Core)

An institutional-grade econometric analysis investigating the structural drivers of youth unemployment discrepancies across the Eurozone, specifically contrasting Spain's service-driven micro-economies with the industrial core.

## Project Structure
* `data-raw/`: Immutable source data (Eurostat, Fed, OECD EPL index).
* `data-clean/`: Standardized, mixed-frequency joined panels.
* `scripts/`: Modular R processing, visualization, and regression pipelines.
* `outputs/`: Publication-grade dashboards and visual assets.
* `docs/`: Qualitative field observations and policy brief drafts.

## Methodological Overview
* **Data Horizon:** Q1 2005 to Q4 2019 (Explicitly truncated to prevent reporting lag gaps).
* **Econometric Framework:** Two-Way Entity Fixed Effects (FE) panel regression to isolate within-country regulatory shifts and absorb time-invariant institutional confounding.
* **Statistical Correction:** Country-level clustered standard errors to ensure inference consistency in the presence of time-series serial correlation and heteroskedasticity.

### Causal Identification Strategy (DAG Framework)

To isolate the structural impact of labor market stringency from cyclical macroeconomic noise, the model maps the causal system via a Directed Acyclic Graph (DAG) with the following parameters:
* **Exposure (D):** OECD Employment Protection Legislation (EPL) Strictness Index (Annual index asymmetrically broadcasted to quarterly frequency).
* **Outcome (Y):** Harmonized Youth Unemployment Rate (Quarterly).
* **Exogenous Confounder (X):** Real GDP Growth Rate, capturing business cycle fluctuations to isolate structural shifts from cyclical shocks (e.g., Eurozone Crisis, COVID-19).
* **Unobserved Confounders (U):** Time-invariant country-specific structures (cultural norms, baseline safety nets), completely absorbed via Entity Fixed Effects.

### Structural Equation
The formal model is specified as:

$$Y_{it} = \beta_0 + \beta_1 D_{it} + \beta_2 X_{it} + \alpha_i + \epsilon_{it}$$

Where $\alpha_i$ represents the country fixed effects, absorbing the unobserved baseline vector $U$.
