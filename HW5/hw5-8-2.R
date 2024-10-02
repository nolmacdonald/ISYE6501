# Import libraries
# lm and glm are in the stats package loaded by default
library(ggplot2) # Plot functions
library(gridExtra)

# Set the working directory
setwd("~/projects/ISYE6501/HW5")

# Load the credit card data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)

# View the imported data to check import but only first few rows
print(head(data, 5))

# Create a linear regression model using all variables
# Crime~. separates Crime (response variable) from predictors
model <- lm(Crime~., data=data)
print(summary(model))

# Extract the coeffiecients
coefficients <- coef(model)

# Create a data frame with the given city data
new_city <- data.frame(
  M = 14.0, So = 0, Ed = 10.0, Po1 = 12.0, Po2 = 15.5,
  LF = 0.640, M.F = 94.0, Pop = 150, NW = 1.1,
  U1 = 0.120, U2 = 3.6, Wealth = 3200, Ineq = 20.1,
  Prob = 0.04, Time = 39.0
)

# Predict the crime rate with predict {stats}
predicted_crime_rate <- predict(model, newdata = new_city)
print(predicted_crime_rate)

pred_interval <- predict(model, newdata = new_city, interval = "confidence")
print(pred_interval)

# Create a list of predictor variables
predictors <- c("M", "So", "Ed", "Po1", "Po2", "LF", "M.F", "Pop", "NW", "U1",
                "U2", "Wealth", "Ineq", "Prob", "Time")

# Function to create a scatter plot with regression line for each predictor
plot_predictor <- function(predictor) {
  ggplot(data, aes_string(x = predictor, y = "Crime")) +
    geom_point(alpha = 0.5) +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    theme_minimal() +
    labs(title = paste("Crime vs", predictor))
}

# Create plots for all predictors
plots <- map(predictors, plot_predictor)


# Arrange plots in a grid
scatter <- grid.arrange(grobs = plots, ncol = 4)
print(scatter)
# Optionally, save the plot
ggsave("figures/crime_correlation_regression.png", scatter, width = 10, height = 6, dpi = 300)