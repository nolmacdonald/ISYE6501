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

# Smooth temperature time series data with Holt-Winters
# additive method is preferred when the seasonal variations are roughly constant through the series
temps_hw_add <- HoltWinters(temps_ts, alpha=NULL, beta=NULL, gamma=NULL, seasonal = "additive")

# Extract the trend component by accessing the level component of the fitted values
trend_component <- temps_hw_add$fitted[, "level"]

# Pad trend_component with NAs to match the length of temps_ts
trend_component_padded <- c(rep(NA, length(temps_ts) - length(trend_component)), trend_component)

# Assuming end of summer is September 1st, find what the indices is in data to call later
indices <- which(data$DAY == "1-Sep")

# Index for September 1st in each year (row 63 for each year checking data)
september_1st_index <- seq(indices, length(temps_ts), by = 123)  # Every year's September 1st index

# Extract original temperature data for September 1st each year
september_1st_original <- temps_ts[september_1st_index]

# Extract the trend component for September 1st (corresponding trend values)
september_1st_trend <- trend_component_padded[september_1st_index]

# Create a data frame for comparison
september_1st_data <- data.frame(
  Year = time(temps_ts)[september_1st_index],
  Original = september_1st_original,
  Trend = september_1st_trend
)

# Remove NA values (if any)
september_1st_data <- na.omit(september_1st_data)

# Plot the September 1st temperature data along with the trend
plot_september_1st <- ggplot(september_1st_data, aes(x = Year)) +
  # Plot temperature data where line color is defined farther below
  geom_line(aes(y = Original, color = "Data Set"), size = 1) +
  # Add in scatter points on the line
  geom_point(aes(y = Original, color = "Data Set"), size = 2) +
  # Plot the trend line from the fitted Holt-Winters data
  geom_line(aes(y = Trend, color = "Trend"), linetype = "dashed", size = 1) +
  # Add labels to for a title and axes
  labs(title = "Temperature Data and Trend for September 1st (1997-2015)", 
       x = "Year", y = "Temperature",
       color = "Temperature") +
  # Use floor() so the years are shown as integers rounding down
  scale_x_continuous(breaks = floor(september_1st_data$Year)) +
  theme_minimal() +
  # Rotate x-axis labels so they do not overlap
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(face = "bold")) +
  # Set the colors for the legend
  scale_color_manual(values = c("Data Set" = "red", "Trend" = "blue"))

# Display the plot
print(plot_september_1st)


# Assuming end of summer is September 1st, find what the indices is in data to call later
indices <- which(data$DAY == "1-Oct")

# Index for September 1st in each year (row 63 for each year checking data)
october_1st_index <- seq(indices, length(temps_ts), by = 123)  # Every year's September 1st index

# Extract original temperature data for September 1st each year
october_1st_original <- temps_ts[october_1st_index]

# Extract the trend component for September 1st (corresponding trend values)
october_1st_trend <- trend_component_padded[october_1st_index]

# Create a data frame for comparison
october_1st_data <- data.frame(
  Year = time(temps_ts)[october_1st_index],
  Original = october_1st_original,
  Trend = october_1st_trend
)

# Remove NA values (if any)
october_1st_data <- na.omit(october_1st_data)

# Plot the September 1st temperature data along with the trend
plot_october_1st <- ggplot(october_1st_data, aes(x = Year)) +
  # Plot temperature data where line color is defined farther below
  geom_line(aes(y = Original, color = "Data Set"), size = 1) +
  # Add in scatter points on the line
  geom_point(aes(y = Original, color = "Data Set"), size = 2) +
  # Plot the trend line from the fitted Holt-Winters data
  geom_line(aes(y = Trend, color = "Trend"), linetype = "dashed", size = 1) +
  # Add labels to for a title and axes
  labs(title = "Temperature Data and Trend for October 1st (1997-2015)", 
       x = "Year", y = "Temperature",
       color = "Temperature") +
  # Use floor() so the years are shown as integers rounding down
  scale_x_continuous(breaks = floor(october_1st_data$Year)) +
  theme_minimal() +
  # Rotate x-axis labels so they do not overlap
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(face = "bold")) +
  # Set the colors for the legend
  scale_color_manual(values = c("Data Set" = "red", "Trend" = "blue"))

# Display the plot
print(plot_october_1st)