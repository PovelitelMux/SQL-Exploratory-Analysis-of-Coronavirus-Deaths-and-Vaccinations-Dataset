/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
-- 0. Tables creation

-- Table: public.deaths

-- DROP TABLE IF EXISTS public.deaths;

CREATE TABLE IF NOT EXISTS public.deaths
(
    iso_code character varying(10) COLLATE pg_catalog."default",
    continent character varying(20) COLLATE pg_catalog."default",
    location character varying(50) COLLATE pg_catalog."default",
    date date,
    total_cases integer,
    new_cases integer,
    new_cases_smoothed real,
    total_deaths integer,
    new_deaths integer,
    new_deaths_smoothed real,
    total_cases_per_million real,
    new_cases_per_million real,
    total_deaths_per_million real,
    new_deaths_per_million real,
    new_deaths_smoothed_per_million real,
    reproduction_rate real,
    icu_patients integer,
    icu_patients_per_million real,
    hosp_patients integer,
    hosp_patients_per_million real,
    weekly_icu_admissions real,
    weekly_icu_admissions_per_million real,
    weekly_hosp_admissions real,
    weekly_hosp_admissions_per_million real,
    population numeric
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.deaths
    OWNER to postgres;

-- Table: public.vaccinations

-- DROP TABLE IF EXISTS public.vaccinations;

CREATE TABLE IF NOT EXISTS public.vaccinations
(
    iso_code character varying(10) COLLATE pg_catalog."default",
    continent character varying(20) COLLATE pg_catalog."default",
    location character varying(50) COLLATE pg_catalog."default",
    date date,
    new_tests bigint,
    total_tests bigint,
    total_tests_per_thousand real,
    new_tests_per_thousand real,
    new_tests_smoothed real,
    new_tests_smoothed_per_thousand real,
    positive_rate real,
    tests_per_case real,
    total_vaccinations bigint,
    people_vaccinated bigint,
    people_fully_vaccinated bigint,
    new_vaccinations bigint,
    new_vaccinations_smoothed real,
    total_vaccinations_per_hundred real,
    people_vaccinated_per_hundred real,
    people_fully_vaccinated_per_hundred real,
    new_vaccinations_smoothed_per_million real,
    stringency_index real,
    population_density real,
    median_age real,
    aged_65_older real,
    aged_70_older real,
    gdp_per_capita real,
    extreme_poverty real,
    cardiovasc_death_rate real,
    diabetes_prevalence real,
    female_smokers real,
    male_smokers real,
    handwashing_facilities real,
    hospital_beds_per_thousand real,
    life_expectancy real,
    human_development_index real
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.vaccinations
    OWNER to postgres;

-- Exploring Analysis

-- 1. Select Data that we are going to be starting with 
-- Shows total cases and total deaths over time in Ukraine

SELECT 	location
		, date
		, total_cases
		, new_cases
		, total_deaths
FROM deaths
WHERE continent IS NOT null
AND location LIKE '%Ukraine%'
AND total_cases IS NOT null
ORDER BY 2;


-- 2. Total Cases and Total Deaths over Continent and Continenet Population
SELECT 	continent
		, SUM(DISTINCT population) AS population
		, SUM(new_cases) AS all_cases
		, SUM(new_deaths) AS all_deaths
		, (SUM(new_deaths)::real/SUM(new_cases))*100 AS death_to_cases_ratio
		, (SUM(new_deaths)::real/SUM(population))*100 AS death_to_population_ratio
FROM deaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY 1 ASC;


-- 3. Total Cases vs Total Deaths in Europe countries
-- Shows likelihood of dying if you contract covid in Europe contries

SELECT 	location
		, SUM(DISTINCT population) AS population
		, SUM(new_cases) AS all_cases
		, SUM(new_deaths) AS all_deaths
		, (SUM(new_deaths)::real/SUM(new_cases))*100 AS death_to_cases_ratio
		, (SUM(new_deaths)::real/SUM(population))*100 AS death_to_population_ratio
FROM deaths
WHERE continent LIKE 'Europe'
AND continent IS NOT null
AND new_cases IS NOT null
GROUP BY location
ORDER BY 6 DESC;


-- 4. Total Cases and Deaths over Time
-- Shows what percentage of deaths over time

SELECT 	date
		, SUM(new_cases) AS all_cases
		, SUM(new_deaths) AS all_deaths
		, LOG(SUM(new_deaths)::real/SUM(new_cases)) AS logarithm_of_death_to_cases_ratio
FROM deaths
WHERE new_cases != 0
AND new_deaths != 0
GROUP BY date
ORDER BY 1;


-- 5. Countries with Highest Infection Rate compared to Population

SELECT 	location
		, population
		, MAX(total_cases::real) AS Highest_Infection_Count
		, MAX((total_cases::real/population))*100 AS Percent_Population_Infected
FROM deaths
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC;


-- 6. Top 10 Countries with Highest Deaths per Population Ratio

SELECT 	location
		, SUM(DISTINCT population) AS population
		, SUM(new_deaths) AS all_deaths
		, (SUM(new_deaths)::real/SUM(population))*1000000 AS deaths_per_1_million_population
FROM deaths
WHERE new_deaths IS NOT null
GROUP BY location
ORDER BY deaths_per_1_million_population DESC
LIMIT 10;


-- 7. GLOBAL NUMBERS - Global death percentage

SELECT 	SUM(new_cases) AS total_cases
		, SUM(CAST(new_deaths AS int)) AS total_deaths
		, SUM(CAST(new_deaths AS int))::real/SUM(New_Cases)*100 AS DeathPercentage
FROM deaths
WHERE continent IS NOT null 
ORDER BY 1,2;

-- 8. Total Population vs Vaccinations

SELECT 	dea.date
		, SUM(DISTINCT dea.population) AS total_population
		, SUM(dea.new_deaths) AS all_deaths
		, LOG(SUM(dea.new_deaths)::real/SUM(DISTINCT dea.population)*1000000) AS logarithm_of_deaths_per_1_million_people
		, CASE 
			WHEN SUM(vac.new_vaccinations)::real/SUM(DISTINCT dea.population)*1000 = 0
			THEN 0
			ELSE LOG(SUM(vac.new_vaccinations)::real/SUM(DISTINCT dea.population)*1000)
			END AS logarithm_of_vaccinations_per_1000_people
FROM deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE new_cases != 0
AND new_deaths != 0
GROUP BY dea.date
ORDER BY 1;


-- 9. Using Common Table Expression - CTE to perform Calculation on Percentage of Vaccinated in Ukraine over time 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
From deaths AS dea
Join vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT 	* 
		, (RollingPeopleVaccinated::real/Population)*100 AS Percentage_of_vaccinated
FROM PopvsVac
WHERE RollingPeopleVaccinated IS NOT null
AND location LIKE '%Ukraine%';

-- 10. New vaccinations in Ukraine over time
SELECT 	dea.continent
		, dea.location
		, dea.date
		, vac.new_vaccinations
		, vac.total_vaccinations
FROM deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
AND vac.new_vaccinations IS NOT null
AND dea.location LIKE '%Ukraine%'
ORDER BY 3;


-- 11. Using Temp Table to perform Calculation

DROP TABLE IF EXISTS public.COVID_summary;

CREATE TABLE IF NOT EXISTS public.COVID_summary
(
	Continent character varying(255),
	Location character varying(255),
	Date date,
	Population numeric,
	New_cases numeric,
	New_deaths numeric,
	New_vaccinations integer,
	RollingPeopleVaccinated real
);

INSERT INTO COVID_summary
SELECT 	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, dea.new_cases
		, dea.new_deaths
		, vac.new_vaccinations
		, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

SELECT *, (RollingPeopleVaccinated/Population)*100 AS vaccination_percentage
FROM COVID_summary;



-- 12. Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated_view AS
SELECT 	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM deaths AS dea
JOIN vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null;

SELECT *
FROM PercentPopulationVaccinated_view;

DROP VIEW PercentPopulationVaccinated_view;

