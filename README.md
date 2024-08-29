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
  
# Conda Installation

Assuming you already have conda installed, create a conda environment in your terminal.
For example, the conda environment will be named `r`.
Note that `(base) $` denotes the beginning of a terminal line with the base conda environment.
In other words, `(base) $` is not part of your commands, but shows which environment is activated.

First, make sure that you have the proper channels added to install the packages when creating an environment.

To add and list the channels:

```
(base) $ conda config --add channels r
(base) $ conda config --add channels conda-forge
(base) $ conda config --show channels
```

This should return:

```
channels:
  - conda-forge
  - r
```

R is installed using:

```
(base) $ conda create -n r
(base) $ conda activate r
(base) $ conda install -c r r-base r-essentials
```

The installed packages can be viewed for a specific conda environment by using the command `conda list --name r`.
Next, assuming RStudio is already installed, we will add an alias to the bash or zsh file to open the Application with a command.
For macOS, the bash file is located at `~/.zshrc`.

Add the alias to the bash or zsh file:

```
alias rstudio="open -na Rstudio"
```

Now you can open RStudio after restarting your terminal.
Remember, restarting your terminal deactivates your environment.

```
(base) $ source ~/.zshrc
(base) $ rstudio
```

To check the path and installation RStudio is using now that it is open we type into the console:

```
> system("type R")
R is /usr/local/bin/R
```

Note that the R path points to the default installation of R.
This is because the conda environment was not activated in the terminal.
To use your conda environment with R installed:

```
(base) $ conda activate r
(r) $ rstudio
```

Again, check the path and installation RStudio is using:

```
> system("type R")
R is /Users/<username>/mambaforge3/envs/r/bin/R
```

Note that `<username>` should be your username. 
Depending on your conda installation, `mambaforge3` could be a different name such as `miniconda`, `anaconda`, or `miniforge`.

## Additional Packages

Additional packages are installed throughout the course as needed.
Packages `ggplot2` and `dplyr` were already included in initial installation.

Packages for Module 2/Homework 1 - Classification:

```
(base) $ conda activate r
(r) $ conda install r-kernlab
(r) $ conda install r-kknn
```
