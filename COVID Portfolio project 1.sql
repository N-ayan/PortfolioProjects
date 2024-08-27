SELECT *
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProjects..CovidVaccination
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 1, 2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProjects..CovidDeaths
where location like 'india'
and  continent is not null
ORDER BY 1, 2

--Total Cases vs Population
-- shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as Infected_Population
FROM PortfolioProjects..CovidDeaths
-- where location like 'india'
where continent is not null
ORDER BY 1, 2


-- Countries with highest infection rate to compared  to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as
	Percent_Population_Infected
FROM PortfolioProjects..CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Countries with the highest death count per population

SELECT location, population, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Total_Death_Count DESC

-- breaking things down by continent


-- Continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
		SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
		SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER 
(PARTITION BY death.Location ORDER BY death.location, death.date) as RoolingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccination vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
ORDER BY 2, 3

-- USING CTE
WITH PopVsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER 
(PARTITION BY death.Location ORDER BY death.location, death.date) as RoolingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccination vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP TABLE (SAME OUTPUT AS CTE) JUST ANOTHER APPROACH

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER 
(PARTITION BY death.Location ORDER BY death.location, death.date) as RoolingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccination vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
--WHERE death.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPeopleVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(INT, vaccine.new_vaccinations)) OVER 
(PARTITION BY death.Location ORDER BY death.location, death.date) as RoolingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths death
JOIN PortfolioProjects..CovidVaccination vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated