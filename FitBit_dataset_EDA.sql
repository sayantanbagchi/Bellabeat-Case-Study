--Time spent on activity per day
Select Distinct Id, SUM(SedentaryMinutes) as sedentary_mins,
SUM(LightlyActiveMinutes) as lightly_active_mins,
SUM(FairlyActiveMinutes) as fairly_active_mins, 
SUM(VeryActiveMinutes) as very_active_mins
From daily_activity
where total_time_in_bed IS NOT NULL
Group by Id


--Daily Average analysis - No trends/patterns found
Select AVG(TotalSteps) as avg_steps,
AVG(TotalDistance) as avg_distance,
AVG(Calories) as avg_calories,
day_of_week
From daily_activity
Group By  day_of_week


--Daily Sum Analysis - No trends/patterns found
Select SUM(TotalSteps) as total_steps,
SUM(TotalDistance) as total_distance,
SUM(Calories) as total_calories,
day_of_week
From daily_activity
Group By  day_of_week


--Sleep and calories comparison	

Select temp1.Id, SUM(TotalMinutesAsleep) as total_sleep_min,
SUM(TotalTimeInBed) as total_time_inbed_min,
SUM(Calories) as calories
From daily_activity as temp1
Inner Join sleep_day as temp2
ON temp1.Id = temp2.Id and temp1.ActivityDate = temp2.SleepDay
Group By temp1.Id


--Average Sleep Time per user
SELECT Id, Avg(TotalMinutesAsleep)/60 as avg_sleep_time_hour,
Avg(TotalTimeInBed)/60 as avg_time_bed_hour,
AVG(TotalTimeInBed - TotalMinutesAsleep) as wasted_bed_time_min
FROM sleep_day
Group by Id


--Activities and colories comparison
Select Id,
SUM(TotalSteps) as total_steps,
SUM(VeryActiveMinutes) as total_very_active_mins,
Sum(FairlyActiveMinutes) as total_fairly_active_mins,
SUM(LightlyActiveMinutes) as total_lightly_active_mins,
SUM(Calories) as total_calories
From daily_activity
Group By Id


--average met per day per user, and compare with the calories burned
Select Distinct temp1.Id, temp1.date_new, sum(temp1.METs) as sum_mets, temp2.Calories
From minute_METs_narrow as temp1
inner join daily_activity as temp2
on temp1.Id = temp2.Id and temp1.date_new = temp2.date_new
Group By temp1.Id, temp1.date_new, temp2.Calories
Order by date_new
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
