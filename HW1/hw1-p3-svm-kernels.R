# Load the kernlab package
library(kernlab)

# Function to optimize C value for SVM
optimize_svm_kernels <- function(data, kernels, scaling) {
  
  results <- data.frame(kernel = character(), accuracy = numeric())
  
  for (k in kernels) {
    # Create an SVM model with options for kernel and scaling
    model <- ksvm(V11 ~ ., data = data, type = "C-svc", kernel = k, C = 100, scaled = scaling)
    
    # Make predictions
    predictions <- predict(model, data[, 1:10])
    
    # Calculate accuracy
    accuracy <- sum(predictions == data[, 11]) / nrow(data)
    
    # Add the current kernel and accuracy to the results data frame
    results <- rbind(results, data.frame(kernel = k, accuracy = accuracy))
  }
  
  # Find the best kernel and accuracy from the results data frame
  best_row <- results[which.max(results$accuracy), ]
  
  cat("Best Kernel:", best_row$kernel, "with accuracy:", best_row$accuracy, "\n")
  
  return(results)
}

# Set the working directory
setwd("~/projects/ISYE6501/HW1-SVM")

# Read data
credit_card_data <- read.table("data/credit_card_data-headers.txt", header = TRUE, sep = " ")
data <- read.table("data/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

# Define a range of kernels to test
kernels <- c("rbfdot","polydot","vanilladot","tanhdot","laplacedot","besseldot", "anovadot", "splinedot")

# Analyze kernels
results <- optimize_svm_kernels(data, kernels, scaling=TRUE)

# Print the results data frame
print(results)