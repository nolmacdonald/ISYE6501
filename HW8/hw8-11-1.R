# Load packages
library(glmnet)

# Set seed so results are reproducible
set.seed(123)

# Set the working directory
setwd("~/projects/ISYE6501/HW8")

# Load the US crime data data into a table
data <- read.table("data/uscrime.txt", stringsAsFactors = FALSE, header = TRUE)
cat(paste("\nUS Crime Data:\n"))
print(head(data, 5))