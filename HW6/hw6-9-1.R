# Import packages
# lm() and glm() are part of stats package -- auto-loaded
library(DAAG) # Cross-Validation w/ lm()
library(boot) # Cross-Validation w/ glm()
library(ggplot2) # Plotting functions
# prcomp is part of stats package -- auto-loaded

# Set seed so results are reproducible
set.seed(1)

# Set the working directory
setwd("~/projects/ISYE6501/HW6")

# Load the credit card data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)
cat(paste("\nUS Crime Data:\n"))
print(head(data, 5))

# Define the PCA data as all 15 predictors
# Exclude the response variable 'Crime'
predictors <- data[, -ncol(data)]

# Apply PCA with scaling set to TRUE
pca_model_scaled <- prcomp(predictors, center = TRUE, scale. = TRUE)

# Summary of PCA results
cat(paste("\nPCA Model (Scaled) Summary:\n"))
scaled_summary <- summary(pca_model_scaled)
print(scaled_summary)

# Use sdev (std. deviations) of principal components
variance = pca_model_scaled$sdev^2 / sum(pca_model_scaled$sdev^2)

# Get column names from "data" to utilize in scree plot
predictor_names <- colnames(data)

# Create a dataframe for plotting
variance_data <- data.frame(
  # Number of principal components
  principal_components = 1:length(variance),
  # Proportional Variance
  prop_variance = variance,
  # Component names for x-axis labels
  component_names = predictor_names[1:length(variance)]
)

# Create the scree plot with ggplot2
scree <- ggplot(variance_data, aes(x = principal_components, 
                                y = prop_variance)) +
  # Size of the markers for data points
  geom_point(size = 2) +
  # Line plot
  geom_line() +
  # Label the resulting values adjacent to each data point
  geom_text(aes(label = round(prop_variance, 3)), 
            hjust = -0.1, vjust = -0.5, size = 3) +
  # Add labels to the x-axis for all 15 components
  scale_x_continuous(breaks = 1:15, labels = paste0("PC", 1:15)) +
  labs(x = "Principle Components",
       y = "Proportion of Variance",
       title = "Proportion of Variance Explained by Principal Components") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(scree)

# 4 PRINCIPAL COMPONENTS -------------------------------------------------------
# pca_model_scaled$rotation[, 1:4]
# Create a new dataset with selected variables
selected_vars <- data[, c("Wealth", "Ineq", "So", "Po1", "Po2", "M.F", "Pop", 
                          "LF", "Crime")]

# Build the linear regression model
regression_model <- lm(Crime ~ Wealth + Ineq + So + Po1 + Po2 + M.F + Pop + LF,
                       data = selected_vars)

# Summary of Regression Model
cat(paste("\nRegression Model Summary:\n"))
lm_summary <- summary(regression_model)
print(lm_summary)

# Create a data frame with the given city data
new_city <- data.frame(
  M = 14.0, So = 0, Ed = 10.0, Po1 = 12.0, Po2 = 15.5,
  LF = 0.640, M.F = 94.0, Pop = 150, NW = 1.1,
  U1 = 0.120, U2 = 3.6, Wealth = 3200, Ineq = 20.1,
  Prob = 0.04, Time = 39.0
)

# Make predictions using the linear regression model
predicted_crime <- predict(regression_model, newdata = new_city)

# Print Predictions
cat(paste("\nPredicted Crime:\n"))
print(predicted_crime)

# Regression Model Summary:
#   
#   Call:
#   lm(formula = Crime ~ Wealth + Ineq + So + Po1 + Po2 + M.F + Pop + 
#        LF, data = selected_vars)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -618.14 -152.88   18.15  119.32  412.05 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)   
# (Intercept) -4914.9666  1552.6699  -3.165  0.00305 **
#   Wealth          0.1509     0.1078   1.401  0.16947   
# Ineq           69.1230    24.8433   2.782  0.00836 **
#   So             34.8461   130.7486   0.267  0.79129   
# Po1           142.4053   113.0817   1.259  0.21560   
# Po2           -30.4493   120.7998  -0.252  0.80235   
# M.F            23.2343    16.5454   1.404  0.16836   
# Pop            -0.6720     1.3909  -0.483  0.63177   
# LF            799.6707  1177.9274   0.679  0.50133   
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 243.9 on 38 degrees of freedom
# Multiple R-squared:  0.6716,	Adjusted R-squared:  0.6024 
# F-statistic: 9.713 on 8 and 38 DF,  p-value: 3.26e-07
# 
# 
# Predicted Crime: 789.2719 

# 4 PRINCIPAL COMPONENTS -------------------------------------------------------
# pca_model_scaled$rotation[, 1:6]

# Create a new dataset with selected variables
selected_vars2 <- data[, c("Wealth", "Ineq", "So", "Po1", "Po2", "M.F", "Pop",
                          "LF", "U1", "U2", "Prob", "Crime")]

# Build the linear regression model
regression_model2 <- lm(Crime ~ Wealth + Ineq + So + Po1 + Po2 + M.F + Pop +
                         LF + U1 + U2 + Prob, data = selected_vars2)

# Summary of Regression Model
cat(paste("\nRegression Model Summary 2:\n"))
lm_summary2 <- summary(regression_model2)
print(lm_summary2)

# Make predictions using the linear regression model
predicted_crime2 <- predict(regression_model2, newdata = new_city)

# Print Predictions
cat(paste("\nPredicted Crime 2:\n"))
print(predicted_crime2)

# Regression Model Summary 2:
#   
#   Call:
#   lm(formula = Crime ~ Wealth + Ineq + So + Po1 + Po2 + M.F + Pop + 
#        LF + U1 + U2 + Prob, data = selected_vars2)
# 
# Residuals:
#   Min     1Q Median     3Q    Max 
# -562.3 -133.3    2.4  138.0  390.0 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)   
# (Intercept) -4.812e+03  1.620e+03  -2.971  0.00533 **
#   Wealth       8.593e-02  1.085e-01   0.792  0.43382   
# Ineq         5.610e+01  2.485e+01   2.257  0.03034 * 
#   So           1.030e+02  1.467e+02   0.702  0.48717   
# Po1          1.364e+02  1.114e+02   1.225  0.22893   
# Po2         -3.283e+01  1.186e+02  -0.277  0.78357   
# M.F          3.317e+01  2.108e+01   1.573  0.12461   
# Pop         -1.049e+00  1.408e+00  -0.745  0.46118   
# LF           5.850e+02  1.483e+03   0.394  0.69570   
# U1          -3.344e+03  4.525e+03  -0.739  0.46479   
# U2           6.597e+01  8.671e+01   0.761  0.45189   
# Prob        -4.450e+03  2.048e+03  -2.173  0.03661 * 
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 235.5 on 35 degrees of freedom
# Multiple R-squared:  0.7179,	Adjusted R-squared:  0.6293 
# F-statistic: 8.098 on 11 and 35 DF,  p-value: 8.559e-07
# 
# Predicted Crime 2: 712.0623 

# Calculate the median of the "Crime" column
crime_median <- median(data$Crime)
# Print the result
cat(paste("\nOriginal Data Median Crime:\n"))
print(crime_median)
# Calculate the mean of the "Crime" column
crime_mean <- mean(data$Crime)
# Print the result
cat(paste("\nOriginal Data Mean Crime:\n"))
print(crime_mean)