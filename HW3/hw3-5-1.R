# Import libraries
library(outliers)

# Set the working directory
setwd("~/projects/ISYE6501/HW3")

# Load the credit card data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)

# Create a dataframe for ONLY crime rate per 100,000 people
# Create a dataframe for ONLY crime rate per 100,000 people
crime_data <- data.frame(Crime = data$Crime)

# Show summary or distribution of dataset
print(summary(crime_data))

# Perform Grubbs' test for outliers on the Crime column
grubbs_test_result <- grubbs.test(data$Crime)

# Print the test result
print(grubbs_test_result)

# Perform Generalized Grubbs' test for two outliers
grubbs_test_two <- grubbs.test(data$Crime, type = 11)  # 11 means two-sided test

# Print the test result
print(grubbs_test_two)