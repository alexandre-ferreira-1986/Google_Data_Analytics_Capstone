
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)

# Set the working directory to the location of the CSV files
setwd("D:/codigos/R/DATA")


# Create a list of all CSV files in the directory
file_list <- list.files(pattern = "*.csv")

# Read each file and combine them
bike_trip <- do.call(rbind, lapply(file_list, function(file) {
  read.csv(file, stringsAsFactors = FALSE)
}))

# Now bike_trip contains data from all the CSV files

# Print a preview
head(bike_trip)

# Structure of the dataset
str(bike_trip)

# Informations
glimpse(bike_trip)

# Check missing datas
colSums(is.na(bike_trip))

# Deleting columns with missing data
bike_trip <- bike_trip %>% 
  select(-end_lat) %>% 
  select(-end_lng)

# Creating column: ride_length
library(lubridate)
bike_trip$started_at = ymd_hms(bike_trip$started_at)
bike_trip$ended_at = ymd_hms(bike_trip$ended_at)

bike_trip$ride_length <- (bike_trip$ended_at - bike_trip$started_at)

# Day of Week (Sun:1, Mon:2, ... Sat: 7)
bike_trip$day_of_week <- wday(bike_trip$started_at, week_start = 1)

# Calculate the mean of ride_length
mean(bike_trip$ride_length)

# Calculate the max and min ride_length
max(bike_trip$ride_length)
min(bike_trip$ride_length)

# Checando a quantidade de distancias negativas
sum(bike_trip$ride_length < 0, na.rm = TRUE)

bike_trip <- subset(bike_trip, ride_length >= 0)

# Calculate the mode of week_day
bike_trip %>%
  count(day_of_week) %>%
  arrange(desc(n)) %>%
  slice(1) %>%
  pull(day_of_week)

# Distribution by day
bike_trip %>%
  group_by(day_of_week) %>%
  summarise(total = n()) %>%
  arrange(desc(total))

# Calculate the average ride_length by members and casual riders
bike_trip %>% 
  group_by(member_casual) %>% 
  summarize(media = mean(ride_length))

bike_trip %>% 
  group_by(member_casual) %>% 
  summarize(media = mean(ride_length)) %>%
  # Convert 'media' from difftime to numeric (e.g., minutes)
  mutate(media_min = as.numeric(media, units = "secs")) %>%
  # Creating the plot
  ggplot(aes(x = member_casual, y = media_min, fill = member_casual)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(x = "User Type", y = "Average Ride Length (seconds)", title = "Average Ride Length by User Type") +
  theme_minimal()

# Calculate average by day_of_week and type of user
bike_trip %>%
  group_by(day_of_week, member_casual) %>%
  summarize(Average_ride_length = mean(ride_length)) %>%
  pivot_wider(names_from = member_casual, values_from = Average_ride_length)

bike_trip %>%
  group_by(day_of_week, member_casual) %>%
  summarize(Average_ride_length = mean(ride_length) / 60) %>%  # Convertendo de segundos para minutos
  pivot_wider(names_from = member_casual, values_from = Average_ride_length)

# Calculate the number of rides by users
library(tidyverse)
bike_trip %>%
  group_by(day_of_week, member_casual) %>%
  summarize(Count_of_rides = n()) %>%
  pivot_wider(names_from = member_casual, values_from = Count_of_rides)

bike_trip %>%
  group_by(day_of_week, member_casual) %>%
  summarise(ride_count = n(), .groups = "drop") %>%
  ggplot(aes(x = day_of_week, y = ride_count, color = member_casual, group = member_casual)) +
  geom_line() +
  labs(x = "Day of the Week", y = "Number of Rides", title = "Rides Distribution by User Type and Day of Week") +
  theme_minimal()

write.csv(bike_trip, file = "bike_trip_clean.csv", row.names = FALSE)
