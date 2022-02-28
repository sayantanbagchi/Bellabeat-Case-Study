# FitBit Smart Device Analysis
```SQL

--Checking Number of Rows on dailyActivities

Select Count(*)
From [dbo].[dailyActivity_merged]


--Checking for duplicates in dailyActivity dataset

Select Id, ActivityDate, TotalSteps, Count(*)
From [dbo].[dailyActivity_merged]
group by id, ActivityDate, TotalSteps
Having Count(*) > 1


--Modify date format for better understaning in sleepDay

Update sleepDay_merged
Set SleepDay = Convert(date, SleepDay, 101)


--Modify date format for better understaning in dailyActivity

Update dailyActivity_merged
Set ActivityDate = Convert(date, ActivityDate, 101)


--Add day_0f_week column on dailyActivities

Alter Table [dbo].[dailyActivity_merged]
ADD day_of_week nvarchar(50)


--Extract datename from ActivityDate

Update dailyActivity_merged
SET day_of_week = DATENAME(DW, ActivityDate)


--Add sleep data columns on dailyActivity table

Alter Table [dbo].[dailyActivity_merged]
ADD total_mins_sleep int,
total_mins_bed int


--Add sleep records into dailyActivity table

UPDATE dailyActivity_merged
Set total_mins_sleep = t2.TotalMinutesAsleep,
total_mins_bed = t2.TotalTimeInBed 
From [dbo].[dailyActivity_merged] as t1
Full Outer Join sleepDay_merged as t2
on t1.id = t2.id and t1.ActivityDate = t2.SleepDay


--Adding specific date format to [dailyActivity_merged] table

Alter table dailyActivity_merged
Add Date_d date

Update dailyActivity_merged
Set Date_d = CONVERT( date, ActivityDate, 103 )


--Split date and time seperately for [hourlyCalories_merged] table

Alter Table [dbo].[hourlyCalories_merged]
ADD time_h int

Update [dbo].[hourlyCalories_merged]
Set time_h = DATEPART(hh, Date_d)

Update [dbo].[hourlyCalories_merged]
Set Date_d = SUBSTRING(Date_d, 1, 9)


--Split date and time seperately for [hourlyIntensities_merged]

Alter Table [dbo].[hourlyIntensities_merged]
ADD time_h int

Update [dbo].[hourlyIntensities_merged]
Set time_h = DATEPART(hh, ActivityHour)

Update [dbo].[hourlyIntensities_merged]
Set ActivityHour = SUBSTRING(ActivityHour, 1, 9)


--Split date and time seperately for [hourlySteps_merged]

Alter Table [dbo].[hourlySteps_merged]
ADD time_h int

Update [dbo].[hourlySteps_merged]
Set time_h = DATEPART(hh, Date_d)

Update [dbo].[hourlySteps_merged]
Set Date_d = SUBSTRING(Date_d, 1, 9)


--Split date and time seperately for [minuteMETsNarrow_merged]

Alter Table [dbo].[minuteMETsNarrow_merged]
ADD time_t time

Update [dbo].[minuteMETsNarrow_merged]
Set time_t = CAST(Date_d as time)

Update [dbo].[minuteMETsNarrow_merged]
Set time_t = Convert(varchar(5), time_t, 108)

Update [dbo].[minuteMETsNarrow_merged]
Set Date_d = SUBSTRING(Date_d, 1, 9)


--Create new table to merge hourlyCalories, hourlyIntensities, and hourlySteps

Create table hourly_cal_int_step_merge(
Id numeric(18,0),
Date_d nvarchar(50),
time_h int,
Calories numeric(18,0),
TotalIntensity numeric(18,0),
AverageIntensity float,
StepTotal numeric (18,0)
)


--Insert corresponsing data and merge multiple table into one table

Insert Into hourly_cal_int_step_merge (Id, Date_d, time_h, Calories, TotalIntensity, AverageIntensity, StepTotal)
(Select t1.Id, t1.Date_d, t1.time_h, t1.Calories, t2.TotalIntensity, t2.AverageIntensity, t3.StepTotal
From [dbo].[hourlyCalories_merged] as t1
Inner Join [dbo].[hourlyIntensities_merged] as t2
ON t1.Id = t2.Id and t1.Date_d = t2.ActivityHour and t1.time_h = t2.time_h
Inner Join [dbo].[hourlySteps_merged] as t3
ON t1.Id = t3.Id and t1.Date_d = t3.Date_d and t1.time_h = t3.time_h)


--Checking for duplicates

/*Select Id, time_h, Calories, TotalIntensity, AverageIntensity, StepTotal, Count(*) as duplicates
From [dbo].[hourly_cal_int_step_merge]
Group by Id, time_h, Calories, TotalIntensity, AverageIntensity, StepTotal
Having Count(*) > 1*/


--Checking for duplicates

/*Select sum(duplicates) as sum_s
from (Select Id, Date_d time_h, Calories, TotalIntensity, AverageIntensity, StepTotal, Count(*) as duplicates
From [dbo].[hourly_cal_int_step_merge]
Group by Id, Date_d, time_h, Calories, TotalIntensity, AverageIntensity, StepTotal
Having Count(*) > 1
Order by duplicates DESC) as cte*/


--Query in hh:mm time format for better understanding on MET Table 

select Id, Cast(Date_d as date) as date_d, METs, Convert(varchar(5), time_t, 108) as time_t
From [dbo].[minuteMETsNarrow_merged]


--Change date type nvarchar to date on MET table to join properly with other table

Alter table minuteMETsNarrow_merged
Add dates_d date

Update minuteMETsNarrow_merged
Set dates_d = Cast(Date_d as date)
```
