-------------------------------------------------------------
--COVID-19 Exploratory Analysis
-------------------------------------------------------------

--SELECT *
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--ORDER BY 3,4

--SELECT *
--FROM COVID19..CovidVaccinations$
--WHERE continent is not null
--ORDER BY 3,4

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--select the data that will be used
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--and continent is not null
--ORDER BY 1,2

--Total Cases vs Total Deaths
--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage --likelihood of dying after contracting COVID19 in the United States
--FROM COVID19..CovidDeaths$
--WHERE location like '%states%'
--and continent is not null
--ORDER BY 1,2

--Total Cases vs Population
--SELECT location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected --percentage of the United States population that has COVID19
--FROM COVID19..CovidDeaths$
--WHERE location like '%states%'
--and continent is not null
--ORDER BY 1,2

--Countries with Highest Infection Rates compared to Population
--SELECT location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected --percentage of world populations that has COVID19
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--GROUP BY location, population
--ORDER BY 4 desc

--Locations with Highest Total Death Counts
--SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount 
--FROM COVID19..CovidDeaths$
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc

--Continents with Highest Total Death Counts (not as accurate, but will use for drill down visualizations; ex. canada is missing from North America)
--SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount 
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount desc

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--Global Numbers
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--SELECT SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 GlobalDeathPercentage
--FROM COVID19..CovidDeaths$
--WHERE continent is not null
--ORDER BY 1,2

--Percentage of Vaccinated People per Population
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
----,(RollingPeopleVaccinated/population)*100
--FROM COVID19..CovidDeaths$ dea
--Join COVID19..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--Use CTE (needed since a calculation is being ran on the derived column RollingPeopleVaccinated)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) --number of columns must match the number of columns in the selection
--as
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--FROM COVID19..CovidDeaths$ dea
--Join COVID19..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null
--)
--SELECT *, (RollingPeopleVaccinated/Population)*100 RollingPercentagePeopleVaccinated
--FROM PopvsVac

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--Use Temp Table
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--DROP TABLE if exists #PercentPopulationVaccinated --makes alterations to table easier
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_Vaccinations numeric,
--RollingPeopleVaccinated numeric
--)

--Insert into #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--FROM COVID19..CovidDeaths$ dea
--Join COVID19..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null

--SELECT *, (RollingPeopleVaccinated/Population)*100 PercentageRollingPeopleVaccinated
--FROM #PercentPopulationVaccinated

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--View Creation for Data Visualization
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

--DROP VIEW if exists PercentPopulationVaccinated  
--CREATE VIEW PercentPopulationVaccinated as
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--FROM COVID19.dbo.CovidDeaths$ dea
--Join COVID19.dbo.CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null

--SELECT *
--FROM PercentPopulationVaccinated