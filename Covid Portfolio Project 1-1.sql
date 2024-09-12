SELECT *
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER by 3,4


-- SELECT *
-- FROM dbo.CovidVaccinations
-- ORDER by 3,4

-- Select Data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER by 1,2

-- Update 0 in total_cases and total_deaths to NULL
UPDATE dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0


-- Looking at Total Cases vs. Total Deaths
-- Show likelihood of dying if you contract covid in a certain country
SELECT Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE [location] LIKE '%China%'
ORDER by 1,2

-- Looking at Total cases vs. Population
-- Show what percentage of population got Covid
SELECT Location, date, population,total_cases, (total_cases/ population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%China%'
ORDER by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/ population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%China%'
WHERE continent is NOT NULL
GROUP BY Location, population
ORDER by PercentPopulationInfected DESC

-- Show Countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%China%'
WHERE continent is NOT NULL
GROUP BY Location
ORDER by TotalDeathCount DESC

-- Let's break things down by continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%China%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC

-- Show continents with the highest deat count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%China%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER by TotalDeathCount DESC


-- Update 0 in new_deaths and new_cases to NULL
UPDATE dbo.CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = 0

UPDATE dbo.CovidDeaths
SET new_cases = null
WHERE new_cases = 0

-- Global Numbers
SELECT  Sum(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/ SUM(new_cases)*100 as DeathPercentage
-- , (total_cases/ population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
-- WHERE [location] LIKE '%state%' and 
where continent is NOT NULL
-- GROUP BY date
ORDER by 1,2



-- Use CovidVaccinations Table
-- Join two tables
-- Looking Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
ORDER by 2,3

-- Use CTE
WITH PopulationvsVaccincation (continent, Location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
    SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
        FROM dbo.CovidDeaths dea
        JOIN dbo.CovidVaccinations vac
        ON dea.location = vac.location
        and dea.date = vac.date
        where dea.continent is not NULL
        -- ORDER by 2,3
)
Select *, (CAST(RollingPeopleVaccinated as float)/ CAST(population as float))*100
FROM PopulationvsVaccincation

-- TEMP Table

Drop TABLE if EXISTS #PercentPopulationVaccinated

Create Table  #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccination NUMERIC,
    RollingPeopleVaccinated NUMERIC

)

Insert into #PercentPopulationVaccinated
  SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
        FROM dbo.CovidDeaths dea
        JOIN dbo.CovidVaccinations vac
        ON dea.location = vac.location
        and dea.date = vac.date
        where dea.continent is not NULL

Select *, (RollingPeopleVaccinated/ Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- ORDER by 2,3

SELECT *
FROM PercentPopulationVaccinated