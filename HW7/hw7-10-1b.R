# Load packages
# glm() part of stats package -- auto-loaded
library(rpart) # Regression tree model
library(rpart.plot) # Plotting regression tree
library(randomForest) # Random forest model
library(ggplot2) # Plotting functions

# Set seed so results are reproducible
set.seed(123)

# Set the working directory
setwd("~/projects/ISYE6501/HW7")

# Load the US crime data data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)
cat(paste("\nUS Crime Data:\n"))
print(head(data, 5))

# 10.1(b) Random Forest Model
# ------------------------------------------------------------------------------
# Create the random forest model
rf_model <- randomForest(Crime ~ .,
                         data = data,
                         importance = TRUE,  # To calculate variable importance
                         ntree = 500)  # Number of trees

# Print the model summary
print(summary(rf_model))

# Check variable importance
importance(rf_model)

# Plot variable importance
varImpPlot(rf_model)