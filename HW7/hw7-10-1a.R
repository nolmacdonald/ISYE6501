# Load packages
# glm() part of stats package -- auto-loaded
library(rpart) # Regression tree model
library(rpart.plot) # Plotting regression tree
library(ggplot2) # Plotting functions

# Set seed so results are reproducible
set.seed(123)

# Set the working directory
setwd("~/projects/ISYE6501/HW7")

# Load the US crime data data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)
cat(paste("\nUS Crime Data:\n"))
print(head(data, 5))

# 10.1(a) Regression Tree Model
# ------------------------------------------------------------------------------

# Fit the regression tree model
rpart_tree_model <- rpart(Crime ~ ., data = data, method = "anova")

# Print the summary of the model
cat("\nSummary of Regression Tree Model:\n")
print(summary(rpart_tree_model))

##   CP         nsplit rel error  xerror  xstd
## 1 0.36296293      0 1.0000000 1.067320 0.2603150
## 2 0.14814320      1 0.6370371 1.053288 0.2172616
## 3 0.05173165      2 0.4888939 1.030801 0.2400202
## 4 0.01000000      3 0.4371622 1.019464 0.2412517

# Make predictions
rpart_predictions <- predict(rpart_tree_model)

# Calculate Mean Squared Error (MSE)
rpart_mse <- mean((data$Crime - rpart_predictions)^2)
cat("Mean Squared Error:", mse, "\n")

# Plot the tree with rpart.plot
rpart.plot(rpart_tree_model, 
           # main = "Regression Tree for Crime Data", 
           type = 4,          # Type of plot
           extra = 101,      # Show fitted values at terminal nodes
           under = TRUE,     # Show splits under nodes
           box.palette = "RdYlGn", # "Blues",  # Continuous
           shadow.col = "gray",     # Add shadow effect
           nn = TRUE)        # Add node numbers

# Add the title manually with less space between tree with "line"
title(main = "Regression Tree for Crime Data",
      # Center the title
      adj = 0.5, 
      # Adjust whitespace between title and tree
      line = -17)

library(caret)

# Fit the regression tree model
rpart_tree_model <- rpart(Crime ~ ., data = data, method = "anova")

# 5-fold cross-validation
train_control <- trainControl(method = "cv", number = 5)

# Tune the model using cross-validation to find the optimal CP
tune_grid <- expand.grid(cp = seq(0.01, 0.1, by = 0.01))

# Fit the model with cross-validation
model_cv <- train(Crime ~ ., data = data, method = "rpart", 
                  trControl = train_control, tuneGrid = tune_grid)

# Prune the initial tree using the optimal CP value
pruned_tree_model <- prune(rpart_tree_model, cp = model_cv$bestTune$cp)

# Print the best CP value based on cross-validation
cat("\nOptimal CP value for pruning:", model_cv$bestTune$cp, "\n")

summary(pruned_tree_model)
##   CP         nsplit rel error  xerror  xstd
## 1 0.3629629      0 1.0000000 1.0627176 0.2641620
## 2 0.1481432      1 0.6370371 0.7664987 0.1693164
## 3 0.0700000      2 0.4888939 0.9683905 0.2428916

# Visualize the pruned tree
# Plot the tree with rpart.plot
rpart.plot(pruned_tree_model, 
           # main = "Regression Tree for Crime Data", 
           type = 4,          # Type of plot
           extra = 101,      # Show fitted values at terminal nodes
           under = TRUE,     # Show splits under nodes
           box.palette = "RdYlGn", # "Blues",  # Continuous
           shadow.col = "gray",     # Add shadow effect
           nn = TRUE)        # Add node numbers

# Add the title manually with less space between tree with "line"
title(main = "Pruned Regression Tree for Crime Data",
      # Center the title
      adj = 0.5, 
      # Adjust whitespace between title and tree
      line = 3)