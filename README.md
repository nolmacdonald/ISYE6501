# ISYE6501

Introduction to Analytics Modeling - Georgia Tech (Fall 2024)

Professor: Dr. Joel Sokol

## Contents

-   Homework 1 - Classification
-   Homework 2 - Validation, Clustering
-   Homework 3 - Basic Data Preparation, Change Detection
-   Homework 4 - Time Series Models
-   Homework 5 - Basic Regression
-   Homework 6 - Advanced Data Preparation
-   Homework 7 - Advanced Regression, Tree-based Models
-   Homework 8 - Variable Selection
-   Homework 9 - Design of Experiments, Probability-based Models
-   Homework 10 - Missing Data, Optimization
-   Homework 11 - Optimization, Advanced Models
-   Homework 12 - Discussion Cases – Case Format, Power Company Case
-   Homework 13 - Discussion Cases – Retailer Case
-   Homework 14 - Discussion Cases – Monetization Case

## Resources

-   R Markdown - All documentation is generated with R Markdown
    -   Check out [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/)

## Documentation

The documentation can be rendered by setting the working directory to where the `docs` folder is located.
For GitHub pages, use the `gitbook` command.
For a PDF use the `pdf_book` command.

```
setwd("~/projects/ISYE6501/docs")
bookdown::render_book("index.Rmd", "bookdown::gitbook")
bookdown::render_book("index.Rmd", "bookdown::pdf_book")
```
