SELECT *
FROM PortfolioProjects..CovidDeaths

SELECT * 
FROM  PortfolioProjects..CovidVaccinations

-- Select the data to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

--Analyzing total cases vs total deaths
-- Shows the Likelihood of dying if you contract the disease
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS  DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%china%'
ORDER BY 1,2

--Exploring total cases vs population
-- Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS  DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with the highest infection rate per population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS  PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing countries with the highest Death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Showing countries with the highest Death count per population per continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and dea.location like '%bania%'
ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --and dea.location like '%bania%'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
CREATE TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and dea.location like '%bania%'
ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL and dea.location like '%bania%'



select * 
from PercentPopulationVaccinated