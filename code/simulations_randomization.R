# Initialize lists to store results
treatment_tab_list <- list()
treatment2_tab_list <- list()
treatment3_tab_list <- list()

# Number of simulations
num_simulations <- 1000

# Simulation loop
for (i in 1:num_simulations) {
  # Set the number of observations
  num_obs <- 3300

  
  # Generate the data
  ID <- 1:num_obs
  
  # First randomization: Treatment (control, dehumanization, etc)
  set.seed(123 + i)  # Different seed for each iteration
  treatment <- sample(1:5, num_obs, replace = TRUE)
  
  # Create the dataframe
  df <- data.frame(ID, treatment)
  
  # Tabulate the treatment variable
  treatment_tab <- table(df$treatment)
  
  # Second randomization: Treatment (test, video, both)
  treatment2 <- ifelse(treatment == 1, 0, sample(1:3, num_obs, replace = TRUE))
  
  # Ensure that treatment2 is 0 where treatment is 1
  treatment2[treatment == 1] <- 0
  
  # Add treatment2 to the dataframe
  df$treatment2 <- treatment2
  
  # Tabulate the treatment2 variable
  treatment2_tab <- table(df$treatment2)
  
  # Create the 13 treatment groups
  df$treatment3 <- as.integer(factor(paste(df$treatment, df$treatment2, sep = "_")))
  
  # Tabulate the treatment3 variable
  treatment3_tab <- table(df$treatment3)
  
  # Store the results in the lists
  treatment_tab_list[[i]] <- treatment_tab
  treatment2_tab_list[[i]] <- treatment2_tab
  treatment3_tab_list[[i]] <- treatment3_tab
}



# Function to summarize a list of tables
summarize_tabs <- function(tab_list) {
   counts <- do.call(rbind, lapply(tab_list, function(x) as.numeric(x)))
    counts_summary <- data.frame(
    Mean = colMeans(counts, na.rm = TRUE),
    Min = apply(counts, 2, min, na.rm = TRUE),
    Max = apply(counts, 2, max, na.rm = TRUE)
  )
  return(counts_summary)
}

# Summarize the results for each variable
treatment_summary <- summarize_tabs(treatment_tab_list)
treatment2_summary <- summarize_tabs(treatment2_tab_list)
treatment3_summary <- summarize_tabs(treatment3_tab_list)

# Display the summary statistics
print("Summary statistics for treatment variable:")
print(treatment_summary)

print("Summary statistics for treatment2 variable:")
print(treatment2_summary)

print("Summary statistics for treatment3 variable:")
print(treatment3_summary)
