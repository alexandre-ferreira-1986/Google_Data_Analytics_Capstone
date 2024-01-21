# Google_Data_Analytics_Capstone
Bike Share Analysis

<p align="center">
<img width="1080" alt="Capture" src="https://github.com/alexandre-ferreira-1986/Google_Data_Analytics_Capstone/blob/main/images/central.png">
</p>

## Quick Links:
### Data Source: [divvy_tripdata](https://divvy-tripdata.s3.amazonaws.com/index.html)

## Introduction

- This case study showcases a data analysis project carried out as a component of the Google Data Analytics Professional Certificate course, specifically the Capstone Project, with a primary focus on Cyclistic, a bike-share company.
- The culmination of this endeavor occurs following the accomplishment of seven preceding courses and serves as a means to synthesize all the knowledge acquired during the program.
- I am a junior data analyst working on the marketing team at Cyclistic.
- The director of marketing believes the company's future success depends on maximizing the number of annual memberships.

## Tools used in Analysis
Preliminary analyses were done in Excel. However, as the 2023 data was too dense, it was chosen to work in RStudio to optimize the analyses.
- R Studio

## Data Analysis Process
## Ask Phase:
  1. What is the problem you are trying to solve?

     **Answer:** /the primary problem is to design marketing strategies to convert casual riders into annuam members of Cyclistic, leveraging historical bike trip data to understand how annual members and casual riders differ, and why casual riders would buy a membership.

   2. What question do you have to answer?

      **Question:** How do annual members and casual riders use Cyclistic bikes differently?
      - The director of marketing assigned this question to answer.

  3. The following questions will guide the analysis:

  - Average Ride Duration by Day and User (in seconds and converted to minutes)
  - Frequency of Rides per User
  - Number of Rides
  - The most frequented day

## Prepare Phase:
- The dataset used for this project is public data provided by Motivate International Inc. It consists of monthly files covering the period from January 2023 to December 2023. 
- Each file within the dataset contains 13 columns related to the bike rides. 
- These columns provide detailed information about each ride, including the ride ID, rideable type, start and end station ID’s and locations, coordinates, and membership type.
- After joining the tables, the result was a dataframe with 13 columns and over 5 million rows, which prompted the use of the R Studio tool for a more robust analysis.
- Despite being more comfortable with Python, I preferred to use R, which was taught during the course.

## Process Phase:

  1. Set the working directory
  2. Create a list with all CSV files
     ~~~
       file_list <- list.files(pattern = "*.csv")
     ~~~
  3. Read each file and combine them
     
     ~~~
       bike_trip <- do.call(rbind, lapply(file_list, function(file) {
        read.csv(file, stringsAsFactors = FALSE)
      }))
     ~~~
   4. Check missing data
      
      ~~~
        colSums(is.na(bike_trip))
      ~~~
  5. Delete columns with missing data because I will not use them during the analysis
     
     ~~~
       bike_trip <- bike_trip %>% 
          select(-end_lat) %>% 
          select(-end_lng)
     ~~~
   6. Converting "started_at" and "ended_at" to DATETIME FORMAT
       
      ~~~
        library(lubridate)
        bike_trip$started_at = ymd_hms(bike_trip$started_at)
        bike_trip$ended_at = ymd_hms(bike_trip$ended_at)
      ~~~

## Analyze Phase:

During the Analyze stage, we explore the data to reveal insights and tackle the significant discoveries concerning the distinct usage patterns of Cyclistic bikes by annual members and casual riders. 

Our primary objective is to gain an understanding of their actions, preferences, and trends, which will guide our marketing strategies aimed at converting casual riders into annual members. 

To address these crucial findings, we conducted the following analyses using R Studio.

1. Create column **ride_length**:
   ~~~
     bike_trip$ride_length <- (bike_trip$ended_at - bike_trip$started_at)
   ~~~
   
2. Create columns with the **Day of the Week**:
   ~~~
     bike_trip$day_of_week <- wday(bike_trip$started_at, week_start = 1)
   ~~~

3. Calculate the Mean Ride Length
   - The mean ride length is 1090 seconds or 18 minutes.
   ~~~
     mean(bike_trip$ride_length)
   ~~~

