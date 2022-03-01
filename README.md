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
For the sake of simplicity, I have centralized all of the data into a Relational Database that is connected using MSSQL. This allowed me to easily manage the entirety of the files and make relevant queries, as the CSV files can be transformed into tables which I have linked by joining common attributes. Note that the server for the mentioned Database is *localhost*.
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

--Add sleep records into daily_activity
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
temp1.Id, temp1.date_new, temp1.time_new, 
temp1.Calories, temp2.TotalIntensity, temp2.AverageIntensity, temp3.StepTotal
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
* Number of unique users represented by the “Id” column. There were 24 unique users who provided data for their 'daily_sleep' health metrics, 8 unique users for their 'weight_loginfo' health metrics and 33 unique users for the rest. Based on this very low sample size of 'weight_loginfo' data providers, I have made the decision to drop this data frame along with 'daily_sleep' data as part of my analysis since this won’t add much insight. I have used 'daily_activity', 'hourly_calories', 'hourly_intensities', 'hourly_steps', 'sleep_day', and 'minute_METs_narrow' data tables for my analysis, all these tables have 33 unique users input.

## Analyze
Transform the data to identify patterns and draw conclusions. As determined by the Process step, I have a variety of data tables that measures different fitness parameters (steps, calories, distance, sleep, activity, etc) in both daily and hourly time frames. However, for organizational consistency as well as ease and simplicity, I will perform analysis on the data tables by whether observations are provided at a daily or hourly intervals. This is made possible because the “Id” column is a shared key that corresponds between each of the data tables.

```SQL
--Time spent on activity per day
Select Distinct Id, SUM(SedentaryMinutes) as sedentary_mins,
SUM(LightlyActiveMinutes) as lightly_active_mins,
SUM(FairlyActiveMinutes) as fairly_active_mins, 
SUM(VeryActiveMinutes) as very_active_mins
From daily_activity
where total_time_in_bed IS NOT NULL
Group by Id
```

