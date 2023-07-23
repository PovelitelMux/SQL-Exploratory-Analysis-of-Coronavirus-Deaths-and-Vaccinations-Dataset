# SQL-Exploratory-Analysis-of-Coronavirus-Deaths-and-Vaccinations-Dataset
Includes PostgreSQL queries to explore Coronavirus (COVID-19) Deaths dataset

The dataset is available at https://ourworldindata.org/covid-deaths.
Then dataset is separated into two CSV files: 
- 'Deaths.csv' - data related to COVID-19 deaths
- 'Vaccinations.csv' - data related to COVID-19 vaccinations

Datasets in the CSV files include the period from Jan 8, 2020 till Jul 19, 2023.

'Covid 19 Data Exploration.sql' file contains the following queries:

1. Total cases and total deaths over time in Ukraine (see following PNG files: '01-1-graph...' and '01-2-graph...').
2. Total cases and total deaths over continent and continent population (see following PNG files: from '02-1-graph...' to '02-4-graph...').
3. Total cases versus total deaths in Europe countries. Data show the likelihood of dying if a person contract COVID-19 in Europe countries (see the following PNG files: '03-1-graph...' and '03-2-graph...').
4. Total cases and deaths over time. Data show the percentage of deaths over time (see the following PNG file: '04-graph...').
5. Countries with the highest infection rate compared to the population.
6. Top 10 countries with the highest deaths to population ratio (see the following PNG file: '06-graph...').
7. Global death percentage.
8. Total population and vaccinations per population over time (see the following PNG file: '08-graph...').
9. CTE used to perform calculations on the percentage of vaccinated people in Ukraine over time (see the following PNG file: '09-graph...').
10. New vaccinations in Ukraine over time (see the following PNG file: '10-graph...').
11. Temporary table used to perform calculations.
12. View created to store data for later visualizations.