4. Calculate the MAX and MIN ride lengths.
   - When performing the calculation, negative values were observed in the analysis.
   ~~~
     max(bike_trip$ride_length)
     min(bike_trip$ride_length)
   ~~~
 5. Treatment given to these negative values.
    - 272 negative values were observed:
      ~~~
        sum(bike_trip$ride_length < 0, na.rm = TRUE)
      ~~~
    - Considering that only 272 rows out of a total of 5.7 million had this issue, I decided to delete them, assuming it was just some insertion error.
      ~~~
        bike_trip <- subset(bike_trip, ride_length >= 0)
      ~~~
  6. Calculating the most frequent day
     - As a result we have the number 6, that represents **Friday**.
     ~~~
       bike_trip %>%
          count(day_of_week) %>%
          arrange(desc(n)) %>%
          slice(1) %>%
          pull(day_of_week)
     ~~~
7. Checking the distribution by day

      | Day of Week | Total |
      |-------------|-------|
      |   Friday    | 883,530 |
      | Wednesday | 860,168 |
      | Thursday | 843,489 |
      | Tuesday | 835,591 |
      | Monday | 822,954 |
      | Saturday | 744,497 |
      | Sunday | 729,376 |

     ~~~
       bike_trip %>%
          group_by(day_of_week) %>%
          summarise(total = n()) %>%
          arrange(desc(total))
     ~~~
8. Calculate the average ride_length by members and casual riders
      | Type of Member | Average (secs) | Average (min) |
      |-------------|-------|-------|
      |   Casual    | 1694 secs | 28 minutes |
      | Member | 751 secs | 12 minutes |

     ~~~
       bike_trip %>% 
          group_by(member_casual) %>% 
          summarize(media = mean(ride_length))
     ~~~

 9. Calculating the average ride length by user and day of week
     
      |day_of_week | casual (minutes) | member (minutes)|
      |-----|------|------|       
      |Sunday| 27 | 11 |
      |Monday| 25 | 12 |
      |Tuesday| 24 | 11 |
      |Wednesday| 24 | 12 |
      |Thursday| 27 | 12 |
      |Friday| 32 | 13 |
      |Saturday| 32 | 13 |

    ~~~
      bike_trip %>%
        group_by(day_of_week, member_casual) %>%
        summarize(Average_ride_length = mean(ride_length) / 60) %>%  # Convert from seconds to minutes
        pivot_wider(names_from = member_casual, values_from = Average_ride_length)
    ~~~

10. Calculate the number of rides by user and day of week

      |day_of_week| casual |member|
      |-----|------|------|
      |Sunday| 234818| 494558|
      |Monday| 246211| 576743|
      |Tuesday| 249153| 586438|
      |Wednesday| 270596| 589572|
      |Thursday| 311907| 531582|
      |Friday| 410684| 472846|
      |Saturday| 335668| 408829|
    ~~~
      bike_trip %>%
        group_by(day_of_week, member_casual) %>%
        summarize(Count_of_rides = n()) %>%
        pivot_wider(names_from = member_casual, values_from = Count_of_rides)
    ~~~

11. The difference in 'ride length' between the two types of users

<p align="center">
<img width="1080" alt="Capture" src="https://github.com/alexandre-ferreira-1986/Google_Data_Analytics_Capstone/blob/main/images/Average_by_user.png">
</p>

12. The difference by type of user and day of week

<p align="center">
<img width="1080" alt="Capture" src="https://github.com/alexandre-ferreira-1986/Google_Data_Analytics_Capstone/blob/main/images/Lin_num_ride.png">
</p>


## Act Phase:
#### Key takeaways: 

Based on the findings the team and business can apply these insights in several ways::

**1. Targeted Marketing Strategies:** Use the insight about casual riders' longer average ride lengths to develop targeted marketing campaigns focused on leisure and exploration aspects of biking.

**2. Membership Conversion:** Implement strategies to convert casual riders into members by emphasizing the benefits of membership for frequent riders, possibly through loyalty programs or discounts.

**3. Operational Planning:** Adjust bike availability and station services based on the usage patterns throughout the week to efficiently cater to the peak usage times of both member types.

## Conclusions

- Casual riders and members exhibit distinct patterns in their bike usage.
- Casual riders tend to have longer rides on average, possibly for leisure, while members show more consistent and frequent usage, indicative of regular commuting or routine use.
- Understanding these differences is crucial for Cyclistic in tailoring their services and marketing strategies to convert casual riders into members and to cater to the distinct needs of both groups.