![Dashboard 1 (2)](https://user-images.githubusercontent.com/96917306/156193153-24d0a864-da4b-44f1-9d4e-02b389650d3d.png)

```SQL
--Daily Average analysis
Select AVG(TotalSteps) as avg_steps,
AVG(TotalDistance) as avg_distance,
AVG(Calories) as avg_calories,
day_of_week
From daily_activity
Group By  day_of_week
```
![image](https://user-images.githubusercontent.com/96917306/156217384-e82a3211-dfe4-41bf-9e0f-5028cd991152.png)
```SQL
--Daily Sum Analysis - No trends/patterns found
Select SUM(TotalSteps) as total_steps,
SUM(TotalDistance) as total_distance,
SUM(Calories) as total_calories,
day_of_week
From daily_activity
Group By  day_of_week
```
![image](https://user-images.githubusercontent.com/96917306/156217758-ed709107-1330-4abb-83a7-d817050d2afc.png)

### Activity duration and Calories burned relation
```SQL
--Activities and colories comparison
Select Id,
SUM(TotalSteps) as total_steps,
SUM(VeryActiveMinutes) as total_very_active_mins,
Sum(FairlyActiveMinutes) as total_fairly_active_mins,
SUM(LightlyActiveMinutes) as total_lightly_active_mins,
SUM(Calories) as total_calories
From daily_activity
Group By Id
```
![image](https://user-images.githubusercontent.com/96917306/156218718-1e41bf61-fc99-4ff4-965e-ae6e28c216fa.png)

![image](https://github.com/sayantanbagchi/Bellabeat-Case-Study/blob/3d1ea386e66a4961c7a9ef5fec7b9349c5a90932/Visualizations/Fitbit%20dashboard.png)


* Strong correlation between activity intense time and calories burned
* From the graph above, we can see that the most desired time people are active throughout the day is between 7:00 AM - 8:00PM
#### Key Findings:

* The R-Squared value for Low Active graph is 0.0118
* The R-Squared value for Fairly Active graph is 0.0391
* The R-Squared value for Very Active graph is 0.3865

There is a strong correlation between Very Active minutes and the amount of calories burned. The r-squared value seems to rise as the intensity and the duration is the activity increases. Thus by inferring to the r-squared values of the respective trend lines of the graphs, we can conclude that the higher the intensity and the duration of the activity, the more calories is burned.

### Sleep and Calories Comparison

```SQL
--Average Sleep Time per user
SELECT Id, Avg(TotalMinutesAsleep)/60 as avg_sleep_time_hour,
Avg(TotalTimeInBed)/60 as avg_time_bed_hour,
AVG(TotalTimeInBed - TotalMinutesAsleep) as wasted_bed_time_min
FROM sleep_day
Group by Id
```
![image](https://user-images.githubusercontent.com/96917306/156220169-f18ab54d-b5d3-4f30-a67d-82a54c594bbf.png)

```SQL
--Sleep and calories comparison	
Select temp1.Id, SUM(TotalMinutesAsleep) as total_sleep_min,
SUM(TotalTimeInBed) as total_time_inbed_min,
SUM(Calories) as calories
From daily_activity as temp1
Inner Join sleep_day as temp2
ON temp1.Id = temp2.Id and temp1.ActivityDate = temp2.SleepDay
Group By temp1.Id
```
![image](https://user-images.githubusercontent.com/96917306/156220333-c98a4ef4-debf-4442-83cc-5a8dab489cea.png)

![image](https://github.com/sayantanbagchi/Bellabeat-Case-Study/blob/4d66e74e147d47a0258b7319ee998c9d53865e5d/Visualizations/sleep_calories.png)

#### Key Findings:

* The R-Squared value is 0.8727
* Strong positive corellation between amount of sleep and calories burned.

Higher duration of sleep is associated with higher amount of calories burned. An adequate duration and good quality of sleep constitutes to higher calories burned during the sleeping process. However sleeping more than the required range doesn't seem to burn more calories and in fact causes the opposite to occur, which is burn fewer calories.

#### METs and Average Calories Burned:

**What is METs?**
The metabolic equivalent of task (MET) is the objective measure of the ratio of the rate at which a person expends energy, relative to the mass of that person, while performing some specific physical activity compared to a reference, set by convention at 3.5 mL of oxygen per kilogram per minute, which is roughly equivalent to the energy expended when sitting quietly.
MET: The ratio of the work metabolic rate to the resting metabolic rate. One MET is defined as 1 kcal/kg/hour and is roughly equivalent to the energy cost of sitting quietly. A MET also is defined as oxygen uptake in ml/kg/min with one MET equal to the oxygen cost of sitting quietly, equivalent to 3.5 ml/kg/min. The MET concept was primarily designed to be used in epidemiological surveys, where survey respondents answer the amount of time they spend for specific physical activities. MET is used to provide general medical thresholds and guidelines to a population. A MET is the ratio of the rate of energy expended during an activity to the rate of energy expended at rest. For example, 1 MET is the rate of energy expenditure while at rest. A 4 MET activity expends 4 times the energy used by the body at rest. If a person does a 4 MET activity for 30 minutes, he or she has done 4 x 30 = 120 MET-minutes (or 2.0 MET-hours) of physical activity. A person could also achieve 120 MET-minutes by doing an 8 MET activity for 15 minutes.

To calculate the amount of calories burned per minute, we can use the formula:

Calories burned per minute = (METs x 3.5 x (your body weight in Kg)) / 200

![image](https://user-images.githubusercontent.com/96917306/156231398-7ef138ae-f2d5-4d9e-badc-3144dbd50571.png)

* source: [Wikipedia](https://en.wikipedia.org/wiki/Metabolic_equivalent_of_task)

```SQL
--average met per day per user, and compare with the calories burned
Select Distinct temp1.Id, temp1.date_new, sum(temp1.METs) as sum_mets, temp2.Calories
From minute_METs_narrow as temp1
inner join daily_activity as temp2
on temp1.Id = temp2.Id and temp1.date_new = temp2.date_new
Group By temp1.Id, temp1.date_new, temp2.Calories
Order by date_new
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
```

![image](https://user-images.githubusercontent.com/96917306/156221688-ec812e40-ea5c-4f08-afa7-8881199a27c7.png)

*there is total 934 rows, for better understanding I am attaching only first 10 rows*

![image](https://github.com/sayantanbagchi/Bellabeat-Case-Study/blob/b6728ca48f518eb15cacb820f02b3abd74cf6605/Visualizations/mets_calories.png)

Key Findings:

* The R-Squared value is 0.5504
* Strong positive corellation between METs and average calories burned.

The amount of calories burned for every user is highly dependent on their MET values they spend every day. This can be seen by the high r-squared value suggesting that the trend line has strong relation with the data points.

## Conclusion

After performing the collection, transformation, cleaning, organisation and analysis of the given datasets, we have enough factual evidence to suggest answers to the business-related questions that were asked.

We can infer that the duration and the level of intensity of the activities performed are greatly in dependence to the amount of calories burned. METs provide a great insight on the intensity of activities performed and the amount of calories burned per minute. While most of the consumers attain adequate amounts of sleep, it is noticed that a small fraction of the users either oversleep or undersleep. Consumers are also more likely to perform low-high intensity activities in the range of 7:00 AM - 8:00PM throughout the day.

In order to design new marketing strategies to better focus on unlocking new growth oppurtunities and develop the business, we have to refer to the analysis provided above and keep those facts in mind. The recommendations I would provide to help solve this business-related scenario is shown below.

Top Recommendations to Marketing Strategists:

* Highlight the MET tracking feature on the smart devices as a marketing strategy and create awareness on MET values. For it allows users to track their level of intensity of activities and provide a real time insight on how much calories they burn every minute.
* Consumers seem to spend most of their time inactive and live a sedentary lifestyle. Notifying users through smart device notifications during the most popular time for performing activities which is between 7:00 AM - 8:00PM can remind people to exercise and live a more active lifestyle.
* Provide app notification for users to remind them to get sufficient sleep every day and implement new sleep measurement features or products such as tracking Rapid Eye Movement (REM) sleep.
* Consider setting daily/weekly calorie challenges and award points to users based on the top performers. Where the points can be accumulated and redeemed as a discount for their next product purchase.

### 									Thank You
