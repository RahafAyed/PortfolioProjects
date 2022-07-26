select *
from projectPortfolio..CovidDeaths
order by 3,4

--select *
--from projectPortfolio..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from projectPortfolio..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- show the liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projectPortfolio..CovidDeaths
where location like '%kenya%'
order by 1,2

-- looking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from projectPortfolio..CovidDeaths
-- where location like '%kenya%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from projectPortfolio..CovidDeaths
-- where location like '%kenya%'
group by location, population
order by PercentagePopulationInfected desc


-- showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from projectPortfolio..CovidDeaths
-- where location like '%kenya%'
-- where continent is not null
group by location
order by HighestDeathCount desc

-- showing the continent with highest death count per population
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from projectPortfolio..CovidDeaths
-- where location like '%kenya%'
where continent is not null
group by continent
order by HighestDeathCount desc

-- global numbers
select date, SUM(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercenatge
from projectPortfolio..CovidDeaths
-- where location like '%kenya%'
where continent is not null
group by date
order by 1,2

-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)
from projectPortfolio..CovidDeaths dea
join projectPortfolio.. CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- create temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectPortfolio..CovidDeaths dea
Join projectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From projectPortfolio..CovidDeaths dea
Join projectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 