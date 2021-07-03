SELECT *
FROM PortfolioProject1..covid_deaths
-- WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in india
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject1..covid_deaths
WHERE Location = 'India'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
--WHERE Location = 'India'
ORDER BY 1,2

-- Looking at countries with infection rates compared to populations

SELECT Location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
--WHERE Location = 'India'
GROUP BY Location, Population
ORDER BY infection_rate DESC

-- Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
--WHERE Location = 'India'
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- Let's break things down by continent


-- Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject1..covid_deaths
WHERE continent IS NOT NULL
--WHERE Location = 'India'
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject1..covid_deaths
-- WHERE Location = 'India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--use CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, rolling_people_vaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


-- creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM PortfolioProject1..covid_deaths dea
JOIN PortfolioProject1..covid_vaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

