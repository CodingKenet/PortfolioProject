--SELECT * FROM ProjectPortfolio..CovidDeaths
SELECT Location, date, total_cases, new_cases, total_deaths, population FROM ProjectPortfolio..CovidDeaths ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in Costa Rica
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage FROM ProjectPortfolio..CovidDeaths
WHERE location like '%Costa Rica%' ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT Location, date, total_cases, Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected FROM ProjectPortfolio..CovidDeaths
WHERE location like '%Costa Rica%' ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  FROM ProjectPortfolio..CovidDeaths
GROUP BY Location,Population ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null GROUP BY Location ORDER BY TotalDeathCount desc

-- Showing Continent with Highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount FROM ProjectPortfolio..CovidDeaths
WHERE continent is null GROUP BY location ORDER BY TotalDeathCount desc

--Global Numbers by day
SELECT date, SUM(new_cases)  as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)/SUM(New_Cases)*100 as DeathPercentage FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null GROUP BY date ORDER BY 1,2

--Global Numbers
SELECT SUM(new_cases)  as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)/SUM(New_Cases)*100 as DeathPercentage FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location
ORDER BY death.location, death.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths death Join ProjectPortfolio..CovidVaccinations vac on death.location = vac.location and death.date = vac.date
WHERE death.continent is not null ORDER BY 2,3


-- USE CTE
WITH PopvsVac (Continent,Location,Date,Population, New_Vaccinations, RollingPeopleVaccinated) as
(SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths death 
Join ProjectPortfolio..CovidVaccinations vac 
on death.location = vac.location 
and death.date = vac.date
WHERE death.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100 From PopvsVac

--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths death 
Join ProjectPortfolio..CovidVaccinations vac 
on death.location = vac.location 
and death.date = vac.date
--WHERE death.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths death 
Join ProjectPortfolio..CovidVaccinations vac 
on death.location = vac.location 
and death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3