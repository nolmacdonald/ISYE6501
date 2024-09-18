# Import libraries
# No import needed, HoltWinters is in stats, pre-installed
library(ggplot2)

# Set the working directory
setwd("~/projects/ISYE6501/HW4")

# Load the temperature data into a table
data <- read.table("data/temps.txt", stringsAsFactors = FALSE, header = TRUE)

# Time series objects in R  need to be formatted as a vector
# We need the values - Drop the dates column
temps <- as.vector(unlist(data[, 2:21]))

# Use ts to create a time series object from the vector "temps"
# From data we know the start time is 1996, so start = 1996
# There are 123 temperature recordings or "frequency"
temps_ts <- ts(temps, start = 1996, frequency = 123)

# Convert time series to data frame to plot with ggplot2
ts_df <- data.frame(
  Time = as.numeric(time(temps_ts)),  # Extract time as a numeric vector
  Temperature = as.numeric(temps)        # Extract values
)

# Plot the time series data to visualize stored in a dataframe
temp_plot <- ggplot(ts_df, aes(x = Time, y = Temperature)) +
  geom_line(color = "blue") +  # Line plot
  labs(title = "Time Series Plot - Temperature", x = "Time", y = "Temperature") +
  theme_minimal()

print(temp_plot)

# Smooth temperature time series data with Holt-Winters
# additive method is preferred when the seasonal variations are roughly constant through the series
temps_hw_add <- HoltWinters(temps_ts, alpha=NULL, beta=NULL, gamma=NULL, seasonal = "additive")

# Smooth temperature time series data with Holt-Winters
# multiplicative method is preferred when the seasonal variations are changing proportional to the level of the series
temps_hw_mult <- HoltWinters(temps_ts, alpha=NULL, beta=NULL, gamma=NULL, seasonal = "multiplicative")

# Create a separate data frame for the fitted values
# Since the fitted values are not the same length as the original data,
# the dataframe needs to be padded with NA values (that won't be used in plot)
# This will allow for me to merge all data into a single dataframe
fitted_df <- data.frame(
  Time = as.numeric(time(temps_ts)),
  Fitted = c(rep(NA, length(temps_ts) - length(fitted(temps_hw_mult)[, 1])), fitted(temps_hw_mult)[, 1])
)
# Merge the original data frame with the fitted values data frame
combined_df <- merge(ts_df, fitted_df, by = "Time")

# Plot the original and fitted values for temperature time series
temp_plot_fit <- ggplot(combined_df, aes(x = Time)) +
  geom_line(aes(y = Temperature), color = "blue", linetype = "solid") +   # Original data
  geom_line(aes(y = Fitted), color = "red", linetype = "solid") + # Fitted values
  labs(title = "Holt-Winters Fitted Temperature", x = "Time", y = "Temperature") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) # Center the title

print(temp_plot_fit)

