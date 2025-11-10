
# Cyclistic Bike-Share Capstone Project

## 📌 Overview
This project is part of the **Google Data Analytics Capstone Case Study**.  
Cyclistic, a bike-share program in Chicago, wants to understand how **casual riders** and **annual members** use bikes differently.  
The goal is to provide insights that help convert more casual riders into annual members.

---
Kaggle notebook link : (https://www.kaggle.com/code/harshurg/cyclistic-bike-share-project)
## 📊 Business Questions
1. How do annual members and casual riders use Cyclistic bikes differently?  
2. Why would casual riders choose to upgrade to annual memberships?  
3. How can Cyclistic use digital media to influence casual riders to become members?  

---

## 🗂 Project Structure
- **data/raw/** → Raw monthly CSV files (Jan–Apr 2021).  
- **data/processed/** → Cleaned & aggregated CSVs used for analysis.  
- **plots/** → Visualizations from R (ggplot2).  
- **reports/** → Full R Markdown report (PDF) + Presentation (PPT).  
- **scripts/** → R scripts for data cleaning & analysis.  

⚠️ Note: Due to GitHub’s 100 MB file size limit, only **sample data** is included.  
The full dataset can be re-created by running the R scripts on the original Divvy data.  

---

## ⚙️ Tools & Packages
- **R** (tidyverse, lubridate, janitor, ggplot2)  
- RStudio / Posit Cloud  
- GitHub for version control  

---

## 📈 Key Insights
- Members: frequent, shorter weekday rides (commuting).  
- Casuals: longer leisure rides, mainly weekends.  
- Seasonal increase in ridership (esp. Mar–Apr).  
- Casuals use docked bikes more, with the longest trip lengths.  

---

## ✅ Recommendations
- Promote annual memberships emphasizing cost savings.  
- Target weekend casual riders with digital ads.  
- Highlight flexibility & value of annual plans.  

---

## 📂 Files
- `Cyclistic_bike_share_report.Rmd` → Full analysis report in R Markdown.  
- `Cyclistic_bike_share_data_report.pdf` → Knitted report.  
- `Cyclistic Bike share— Member vs Annual .pptx` → Presentation.  
- `data/processed/` → Aggregated datasets for analysis.  
- `plots/` → Visual outputs used in the report.  

---

## Project Workflow (Google DA Capstone Process)
## 1️⃣ Ask

Defined business task: support marketing strategy to increase annual memberships.

Identified stakeholders: Cyclistic’s marketing team.

## 2️⃣ Prepare

Collected Divvy Trip Data (Jan–Apr 2021).

Validated data source: publicly available, real-world dataset.

Noted limitations: only a 4-month subset used for analysis.

## 3️⃣ Process

Cleaned column names (using janitor).

Converted timestamps with lubridate.

Created new features: ride length, day-of-week, month, hour.

Removed invalid rides (≤0 mins or >24 hrs).

Checked for missing values & duplicates.

## 4️⃣ Analyze

Descriptive statistics (mean, median, IQR, SD).

Hypothesis tests: t-test & Wilcoxon test.

Visualizations (ggplot2):

Ride length distribution

Rides by weekday, month, and bike type

Average ride duration trends

## 5️⃣ Share

Prepared R Markdown report (PDF).

Created presentation slides with key insights.

Summarized recommendations for Cyclistic’s marketing strategy.

## 6️⃣ Act

Insights will guide targeted marketing campaigns (focus on converting casuals to members). 
