-- Overall table that we are going to be using 
SELECT * 
FROM project_portfolio..covid_deaths 
ORDER BY 3,4;

SELECT * 
FROM project_portfolio..covid_vacs 
ORDER BY 3,4;

-- Querying data that we are going to be using
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases,
	total_deaths,
	population
FROM 
	project_portfolio..covid_deaths
ORDER BY 1,2;


-- Global Cases Numbers in 2020 and 2021
SELECT
    YEAR(date) as year,
	SUM(COALESCE(new_cases, 0)) AS total_cases
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
	YEAR(date)
ORDER BY 
    1 DESC;


-- Global Death Numbers in 2020 and 2021
SELECT
    YEAR(date) as year,
	SUM(COALESCE(new_deaths, 0)) AS total_deaths
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
	YEAR(date)
ORDER BY 
    1 DESC;


-- Global Case Fatality Rate During 2020 and 2021
SELECT
	YEAR(date) AS year,
	SUM(new_deaths) AS total_deaths,
	SUM(new_cases) AS total_cases,
	ROUND(SUM(new_deaths)/SUM(new_cases)*100, 2) AS death_rate 
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY YEAR(date)
ORDER BY 
    1 ASC;


-- COVID 19 Death Rate in 2020 in Indonesia 
SELECT 
	location, 
	2020 AS year, 
	SUM(new_cases) AS total_cases_ind, 
	SUM(new_deaths) AS total_deaths_ind,
	ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS death_percentage
FROM 
	project_portfolio..covid_deaths
WHERE 
	date >= '2020-01-01' AND date < '2021-01-01' AND location LIKE '%Indonesia%'
GROUP BY location;


-- COVID 19 Cases Ratio in 2020 in Indonesia 
SELECT 
	location, 
	2020 AS year,
	population,
	SUM(new_cases) AS total_cases_ind, 
	ROUND((SUM(new_cases)/population)*100,2) AS cases_percentage
FROM 
	project_portfolio..covid_deaths
WHERE 
	date >= '2020-01-01' AND date < '2021-01-01' AND location LIKE '%Indonesia%'
GROUP BY location, population;


--Top 5 Country with Highest Total Case in 2020
SELECT TOP 5
    location, 
    2020 AS year,  
    SUM(COALESCE(new_cases, 0)) AS total_cases
FROM 
    project_portfolio..covid_deaths
WHERE 
    date >= '2020-01-01' AND date < '2021-01-01' AND continent IS NOT NULL
GROUP BY 
    location, YEAR(date)
ORDER BY 
    3 DESC;


-- Top 5 Country with Highest Infection Rate in 2020
SELECT TOP 5
    location, 
    2020 AS year, 
    population, 
    SUM(COALESCE(new_cases, 0)) AS total_cases,
	ROUND(SUM(COALESCE(new_cases, 0)/population)*100,2) AS infection_rate
FROM 
    project_portfolio..covid_deaths
WHERE 
    date >= '2020-01-01' AND date < '2021-01-01' AND CONTINENT IS NOT NULL
GROUP BY 
    location, population, YEAR(date)
ORDER BY 
    5 DESC;


--Top 5 Country with Highest Total Death in 2020
SELECT TOP 5
    location, 
    2020 AS year,  
    SUM(COALESCE(new_deaths, 0)) AS total_death
FROM 
    project_portfolio..covid_deaths
WHERE 
    date >= '2020-01-01' AND date < '2021-01-01' AND CONTINENT IS NOT NULL
GROUP BY 
    location, YEAR(date)
ORDER BY 
    3 DESC;


-- Top 5 Country with Highest Case Fatality Rate in 2020
SELECT TOP 5
    location, 
    2020 AS year,
    SUM(COALESCE(new_deaths, 0)) AS total_death,
    SUM(COALESCE(new_cases, 0)) AS total_cases, 
    ROUND((SUM(COALESCE(new_deaths, 0)) * 1.0 / NULLIF(SUM(COALESCE(new_cases, 0)), 0)) * 100, 2) AS death_rate
