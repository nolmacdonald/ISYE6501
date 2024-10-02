# Import packages
# lm() and glm() are part of stats package -- auto-loaded
library(DAAG) # Cross-Validation w/ lm()
library(boot) # Cross-Validation w/ glm()

# Set seed so results are reproducible
set.seed(1)

# Set the working directory
setwd("~/projects/ISYE6501/HW6")

# Load the credit card data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)

# Create a linear regression model using all variables
# Crime~. separates Crime (response variable) from predictors
model <- lm(Crime~., data=data)
cat(paste("\nModel 1 Summary (15 Predictors):"))
print(summary(model))

# Model 1 Summary (15 Predictors):
#
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -395.74  -98.09   -6.69  112.99  512.67 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -5.984e+03  1.628e+03  -3.675 0.000893 ***
#   M            8.783e+01  4.171e+01   2.106 0.043443 *  
#   So          -3.803e+00  1.488e+02  -0.026 0.979765    
# Ed           1.883e+02  6.209e+01   3.033 0.004861 ** 
#   Po1          1.928e+02  1.061e+02   1.817 0.078892 .  
# Po2         -1.094e+02  1.175e+02  -0.931 0.358830    
# LF          -6.638e+02  1.470e+03  -0.452 0.654654    
# M.F          1.741e+01  2.035e+01   0.855 0.398995    
# Pop         -7.330e-01  1.290e+00  -0.568 0.573845    
# NW           4.204e+00  6.481e+00   0.649 0.521279    
# U1          -5.827e+03  4.210e+03  -1.384 0.176238    
# U2           1.678e+02  8.234e+01   2.038 0.050161 .  
# Wealth       9.617e-02  1.037e-01   0.928 0.360754    
# Ineq         7.067e+01  2.272e+01   3.111 0.003983 ** 
#   Prob        -4.855e+03  2.272e+03  -2.137 0.040627 *  
#   Time        -3.479e+00  7.165e+00  -0.486 0.630708    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 209.1 on 31 degrees of freedom
# Multiple R-squared:  0.8031,	Adjusted R-squared:  0.7078 
# F-statistic: 8.429 on 15 and 31 DF,  p-value: 3.539e-07
# 
# Predicted Crime Rate: 155.434896887446 
# Predicted Crime Rate Confidence Interval: 
#   fit       lwr      upr
# 1 155.4349 -1310.076 1620.946

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
cat(paste("Predicted Crime Rate:", predicted_crime_rate), "\n")

pred_interval <- predict(model, newdata = new_city, interval = "confidence")
cat(paste("Predicted Crime Rate Confidence Interval:"), "\n")
print(pred_interval)

# Linear regression model with only significant variables
model2 <- lm( Crime ~  M + Ed + Po1 + U2 + Ineq + Prob, data = data)

# Summary of the second model with less predictors
cat(paste("\nModel 2 Summary (6 Predictors):"))
print(summary(model2))

# Extract the coeffiecients
coefficients_2 <- coef(model2)

# Predict the crime rate with predict {stats}
predicted_crime_rate_2 <- predict(model2, newdata = new_city)
cat(paste("Predicted Crime Rate (Model 2):", predicted_crime_rate_2), "\n")

pred_interval_2 <- predict(model2, newdata = new_city, interval = "confidence")
cat(paste("Predicted Crime Rate Confidence Interval (Model 2):"), "\n")
print(pred_interval_2)

# Model 2 Summary (6 Predictors):
#   Call:
#   lm(formula = Crime ~ M + Ed + Po1 + U2 + Ineq + Prob, data = data)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -470.68  -78.41  -19.68  133.12  556.23 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -5040.50     899.84  -5.602 1.72e-06 ***
#   M             105.02      33.30   3.154  0.00305 ** 
#   Ed            196.47      44.75   4.390 8.07e-05 ***
#   Po1           115.02      13.75   8.363 2.56e-10 ***
#   U2             89.37      40.91   2.185  0.03483 *  
#   Ineq           67.65      13.94   4.855 1.88e-05 ***
#   Prob        -3801.84    1528.10  -2.488  0.01711 *  
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 200.7 on 40 degrees of freedom
# Multiple R-squared:  0.7659,	Adjusted R-squared:  0.7307 
# F-statistic: 21.81 on 6 and 40 DF,  p-value: 3.418e-11
# 
# Predicted Crime Rate (Model 2): 1304.24521072363 
# Predicted Crime Rate Confidence Interval (Model 2): 
#   fit      lwr      upr
# 1 1304.245 1180.741 1427.749

# Use DAAG for 5-fold cross-validation (CV)
# "m" is number of folds
cv_5fold <- cv.lm(data, model2, m = 5)

# Overall mean squared prediction error in cv is "ms"
# NOTE typo in cv.lm -- "sum over all n folds", n is actually the number
# of data points in the last fold, not the number of folds.

# Calculate R-squared values directly
# R^2 = 1 - SSEresiduals / SSEtotal

# total sum of squared differences between data and its mean
SStot <- sum((data$Crime - mean(data$Crime))^2)

# for model, model2, and cross-validation, calculated SEres
SSres_model <- sum(model$residuals^2)

SSres_model2 <- sum(model2$residuals^2)

# mean squared error, times number of data points, gives sum of squared errors
SSres_cv <- attr(cv_5fold, "ms") * nrow(data)

