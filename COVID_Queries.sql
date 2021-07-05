select * from dbo.covidDeaths
order by 3,4

select * from dbo.covidVaccinations
order by 3,4

-- Select Data that we are going to be using

select Location, date, total_deaths, new_cases, total_deaths, population
from dbo.covidDeaths
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in the united states
select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from dbo.covidDeaths
Where location like '%states%'
order by 1, 2


-- Total Cases vs Population
-- What Percentage of Population has contacted Covid
select Location, date, total_cases, Population, (total_cases/population)*100 as InfectionPercentage
from dbo.covidDeaths
Where location like '%states%'
order by 1, 2

-- Looking at countries with Highest infection Rate compared to Population
select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
from dbo.covidDeaths
Group by Location, population
order by InfectionPercentage desc


-- Showing Countries with Highest Death Count per Population
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.covidDeaths
where continent is not null
Group by Location, population
order by TotalDeathCount desc

-- By Continent
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.covidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.covidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- aggregate functions
-- Global Numbers
select date, SUM(new_cases) as all_new_cases, sum(cast(new_deaths as int)) as all_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.covidDeaths
Where continent is not null
Group By date
order by 1, 2

-- Overall death percentage
select SUM(new_cases) as all_new_cases, sum(cast(new_deaths as int)) as all_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.covidDeaths
Where continent is not null
order by 1, 2


--Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