FROM 
    project_portfolio..covid_deaths
WHERE 
    date >= '2020-01-01' AND date < '2021-01-01'
GROUP BY 
    location
ORDER BY 
    death_rate DESC;


-- Total Cases by Continent During 2020-2021
SELECT
    continent,   
    SUM(COALESCE(new_cases, 0)) AS total_cases
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    2 DESC;


-- Total Deaths by Continent During 2020-2021
SELECT
    continent,   
    SUM(COALESCE(new_deaths, 0)) AS total_deaths
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    2 DESC;


-- Global Death Number During 2020-2021
SELECT
	YEAR(date) AS Year,
	SUM(new_deaths) AS total_deaths
FROM 
    project_portfolio..covid_deaths
WHERE 
    continent IS NOT NULL
GROUP BY YEAR(date)
ORDER BY 
    1 ASC;

-- Join with Vaccinations Table
SELECT * 
FROM project_portfolio..covid_deaths cd
	JOIN project_portfolio..covid_vacs cv
	ON cd.location = cv.location AND cd.date = cv.date;


-- Total Population vs Vaccinations
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM project_portfolio..covid_deaths cd
	JOIN project_portfolio..covid_vacs cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
	AS (
	SELECT 
		cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
	FROM project_portfolio..covid_deaths cd
		JOIN project_portfolio..covid_vacs cv
	ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL)
	-- ORDER BY 2,3
SELECT *, ROUND((rolling_people_vaccinated/Population )*100, 2) 
FROM PopvsVac


-- Country with Highest Vaccination Rate in 2020-2021
SELECT 
	cd.location,
	cd.population,
	SUM(cv.new_vaccinations) as total_vaccinated,
	ROUND((SUM(cv.new_vaccinations)/cd.population*100), 4) as vaccination_rate 
FROM 
	project_portfolio..covid_deaths cd
	JOIN project_portfolio..covid_vacs cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE 
	cd.continent IS NOT NULL
GROUP BY 
	cd.location, cd.population
HAVING 
	SUM(cv.new_vaccinations) IS NOT NULL
ORDER BY 4 DESC;


-- Temp Table
CREATE TABLE vaccination_percentage (
    location NVARCHAR(255),
    population NUMERIC(18,2),
    total_vaccinated NUMERIC(18,2),
    vaccination_rate NUMERIC(5,2)
);

INSERT INTO vaccination_percentage(location, population, total_vaccinated, vaccination_rate)
SELECT 
    cd.location,
    cd.population,
    SUM(COALESCE(cv.new_vaccinations, 0)) AS total_vaccinated,
    ROUND((SUM(COALESCE(cv.new_vaccinations, 0)) / cd.population) * 100, 2) AS vaccination_rate
FROM 
    project_portfolio..covid_deaths cd
JOIN 
    project_portfolio..covid_vacs cv
ON 
    cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL 
GROUP BY 
    cd.location, cd.population
HAVING 
    SUM(cv.new_vaccinations) > 0;


-- Selecting from temp table (Top 10 Country with Highest Vaccination Rate)
SELECT TOP 10 *
FROM 
    vaccination_percentage
WHERE vaccination_rate < 100
ORDER BY vaccination_rate DESC


-- Create View
CREATE VIEW vaccination_percentage_view AS
SELECT 
    cd.location,
    cd.population,
    SUM(COALESCE(cv.new_vaccinations, 0)) AS total_vaccinated,
    ROUND((SUM(COALESCE(cv.new_vaccinations, 0)) / cd.population) * 100, 2) AS vaccination_rate
FROM 
    project_portfolio..covid_deaths cd
JOIN 
    project_portfolio..covid_vacs cv
ON 
    cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL 
GROUP BY 
    cd.location, cd.population
HAVING 
    SUM(cv.new_vaccinations) > 0;











