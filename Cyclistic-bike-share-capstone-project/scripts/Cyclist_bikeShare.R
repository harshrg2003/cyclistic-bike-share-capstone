#Installing the packages
install.packages('tidyverse')
install.packages('janitor')
install.packages('lubridate')
#Loading the packages
library(tidyverse)
library(janitor)
library(lubridate)

#Adding a name <- Importing the csv(file_location)
Jan2021 <- read_csv("Divvy_MonthlyTripData/2021_01.csv")
Feb2021 <- read_csv("Divvy_MonthlyTripData/2021_02.csv")
Mar2021 <- read_csv("Divvy_MonthlyTripData/2021_03.csv")
Apr2021 <- read_csv("Divvy_MonthlyTripData/2021_04.csv")


str(Jan2021)
str(Feb2021)
str(Mar2021)
str(Apr2021)


#Creating new dataset name <- binding rows(all_your_datasets)
merged_df <- bind_rows(Jan2021, Feb2021, Mar2021, Apr2021)

#Cleaning & removing any spaces, parentheses, etc.
merged_df <- clean_names(merged_df)

#removing_empty(dataset_name, by leaving c() empty, it selects rows & columns)
remove_empty(merged_df, which = c())

# 1. Convert started_at & ended_at to datetime
merged_df <- merged_df %>%
  mutate(
    started_at = ymd_hms(started_at),
    ended_at   = ymd_hms(ended_at)
  )

# 2. Create ride_length in minutes
merged_df <- merged_df %>%
  mutate(ride_length = as.numeric(difftime(ended_at, started_at, units = "mins")))

# 3. Add day_of_week
merged_df <- merged_df %>%
  mutate(day_of_week = wday(started_at, label = TRUE, abbr = FALSE))

# 4. Remove invalid rides (<=0 and > 24 hours)
merged_df <- merged_df %>% 
  filter(ride_length > 0 & ride_length < 1440)

table(merged_df$member_casual) # 5. Check member_casual values

View(merged_df)
library(dplyr)
# show counts of NA per column
merged_df %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "na_count") %>%
  arrange(desc(na_count))

# Count duplicate ride_ids
sum(duplicated(merged_df$ride_id))

library(scales)
library(ggplot2)

# create output dirs
dir.create("analysis_results", showWarnings = FALSE)
dir.create("analysis_results/plots", showWarnings = FALSE)
dir.create("analysis_results/tables", showWarnings = FALSE)

merged_df <- merged_df %>%
  mutate(
    member_casual = as.factor(member_casual),
    start_hour = hour(started_at),
    month = floor_date(as_date(started_at), "month"),
    day_of_week = wday(started_at, label = TRUE, abbr = FALSE, week_start = 1)
  )
View(merged_df)

# compute count, mean, median, sd, IQR of ride_length for members vs casuals.
summary_by_type <- merged_df %>%
  group_by(member_casual) %>%
  summarise(
    n = n(),
    mean_mins = mean(ride_length, na.rm = TRUE),
    median_mins = median(ride_length, na.rm = TRUE),
    sd_mins = sd(ride_length, na.rm = TRUE),
    iqr_mins = IQR(ride_length, na.rm = TRUE),
    p10 = quantile(ride_length, 0.10, na.rm=TRUE),
    p90 = quantile(ride_length, 0.90, na.rm=TRUE)
  )

write_csv(summary_by_type, "analysis_results/tables/summary_by_type.csv")
summary_by_type

# Filter rides for visualization clarity (remove extreme outliers > 120 mins)
viz_df <- merged_df %>%
  filter(ride_length > 0 & ride_length <= 120)

# Boxplot: ride length by rider type
p_box <- ggplot(viz_df, aes(x = member_casual, y = ride_length, fill = member_casual)) +
  geom_boxplot(outlier.shape = NA) +   # hide extreme outliers
  coord_flip() +
  labs(title = "Ride Length Distribution (< 120 mins)",
       x = "Rider Type", y = "Ride Length (minutes)") +
  theme_minimal()

# Save boxplot to plots folder
ggsave("analysis_results/plots/boxplot_ride_length_by_type.png",
       p_box, width = 7, height = 4)

# Density plot with log scale
p_dens <- ggplot(viz_df, aes(x = ride_length, color = member_casual, fill = member_casual)) +
  geom_density(alpha = 0.3) +
  scale_x_log10() +
  labs(title = "Ride Length Distribution (Log Scale)",
       x = "Ride Length (minutes, log10 scale)", y = "Density") +
  theme_minimal()

# Save density plot to plots folder
ggsave("analysis_results/plots/density_ride_length_by_type.png",
       p_dens, width = 7, height = 4)

# Add log transformation to reduce skew- t-test on log(ride_length)
t_test_res <- merged_df %>%
  filter(ride_length > 0) %>%
  mutate(log_len = log(ride_length)) %>%
  { t.test(log_len ~ member_casual, data = .) }
t_test_res