# Calculate R-squareds for model, model2, cross-validation

rsq_model <- 1 - SSres_model / SStot # initial model with insignificant factors
# 0.803

rsq_model2 <- 1 - SSres_model2 / SStot # model2 without insignificant factors
# 0.766

rsq_cv <- 1 - SSres_cv / SStot # cross-validated
# 0.638

# So, this shows that including the insignificant factors overfits compared to removing them,
# and even the fitted model is probably overfitted.
# That's not so surprising, since we started with just 47 data points and we have 15 factors to predict from.
# The ratio of data points to factors is about 3:1, 
# and it's usually good to have 10:1 or more.

# Try cross-validation on the first, 15-factor model
cv_first <- cv.lm(data, model, m=5)

# mean squared error, times number of data points, gives sum of squared errors
SSres_cv_first <- attr(cv_first, "ms") * nrow(data)
rsq_cv_first <- 1 - SSres_cv_first / SStot # cross-validated
# 0.413

# That's a huge difference from the 0.803 reported by lm() on the training data,
# which demonstrates the need to validate!

# glm model for regression -----------------------------------------------------
# Using glm() instead of lm()
# More general function for regression
glm_model <- glm(Crime ~ . , data=data, family="gaussian")
cat(paste("\nglm Model Summary (15 Predictors):"))
print(summary(glm_model))

# glm Model Summary (15 Predictors):
#   Call:
#   glm(formula = Crime ~ ., family = "gaussian", data = data)

# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -5.984e+03  1.628e+03  -3.675 0.000893 ***
#   M            8.783e+01  4.171e+01   2.106 0.043443 *  
#   So          -3.803e+00  1.488e+02  -0.026 0.979765    
# Ed           1.883e+02  6.209e+01   3.033 0.004861 ** 
#   Po1          1.928e+02  1.061e+02   1.817 0.078892 .  
# Po2         -1.094e+02  1.175e+02  -0.931 0.358830    
# LF          -6.638e+02  1.470e+03  -0.452 0.654654    
# M.F          1.741e+01  2.035e+01   0.855 0.398995    
# Pop         -7.330e-01  1.290e+00  -0.568 0.573845    
# NW           4.204e+00  6.481e+00   0.649 0.521279    
# U1          -5.827e+03  4.210e+03  -1.384 0.176238    
# U2           1.678e+02  8.234e+01   2.038 0.050161 .  
# Wealth       9.617e-02  1.037e-01   0.928 0.360754    
# Ineq         7.067e+01  2.272e+01   3.111 0.003983 ** 
#   Prob        -4.855e+03  2.272e+03  -2.137 0.040627 *  
#   Time        -3.479e+00  7.165e+00  -0.486 0.630708    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for gaussian family taken to be 43707.93)
# 
# Null deviance: 6880928  on 46  degrees of freedom
# Residual deviance: 1354946  on 31  degrees of freedom
# AIC: 650.03
# 
# Number of Fisher Scoring iterations: 2

# glm Model 2 with only 6 predictors
glm_model2 <- glm(Crime ~ M + Ed + Po1 + U2 + Ineq + Prob ,
                  data=data, family="gaussian")
cat(paste("\nglm Model 2 Summary (6 Predictors):"))
print(summary(glm_model2))

# glm Model 2 Summary (6 Predictors):
#   Call:
#   glm(formula = Crime ~ M + Ed + Po1 + U2 + Ineq + Prob, family = "gaussian", 
#       data = data)
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -5040.50     899.84  -5.602 1.72e-06 ***
#   M             105.02      33.30   3.154  0.00305 ** 
#   Ed            196.47      44.75   4.390 8.07e-05 ***
#   Po1           115.02      13.75   8.363 2.56e-10 ***
#   U2             89.37      40.91   2.185  0.03483 *  
#   Ineq           67.65      13.94   4.855 1.88e-05 ***
#   Prob        -3801.84    1528.10  -2.488  0.01711 *  
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for gaussian family taken to be 40276.42)
# 
# Null deviance: 6880928  on 46  degrees of freedom
# Residual deviance: 1611057  on 40  degrees of freedom
# AIC: 640.17
# 
# Number of Fisher Scoring iterations: 2

# Cross-Validation with glm model ----------------------------------------------

# 5-fold Cross-Validation (K=5) with 15 predictor glm model
cv_glm <- cv.glm(data, glm_model, K=5)
# 5-fold Cross-Validation (K=5) with 6 predictor glm model
cv_glm2 <- cv.glm(data, glm_model2, K=5)

# Sum of Squared Errors --------------------------------------------------------

# 5-fold Cross-Validation with 15 predictor glm model
# mean squared error is cv_glm$delta[1]
# SStot: total sum of squared differences between data and its mean
SSres_cv_glm <- 1 - cv_glm$delta[1] * nrow(data) / SStot
# 0.281 - Could be different with random seed
# Low R-squared value when cross-validating the 15-factor model

# 5-fold Cross-Validation with 6 predictor glm model
# mean squared error is cv_glm2$delta[1]
# SStot: total sum of squared differences between data and its mean
SSres_cv_glm2 <- 1 - cv_glm2$delta[1] * nrow(data) / SStot
# 0.671 - Could be different with random seed
