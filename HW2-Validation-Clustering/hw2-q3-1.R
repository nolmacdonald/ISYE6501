# Import libraries
library(kknn) # KNN
library(ggplot2)

# Set the working directory
setwd("~/projects/ISYE6501/HW2-Validation-Clustering")

# Load the credit card data into a table
data <- read.table("data/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

# Target variable V11 must be categorical
data$V11 <- as.factor(data$V11)

# View the imported data to check first few rows
head(data, 10)

# Setting the seed is important for reproducibility
set.seed(123)

# Manually split the data into training (70%) and testing (30%) sets
sample_index <- sample(seq_len(nrow(data)), size = 0.7 * nrow(data))
trainData <- data[sample_index, ]
testData <- data[-sample_index, ]

# Perform cross-validation to find the best k
k_values <- 1:50 # Define a range of k values to test

# Initialize a dataframe to store k values and corresponding accuracies
results_df <- data.frame(k = integer(), accuracy = numeric(), stringsAsFactors = FALSE)

# Initialize a vector to store the mean accuracy for each k
cv_accuracies <- numeric(length(k_values))

for (i in seq_along(k_values)) {
  k <- k_values[i]
  
  # Perform cross-validation
  cv_result <- cv.kknn(V11 ~ ., data = trainData, kcv = 10, k = k)
  
  # Extract accuracy values
  accuracy_values <- cv_result[[2]]
  
  # Calculate the mean accuracy for this k
  mean_accuracy <- mean(accuracy_values, na.rm = TRUE)
  cv_accuracies[i] <- mean_accuracy
  
  # Append results to the dataframe
  results_df <- rbind(results_df, data.frame(k = k, accuracy = mean_accuracy, stringsAsFactors = FALSE))
}

# Find the best k
best_k <- k_values[which.max(cv_accuracies)]
best_k_accuracy <- max(cv_accuracies, na.rm = TRUE)

# Print the best k and corresponding accuracy
cat("Best k:", best_k, "\n")
cat("Best k Accuracy:", best_k_accuracy, "\n")

# Plot k vs. accuracy
# Create the scatter plot with larger points and a label for k = 13 with accuracy value
plot <- ggplot(results_df, aes(x = k, y = accuracy)) +
  geom_point(size = 3, color = "blue") +               # Adjust the size and color of the points
  geom_text(data = subset(results_df, k == 13),         # Filter the dataframe for k = 13
            aes(label = paste0("k = ", k, " (", round(accuracy, 6), ")")), # Label text with accuracy value
            vjust = -1,                                # Vertical adjustment for label position
            hjust = 1,                                 # Horizontal adjustment for label position
            color = "red",                             # Color of the label text
            size = 4) +                                  # Size of the label text
labs(title = "K vs Accuracy",
     x = "Number of Neighbors (k)",
     y = "Accuracy") +
  theme_minimal() +                                    # Use a minimal theme for the plot
  theme(axis.text = element_text(size = 12),           # Increase axis text size for readability
        axis.title = element_text(size = 14))          # Increase axis title size for readability

# Show the plot
print(plot)
# Save the plot
# ggsave("figures/knn_accuracy_cross_validation.png", plot, width = 10, height = 6, dpi = 300)

# Train the final model with the best k
final_model <- kknn(V11 ~ ., trainData, testData, k = best_k)

# Predict and evaluate the model on the test set
test_predictions <- fitted(final_model)
confusion_matrix <- table(testData$V11, test_predictions)
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)

# Print the accuracy on the test set
cat("Test Set Accuracy:", accuracy, "\n")
