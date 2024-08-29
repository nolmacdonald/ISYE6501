# Load kknn for k-nearest-neighbors
library(kknn)
library(ggplot2)

# Set the working directory
setwd("~/projects/ISYE6501/HW1-SVM")

# Read txt file
data <- read.table("data/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

# Show the first 10 rows of data
head(data, 10)

# Create a function to determine the accuracy of k-nearest-neighbors using LOOCV
kknn_accuracy <- function(data, max_k) {
  results <- data.frame(k = 1:max_k, accuracy = numeric(max_k), stringsAsFactors = FALSE)
  
  for (k in 1:max_k) {
    predictions <- rep(0, nrow(data))
    
    for (i in 1:nrow(data)) {
      model <- kknn(V11~V1+V2+V3+V4+V5+V6+V7+V8+V9+V10, 
                    data[-i, ], 
                    data[i, ],
                    k = k, 
                    kernel = "optimal",
                    scale = TRUE)
      
      # Store the predicted value using fitted.values()
      # kknn is continuous so use round() for classifications 0 or 1
      predictions[i] <- round(fitted.values(model))
    }
    
    # Store the accuracy value in the results dataframe
    results$accuracy[k] <- sum(predictions == data[, 11]) / nrow(data)
  }
  
  return(results)
}

# Look at k-values from 1 to 50
max_k <- 50

# Calculate accuracies for k from 1 to 20
results <- kknn_accuracy(data, max_k = max_k)

# Print the results data frame
print(results)

# Create a ggplot
plot <- ggplot(results, aes(x = k, y = accuracy)) +
  # geom_line(color = "blue") +
  geom_point(color = "red", size = 3) +
  theme_minimal() +
  labs(title = "KNN Classification: Accuracy vs. k",
       x = "k-value",
       y = "Accuracy") +
  scale_x_continuous(breaks = 1:max_k)

# Display the plot
print(plot)

# Optionally, save the plot
ggsave("figures/knn_accuracy_plot.png", plot, width = 10, height = 6, dpi = 300)
