# Import libraries for SVM and KNN
library(kernlab)
library(kknn)

library(ggplot2)
library(patchwork)

# Set the working directory
setwd("~/projects/ISYE6501/HW2-Validation-Clustering")

# Load the iris data set
data <- read.table("data/iris.txt", stringsAsFactors = FALSE, header = TRUE)

# Plot the petal data to look at the data set before clustering
petal_plot <- ggplot(data, aes(Petal.Length, Petal.Width)) +
  geom_point(aes(col = Species), size = 4) +
  labs(
    title = "Iris Flower Species Petals",
    x = "Petal Length (cm)",
    y = "Petal Width (cm)"
  )
# Save the plot
ggsave("figures/petal_species.png", petal_plot, width = 10, height = 6, dpi = 300)
# Show the plot
print(petal_plot)

# Plot the sepal data to look at the data set before clustering
sepal_plot <- ggplot(data, aes(Sepal.Length, Sepal.Width)) +
  geom_point(aes(col = Species), size = 4) +
  labs(
    title = "Iris Flower Species Sepals",
    x = "Sepal Length (cm)",
    y = "Sepal Width (cm)"
  )
# Save the plot
ggsave("figures/sepal_species.png", sepal_plot, width = 10, height = 6, dpi = 300)
# Show the plot
print(sepal_plot)

# Combine and display the plots side by side using patchwork
combined_plot <- petal_plot + sepal_plot
# Save the plot with both side by side
ggsave("figures/combined_plots.png", plot = combined_plot, width = 14, height = 6, dpi = 300)
# Show the combined plot
print(combined_plot)

# Setting the seed is important for reproducibility
set.seed(123)