# Load the kernlab package - ksvm
library(kernlab)

# Set the working directory
setwd("~/projects/ISYE6501/HW1-SVM")

# Read txt file
credit_card_data <- read.table("data/credit_card_data-headers.txt", header = TRUE, sep = "")

# Print the column names of credit_card_data
# names(credit_card_data)

# Verify the target variable is a factor to train the SVM model
# str(credit_card_data$A1)

# Show the first 10 rows of credit_card_data
head(credit_card_data, 10)

# lambda is C in ksvm
# Find a value of C that works well
# A1 A2 A3 A8 A9 A10 A11 A12 A14 R1