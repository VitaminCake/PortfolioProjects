SELECT*
--I use "WHERE continent is not null" because in some data the the CONTINENT and LOCATION are switched
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 1,2

--Looking Total Cases vs Total Deaths
--Shows the probability of dying if you contract covid
Select location, date, total_cases,total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is not null
Where location like '%italy%'
order by 1,2


--Looking at Total cases vs Population
--Shows what percentage of the population got infected
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is not null
Where location like '%italy%'
order by 1,2

--Looking at countries with highest infection rate
Select location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
order by InfectionPercentage desc


--Countries with highest deaths per population
--I used CAST on "total_deaths" in this query because there is an error in the data type, i have to cast it as a numeric value
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
order by TotalDeathCount  desc

--Continent with highest deaths per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount  desc

--Global Numbers
--Data error here, "new_cases" is float while "new_deaths" is "nvarchar" forcing me to use CAST
Select SUM(new_cases)as Totalcases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 1,2

--Total population vs vaccinations
--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalPeopleVaccinated) 
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(cast(CV.new_vaccinations as int)) OVER (partition by CD.location order by CD.Location, CD.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths$ CD
Join PortfolioProject..CovidVaccinations$ CV	
  On CD.location = CV.location
  and CD.date = CV.date 
where CD.continent is not null
)
SELECT*, (TotalPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(cast(CV.new_vaccinations as int)) OVER (partition by CD.location order by CD.Location, CD.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths$ CD
Join PortfolioProject..CovidVaccinations$ CV	
  On CD.location = CV.location
  and CD.date = CV.date 
where CD.continent is not null

SELECT*, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

	
--Creating view to store data for visualization

Create View PercentPopulationVaccinated as
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(cast(CV.new_vaccinations as int)) OVER (partition by CD.location order by CD.Location, CD.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths$ CD
Join PortfolioProject..CovidVaccinations$ CV	
  On CD.location = CV.location
  and CD.date = CV.date 
where CD.continent is not null


Select*
From PercentPopulationVaccinated