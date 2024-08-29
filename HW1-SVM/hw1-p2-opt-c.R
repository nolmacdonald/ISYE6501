# Load required libraries
library(kernlab)
library(ggplot2)
library(dplyr)

# Read data
data <- read.table("data/credit_card_data.txt", stringsAsFactors = FALSE, header = FALSE)

# Ensure the target variable is a factor
data[, 11] <- as.factor(data[, 11])

# Create a function that runs ksvm looping over C values
opt_ksvm_c <- function(C, data, scaled = TRUE) {
  model <- ksvm(V11 ~ ., data = data, type = "C-svc", kernel = "vanilladot", C = C, scaled = scaled)
  
  # Calculate the coefficients a_1 to a_m
  a <- colSums(model@xmatrix[[1]] * model@coef[[1]])
  # a_1 to a_m need to be labeled instead of V1-V10
  names(a) <- paste0("a", 1:10)
  
  # Calculate a0, which is -model@b
  a0 <- -model@b
  
  # Predict
  pred <- predict(model, data[, 1:10])
  
  # Fraction of the model’s predictions match the actual classification
  accuracy <- sum(pred == data[, 11]) / nrow(data)
  
  # Return a data frame with C, scaled, a0, accuracy, and coefficients
  result <- data.frame(
    C = C,
    scaled = scaled,
    a0 = a0,
    accuracy = accuracy,
    t(a)  # Transpose the coefficients to be in separate columns
  )
  
  return(result)
}

# Define C values
c_values <- c(1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1, 10, 1e2, 1e3, 1e4, 1e5)

# Run the function to use ksvm over a range of C values
# Combine the results to a data frame using lapply() and bind_rows()
results_scaled <- bind_rows(lapply(c_values, opt_ksvm_c, data = data, scaled = TRUE))
results_unscaled <- bind_rows(lapply(c_values, opt_ksvm_c, data = data, scaled = FALSE))

# Combine scaled and unscaled results into one data frame
results_df <- bind_rows(results_scaled, results_unscaled)

# Print results table
print(results_df %>% select(C, scaled, accuracy))

# Filtering w/ the pipe operator %>%
# Find best C value for scaled models
best_scaled <- results_df %>% 
  filter(scaled == TRUE) %>% 
  arrange(desc(accuracy)) %>% 
  slice(1)

# Find best C value for unscaled models
best_unscaled <- results_df %>% 
  filter(scaled == FALSE) %>% 
  arrange(desc(accuracy)) %>% 
  slice(1)

cat("Best C value (Scaled):", best_scaled$C, "with accuracy:", best_scaled$accuracy, "\n")
cat("Best C value (Unscaled):", best_unscaled$C, "with accuracy:", best_unscaled$accuracy, "\n")

# Plot results of C value (x log scale) vs. Accuracy (y) 
plot <- ggplot(results_df, aes(x = C, y = accuracy, color = factor(scaled))) +
  geom_line() +
  geom_point() +
  scale_x_log10(breaks = c_values) +
  labs(x = "C (log scale)", y = "Classification Accuracy", title = "SVM Performance vs C Value") +
  scale_color_discrete(name = "SCALE", labels = c("FALSE" = "Unscaled", "TRUE" = "Scaled")) +
  theme_minimal()

# Show plot in RStudio
print(plot)
# Save the plot
ggsave("figures/svm_performance_plot.png", plot, width = 10, height = 6, dpi = 300)