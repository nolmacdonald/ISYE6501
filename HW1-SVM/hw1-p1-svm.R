# Load the kernlab package - ksvm
library(kernlab)
library(ggplot2)

# Set the working directory
setwd("~/projects/ISYE6501/HW1-SVM")

# Clear the Global Environment stored data
rm(list=ls())

# Read txt file
credit_card_data <- read.table("data/credit_card_data-headers.txt", header = TRUE, sep = " ")
data <- read.table("data/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

# Show the first 10 rows of credit_card_data
head(credit_card_data, 10)

# lambda is C in ksvm
# Find a value of C that works well
# A1 A2 A3 A8 A9 A10 A11 A12 A14 R1

# Ensure the target variable is a factor
data[, 11] <- as.factor(data[, 11])  # Assuming R1 is the 11th column

# Create an SVM model w/ scaling
model_scaled <- ksvm(V11~., data=data, type = "C-svc", kernel = "vanilladot", C = 0.1, scaled = TRUE)

# Print the model information
print(model_scaled)

# Create an SVM model w/o scaling
model_unscaled <- ksvm(V11~., data=data, type = "C-svc", kernel = "vanilladot", C = 0.1, scaled = FALSE)

# Print the model information
print(model_unscaled)

# Calculate the coefficients a_1 to a_m
a_scaled <- colSums(model_scaled@xmatrix[[1]] * model_scaled@coef[[1]])
print(a_scaled)

a_unscaled <- colSums(model_unscaled@xmatrix[[1]] * model_unscaled@coef[[1]])

# Calculate a0, which is -model@b
a0_scaled <- -model_scaled@b
print(a0_scaled)

a0_unscaled <- -model_unscaled@b

# See what the model predicts
pred_scaled <- predict(model_scaled,data[,1:10])
pred_unscaled <- predict(model_unscaled,data[,1:10])

# Fraction of the model’s predictions match the actual classification
class_frac_scaled <- sum(pred_scaled == data[,11]) / nrow(data)
class_frac_unscaled <- sum(pred_unscaled == data[,11]) / nrow(data)

# Print the fraction to the console
cat("Fraction of model predictions matching classification: (scaled)", class_frac_scaled, "\n")
cat("Fraction of model predictions matching classification (unscaled):", class_frac_unscaled, "\n")
