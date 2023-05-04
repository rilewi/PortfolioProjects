--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths in USA

SELECT Location, date, total_cases, total_deaths, 
       CAST(total_deaths AS float)/CAST(total_cases AS float)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population

SELECT Location, date, total_cases, Population, 
       CAST(total_cases AS float)/CAST(population AS float)*100 as Cases_to_Population_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
		CAST(MAX(total_cases) AS float)/CAST(population AS float) *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--Showing Countries' Death count by Continent

SELECT location, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT location, CAST(population AS float)/CAST(MAX(total_deaths) AS bigint) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null AND location not like '%income%'
GROUP BY location, population
ORDER BY HighestDeathCount DESC


--Global Numbers
SELECT 
       SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
       CASE 
         WHEN SUM(new_cases) = 0 THEN NULL 
         ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 
       END AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs. Vaccinations using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPplVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPplVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL
)
SELECT *, (RollingPplVaccinated / population)*100
FROM PopvsVac
ORDER BY 2,3


-- Looking at Total Population vs. Vaccinations using temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPplVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL

SELECT *, (RollingPplVaccinated/population)*100 AS Percent_Pop_Vaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPplVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated