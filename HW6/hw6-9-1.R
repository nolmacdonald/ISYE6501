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
cat(paste("\nUS Crime Data:\n"))
print(head(data, 5))