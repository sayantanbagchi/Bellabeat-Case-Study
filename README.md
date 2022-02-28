# FitBit Smart Device Analysis
Welcome to the Bellabeat data analysis case study as a part of Google Data Analytics Specialization's capstone project.
## Introduction
Urška Sršen and Sando Mur founded Bellabeat, a high-tech company that manufactures health-focused smart products. Collecting data on activity, sleep, stress, and reproductive health has allowed Bellabeat to empower women with knowledge about their own health and habits. Since it was founded in 2013, Bellabeat has grown rapidly and quickly positioned itself as a tech-driven wellness company for women. 
### Scenario
You are a junior data analyst working on the marketing analyst team at Bellabeat, a high-tech manufacturer of health-focused products for women. Bellabeat is a successful small company, but they have the potential to become a larger player in the global smart device market. Urška Sršen, cofounder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. You have been asked to focus on one of Bellabeat’s products and analyze smart device data to gain insight into how consumers are using their smart devices. The insights you discover will then help guide marketing strategy for the company. You will present your analysis to the Bellabeat executive team along with your high-level recommendations for Bellabeat’s marketing strategy.
### Business Task
Sršen asks you to analyze smart device usage data in order to gain insight into how consumers use non-Bellabeat smart devices. She then wants you to select one Bellabeat product to apply these insights to in your presentation. 

Following three points are the questions needed to be answered by this analysis.
1. What are some trends in smart device usage?
2. How could these trends apply to Bellabeat customers?
3. How could these trends help influence Bellabeat marketing strategy?

## Prepare
To answer Bellabeat's business tasks I will be using [FitBit Fitness Tracker Data](https://www.kaggle.com/arashnic/fitbit) (CC0: Public Domain, dataset made available through [Mobius](https://www.kaggle.com/arashnic)): This Kaggle data set contains personal fitness tracker from thirty fitbit users. Thirty eligible Fitbit users consented to the submission of personal tracker data, including minute-level output for physical activity, heart rate, and sleep monitoring. It includes information about daily activity, steps, and heart rate that can be used to explore users’ habits.
#### Considerations
* Sampling bias might apply, it is unclear how participants are choosen. As participants willing to make their activity data public they might be heavier users of FitBit.
* The dataset does not provide information about gender of the users. Bellabeat is a tech-driven wellness company for women only.
* The data is from 2016, so it is outdated as fitness trackers matured a lot since then.

I have used Microsoft SQL Server Management Studio for this project to help process and analyze and for visualization I have used Tableau Public.
In order to solve this business task, only 6 of the given 18 datasets were used.

## Process 
Clean and format data to be more meaningful and clearer. In this step I have organized data by adding columns, extracting information and removing bad data and duplicates.
```SQL
-- Checking Number of Rows on daily_activity
SELECT COUNT (*)
FROM daily_activity;

-- Checking for duplicates in daily_activity
SELECT Id, ActivityDate, TotalSteps, Count(*)
FROM daily_activity
GROUP BY id, ActivityDate, TotalSteps
HAVING Count(*) > 1;

-- Modify date format for better understaning in daily_activity
Update daily_activity
Set ActivityDate = Convert(date, ActivityDate, 21);

-- Add day_0f_week column on daily_activities
Alter Table daily_activity
ADD day_of_week nvarchar(50)

--Extract datename from ActivityDate
Update daily_activity
SET day_of_week = DATENAME(DW, ActivityDate)

-- Modify date format for better understaning in sleep_day
Update sleep_day
Set SleepDay = Convert(date, SleepDay, 21)

-- Add sleep data columns on daily_activity
Alter Table daily_activity
ADD total_minutes_sleep int,
total_time_in_bed int;

--Add sleep records into dailyActivity
UPDATE daily_activity
Set total_minutes_sleep = temp2.TotalMinutesAsleep,
total_time_in_bed = temp2.TotalTimeInBed 
From daily_activity as temp1
Full Outer Join sleep_day as temp2
on temp1.id = temp2.id and temp1.ActivityDate = temp2.SleepDay;

--Adding specific date format to daily_activity
Alter table daily_activity
Add date_new date;
Update daily_activity
Set date_new = CONVERT( date, ActivityDate, 103 )

--Split date and time for hourly_calories
Alter Table hourly_calories
ADD time_new int, date_new DATE;
Update hourly_calories
Set time_new = DATEPART(hh, ActivityHour);
Update hourly_calories
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for hourly_intensities
Alter Table hourly_intensities
ADD time_new int, date_new DATE;
Update hourly_intensities
Set time_new = DATEPART(hh, ActivityHour);
Update hourly_intensities
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for hourly_steps
Alter Table hourly_steps
ADD time_new int, date_new DATE;
Update hourly_steps
Set time_new = DATEPART(hh, ActivityHour);
Update hourly_steps
Set date_new = CAST(ActivityHour AS DATE);

--Split date and time seperately for minute_METs_narrow
Alter Table minute_METs_narrow
ADD time_new TIME, date_new DATE
Update minute_METs_narrow
Set time_new = CAST(ActivityMinute as time)
Update minute_METs_narrow
Set time_new = Convert(varchar(5), time_new, 108)
Update minute_METs_narrow
Set date_new = CAST(ActivityMinute AS DATE);

--Create new table to merge hourly_calories, hourly_intensities, and hourly_steps
Create table hourly_data_merge(
id numeric(18,0),
date_new nvarchar(50),
time_new int,
calories numeric(18,0),
total_intensity numeric(18,0),
average_intensity float,
step_total numeric (18,0)
);
--Insert corresponsing data and merge multiple table into one table
Insert Into hourly_data_merge(
id, date_new, time_new, calories, total_intensity, average_intensity, step_total)
(SELECT 
temp1.Id, temp1.date_new, temp1.time_new, temp1.Calories, temp2.TotalIntensity, temp2.AverageIntensity, temp3.StepTotal
From hourly_calories AS temp1
Inner Join hourly_intensities AS temp2
ON temp1.Id = temp2.Id and temp1.date_new = temp2.date_new and temp1.time_new = temp2.time_new 
Inner Join hourly_steps AS temp3
ON temp1.Id = temp3.Id and temp1.date_new = temp3.date_new and temp1.time_new = temp3.time_new);

--Checking for duplicates
SELECT id, time_new, calories, total_intensity, average_intensity, step_total, Count(*) as duplicates
	  FROM hourly_data_merge
	  GROUP BY id, time_new, calories, total_intensity, average_intensity, step_total
	  HAVING Count(*) > 1;
SELECT sum(duplicates) as total_duplicates
FROM (SELECT id, time_new, calories, total_intensity, average_intensity, step_total, Count(*) as duplicates
	  FROM hourly_data_merge
	  GROUP BY id, time_new, calories, total_intensity, average_intensity, step_total
	  HAVING Count(*) > 1) AS temp;
```
