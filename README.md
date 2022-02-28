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

