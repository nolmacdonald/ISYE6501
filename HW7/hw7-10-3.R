# Load packages
# glm() part of stats package -- auto-loaded
library(caret) # Cross-validation

# Set seed so results are reproducible
set.seed(123)

# Set the working directory
setwd("~/projects/ISYE6501/HW7")

# Load the german credit data into a table 999 obs. of 21 variables
data <- read.table("data/germancredit.txt", stringsAsFactors = FALSE, header = FALSE)
cat(paste("\nGerman Credit Data:\n"))
print(head(data, 20))

# Part I: Logistic regression model - glm(family=binomial(link=”logit”)`)

# Initial Model
# ------------------------------------------------------------------------------
# Convert the response variable (V21) to binary to use logit
# Good risk = 1 needs to be converted to 0
data$V21[data$V21==1] <- 0
# Bad risk = 2 needs to be converted to 1
data$V21[data$V21==2] <- 1

# Fit the logistic regression model
model <- glm(V21 ~ ., data = data, family = binomial(link = "logit"))

# Display the model summary
summary_model <- summary(model)
print(summary_model)

# Calculate the model's accuracy
# Return probabilities between 0 and 1 - "response"
# Convert probabilities into binary predictions ifelse(... > 0.5, 1, 0)
predictions <- ifelse(predict(model, type = "response") > 0.5, 1, 0)
accuracy <- mean(predictions == data$V21)
# 0.786

# Calculate McFadden's R-squared
null_model <- glm(V21 ~ 1, data = data, family = binomial(link = "logit"))
mcfadden_r2 <- 1 - (model$deviance / null_model$deviance)
# Not very good, McFadden R-squared is 0.266762

# Set the threshold based on cost ratio
cost_ratio <- 5
threshold <- 1 / (1 + cost_ratio)

# Predict probabilities
probabilities <- predict(model, type = "response")

# Classify using the adjusted threshold
predictions_adjusted <- ifelse(probabilities > threshold, 1, 0)

# Calculate the accuracy of the adjusted threshold
accuracy_adjusted <- mean(predictions_adjusted == data$V21)
cat("Accuracy with adjusted threshold:", accuracy_adjusted, "\n")



