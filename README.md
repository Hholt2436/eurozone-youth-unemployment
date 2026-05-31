# Eurozone Youth Unemployment Analysis (Spain vs. The Core)

An institutional-grade econometric analysis investigating the structural drivers of youth unemployment discrepancies across the Eurozone, specifically contrasting Spain's service-driven micro-economies with the industrial core.

## Project Structure
* `data-raw/`: Immutable source data (Eurostat, Fed, OECD EPL index).
* `data-clean/`: Standardized, mixed-frequency joined panels.
* `scripts/`: Modular R processing, visualization, and regression pipelines.
* `outputs/`: Publication-grade dashboards and visual assets.
* `docs/`: Qualitative field observations and policy brief drafts.

## Methodological Overview
* **Data Horizon:** Q1 1995 to Q4 2025 (Explicitly truncated to prevent reporting lag gaps).
* **Identification Strategy:** Parsimonious multiple linear regression with country-level clustered standard errors to account for serial correlation.