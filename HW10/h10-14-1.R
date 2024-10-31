# Load packages
library(dplyr)
library(tidyr)

# Set seed so results are reproducible
set.seed(123)

# Set the working directory
setwd("~/projects/ISYE6501/HW10")

# Load the Wisconsin breast cancer database (original)
data <- read.table("data/breast-cancer-wisconsin.data.txt", 
                   stringsAsFactors = FALSE, header = FALSE, sep = ",")
cat(paste("\nWisconsin Breaast Cancer Data:\n"))
print(head(data, 5))

# Assign column names
# colnames(data) <- c(
#     "Sample_code_number", "Clump_thickness", "Uniformity_of_cell_size",
#     "Uniformity_of_cell_shape", "Marginal_adhesion", 
#     "Single_epithelial_cell_size",
#     "Bare_nuclei", "Bland_chromatin", "Normal_nucleoli", "Mitoses", "Class"
# )


# Inspect the data (contains "?" values)
# Counting missing values that are "?" in each column
missing_values_count <- sapply(data, function(x) sum(x == "?", na.rm = TRUE))
cat(paste("\nNumber of Missing Values by Column:\n"))
print(missing_values_count)

# To confirm the missin values in V7 print the missing value rows (16)
cat(paste("\nRows with Missing Values:\n"))
print(data[which(data$V7 == "?"), ])

# Find the percentage of observations with missing data.

nrow(data[which(data$V7 == "?"),])/nrow(data)

# Find and store the indices of the missing V7 data.

missing <- which(data$V7 == "?", arr.ind = TRUE)
missing

## 24  41 140 146 159 165 236 250 276 293 295 298 316 322 412 618


#################### Mean/Mode Imputation ####################

# Function to calculate mode
get_mode <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
}

# Impute missing values
# Replace "?" with NA in the entire dataset
data_imputed <- data
data_imputed[data_imputed == "?"] <- NA

# Calculate and print the mode for the "Bare_nuclei" column
mode_V7 <- get_mode(data_imputed$V7)
cat("V7 Mode after imputation:", mode_V7, "\n")

#################### Mean/Mode Imputation ####################

# Use mode imputation since V7 is a categorical variable.

# R does not have a built in function to find the mode of a vector,
# so we create one ourselves.

getmode <- function(v) {
  # Return a vector without duplicate values
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# Find the mode of V7.

mode_V7 <- as.numeric(getmode(data[-missing,"V7"]))
mode_V7

## 1

# Impute V7 for observations with missing data for V7 to mode_V7.

data_mode_imp <- data
data_mode_imp[missing,]$V7 <- mode_V7
data_mode_imp$V7 <- as.integer(data_mode_imp$V7)

#################### Regression Imputation ####################

# Do not include the response variable in regression imputation

data_modified <- data[-missing,2:10]
data_modified$V7 <- as.integer(data_modified$V7)

# Generate linear model using all other factors as predictors

model <- lm(V7~V2+V3+V4+V5+V6+V8+V9+V10, data = data_modified)
summary(model)

# Not all predictors are significant, so use backwards stepwise
# regression for variable selection.

step(model)

# Generate the linear model that stepwise regression recommends.

final_model <- lm(V7~V2+V4+V5+V8, data = data_modified)
summary(final_model)

# Now all predictors are signifcant.

# Use cross-validation to test how good this model really is.

library(DAAG)
model_cv <- cv.lm(data_modified, final_model, m=5)
SST <- sum((as.numeric(data[-missing,]$V7) - mean(as.numeric(data[-missing,]$V7)))^2)
R2_cv <- 1 - attr(model_cv,"ms")*nrow(data[-missing,])/SST
R2_cv

## 0.603

# Get predictions for missing V7 values.

V7_hat <- predict(final_model, newdata = data[missing,])

# Impute V7 for observations with missing data for V7 to predicted
# values with this linear model.

data_reg_imp <- data
data_reg_imp[missing,]$V7 <- V7_hat
data_reg_imp$V7 <- as.numeric(data_reg_imp$V7)

# Round the V7_hat values since the originals are all integer

data_reg_imp[missing,]$V7 <- round(V7_hat)
data_reg_imp$V7 <- as.integer(data_reg_imp$V7)

# Make sure no V7 values are outside of the orignal range.

data_reg_imp$V7[data_reg_imp$V7 > 10] <- 10
data_reg_imp$V7[data_reg_imp$V7 < 1] <- 1

# NOTE: Using multinomial regression might be more proper here
# since V7 is categorical and not continuous, but we haven't
# covered that in this course.