# Wilcoxon rank-sum test
wilcox_res <- merged_df %>%
  filter(ride_length > 0) %>%
  wilcox.test(ride_length ~ member_casual, data = .)
wilcox_res

# Save as CSV (for backup & external use)
write_csv(merged_df, "analysis_results/tables/merged_df_cleaned.csv")

# Save as RDS (faster reload in R)
saveRDS(merged_df, "analysis_results/merged_df_cleaned.rds")

# Reload cleaned dataset
merged_df <- readRDS("analysis_results/merged_df_cleaned.rds")

# Summarize rides and avg length by day of week and rider type
by_day <- merged_df %>%
  group_by(day_of_week, member_casual) %>%
  summarise(
    rides = n(),
    avg_length = mean(ride_length, na.rm = TRUE),
    .groups = "drop"
  )
# Save summary table
write_csv(by_day, "analysis_results/tables/rides_by_day.csv")

by_day

# Remove rows with NA day_of_week
merged_df <- merged_df %>% filter(!is.na(day_of_week))

# show counts of NA per column
merged_df %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "na_count") %>%
  arrange(desc(na_count))

# Remove rows with missing critical values
merged_df <- merged_df %>%
  filter(!is.na(ended_at) & !is.na(ride_length))

# Recalculate by_day after cleaning
by_day <- merged_df %>%
  group_by(day_of_week, member_casual) %>%
  summarise(
    rides = n(),
    avg_length = mean(ride_length, na.rm = TRUE),
    .groups = "drop"
  )

# Save summary table
write_csv(by_day, "analysis_results/tables/rides_by_day.csv")

by_day

# Plot ride counts by day
p_day_count <- ggplot(by_day, aes(x = day_of_week, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Number of rides by day of week",
       x = "Day of Week", y = "Number of Rides") +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal()

# Save plot
ggsave("analysis_results/plots/rides_by_day.png", p_day_count, width=8, height=4)

# Plot avg ride length by day
p_day_len <- ggplot(by_day, aes(x = day_of_week, y = avg_length, color = member_casual, group = member_casual)) +
  geom_line(linewidth=1) + 
  geom_point(size=2) +
  labs(title = "Average ride length by day of week",
       x = "Day of Week", y = "Average Ride Length (minutes)") +
  theme_minimal()

# Save plot
ggsave("analysis_results/plots/avg_length_by_day.png", p_day_len, width=8, height=4)

# Add month and season columns
merged_df <- merged_df %>%
  mutate(
    month = month(started_at, label = TRUE, abbr = TRUE),
    season = case_when(
      month %in% c("Dec", "Jan", "Feb") ~ "Winter",
      month %in% c("Mar", "Apr", "May") ~ "Spring",
      month %in% c("Jun", "Jul", "Aug") ~ "Summer",
      month %in% c("Sep", "Oct", "Nov") ~ "Fall"
    )
  )

View(merged_df)

# 6A. Summary by month
by_month <- merged_df %>%
  group_by(month, member_casual) %>%
  summarise(
    rides = n(),
    avg_length = mean(ride_length, na.rm = TRUE),
    .groups = "drop"
  )

# Save table
write_csv(by_month, "analysis_results/tables/rides_by_month.csv")

by_month

# 6B. Plot - Number of rides by month
p_month_rides <- ggplot(by_month, aes(x = month, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Number of rides by month",
       x = "Month", y = "Number of rides") +
  theme_minimal()

ggsave("analysis_results/plots/rides_by_month.png", p_month_rides, width = 8, height = 5)

# 6C. Plot - Average ride length by month
p_month_length <- ggplot(by_month, aes(x = month, y = avg_length, color = member_casual, group = member_casual)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  labs(title = "Average ride length by month",
       x = "Month", y = "Average ride length (minutes)") +
  theme_minimal()

ggsave("analysis_results/plots/avg_length_by_month.png", p_month_length, width = 8, height = 5)

# Step 7A: Summarize rides by bike type and user type
by_bike <- merged_df %>%
  group_by(rideable_type, member_casual) %>%
  summarise(
    rides = n(),
    avg_length = mean(ride_length, na.rm = TRUE),
    .groups = "drop"
  )
# Save summary table
write_csv(by_bike, "analysis_results/tables/rides_by_bike_type.csv")

# Step 7B: Plot - Number of rides by bike type
p_bike_rides <- ggplot(by_bike, aes(x = rideable_type, y = rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Number of rides by bike type",
       x = "Bike Type", y = "Number of Rides") +
  theme_minimal()
ggsave("analysis_results/plots/rides_by_bike_type.png", p_bike_rides, width = 7, height = 5)

# Step 7C: Plot - Average ride length by bike type
p_bike_length <- ggplot(by_bike, aes(x = rideable_type, y = avg_length, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title = "Average ride length by bike type",
       x = "Bike Type", y = "Average Ride Length (minutes)") +
  theme_minimal()
ggsave("analysis_results/plots/avg_length_by_bike_type.png", p_bike_length, width = 7, height = 5)

by_bike
