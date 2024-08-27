# Homework 1

ISYE 6501 - Introduction to Analytics Modeling

Module 2 - Classification

*Due August 29, 2024 at 2AM EST*

## Question 2.1

**Describe a situation or problem from your job, everyday life, current events, etc., for which a classification model would be appropriate. List some (up to 5) predictors that you might use.**

Sports analytics?
Nuclear thermal hydraulics?

## Question 2.2

The files `credit_card_data.txt` (without headers) and `credit_card_data-headers.txt` (with headers) contain a dataset with 654 data points, 6 continuous and 4 binary predictor variables.  It has anonymized credit card applications with a binary response variable (last column) indicating if the application was positive or negative. The dataset is the “Credit Approval Data Set” from the UCI Machine Learning Repository (https://archive.ics.uci.edu/ml/datasets/Credit+Approval) without the categorical variables and without data points that have missing values.

1.	Using the support vector machine function `ksvm` contained in the R package `kernlab`, find a good classifier for this data. Show the equation of your classifier, and how well it classifies the data points in the full data set.  (Don’t worry about test/validation data yet; we’ll cover that topic soon.)

Notes on `ksvm`:

- You can use `scaled=TRUE` to get `ksvm` to scale the data as part of calculating a classifier.
- The term λ we used in the SVM lesson to trade off the two components of correctness and margin is called C in `ksvm`.  One of the challenges of this homework is to find a value of C that works well; for many values of C, almost all predictions will be “yes” or almost all predictions will be “no”.
- `ksvm` does not directly return the coefficients a0 and a1…am.  Instead, you need to do the last step of the calculation yourself.  Here’s an example of the steps to take (assuming your data is stored in a matrix called data):[^1]

```
# call ksvm.  Vanilladot is a simple linear kernel.
model <- ksvm(data[,1:10],data[,11],type=”C-svc”,kernel=”vanilladot”,C=100,scaled=TRUE)
# calculate a1…am
a <- colSums(model@xmatrix[[1]] * model@coef[[1]])
a
# calculate a0
a0 <- –model@b
a0
# see what the model predicts
pred <- predict(model,data[,1:10])
pred
# see what fraction of the model’s predictions match the actual classification
sum(pred == data[,11]) / nrow(data)
```

Hint: You might want to view the predictions your model makes; if C is too large or too small, they’ll almost all be the same (all zero or all one) and the predictive value of the model will be poor.  Even finding the right order of magnitude for C might take a little trial-and-error.

[^1]: I know I said I wouldn’t give you exact R code to copy, because I want you to learn for yourself.  In general, that’s definitely true – but in this case, because it’s your first R assignment and because the ksvm function leaves you in the middle of a mathematical calculation that we haven’t gotten into in this course, I’m giving you the code.

## KVSM: Support Vector Machines (SVM)

[KVSM R Documentation](https://www.rdocumentation.org/packages/kernlab/versions/0.9-33/topics/ksvm)
- C-svc, nu-svc, (classification) one-class-svc (novelty) eps-svr, nu-svr (regression) formulations

## Notes

- 654 observations (obs) of 11 variables
- A1, A2, A3, A8, A9, A10, A11, A12, A14, A15, R1
- A1: b, a (yes/no?)
- A2: Continuous 
- A3: Continuous 
- A8: Continuous 
- A9: T/F
- A10: T/F 
- A11: Continuous 
- A12: T/F 
- A14: Continuous 
- A15: Continuous 
- R1: Not in reference data, label for approval, 1 is yes, 0 is no

1. Load the Packages/Data

```
# Load the kernlab package - ksvm
library(kernlab)

# Set the working directory
setwd("~/projects/ISYE6501/HW1-SVM")

# Read txt file
credit_card_data <- read.table("data/credit_card_data-headers.txt", header = TRUE, sep = "")
```

2. Prepare the Data
- Your target variable (yes/no for approval is R1 in the data set)

```
credit_card_data <- as.factor(credit_card_data$R1)
```
