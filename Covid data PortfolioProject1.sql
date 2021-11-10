select * from PortfolioProject .. coviddeaths
-- this is an exploratory project to examine this datasets to look for unique trends and informations

select date,location,population,total_cases,new_cases,new_deaths,total_deaths 
from PortfolioProject .. coviddeaths
order by location,date

--lets take a look at some critical figures



----Total case vs Total death(DeathPercentage)
--select location,date,population,total_cases,total_deaths,(total_deaths/population)*100 as Deathpercentage
--from PortfolioProject .. coviddeaths
--order by location,date


--Total cases vs Total deaths(DeathPercentage) Worldwide.
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject .. coviddeaths
where continent is not null
--Group by location
order by 1,2

--1.Total cases vs Total deaths(DeathPercentage) Nigeria.
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject .. coviddeaths
--where continent is not null
where location like '%Nigeria%'
--Group by location
order by 1,2

--2. Total cases vs population(PopulationPercentageInfected). Nigeria

select SUM(new_cases) as total_cases,population,
(SUM(cast(new_deaths as int))/population * 100) as PopulationPercentageInfected
from PortfolioProject .. coviddeaths
--where continent is not null
where location like '%Nigeria%'
Group by population
order by PopulationPercentageInfected desc




--3.Countries with the highest infection rate
select location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases)/population * 100 as HighestInfectedRatedCountries
from PortfolioProject .. coviddeaths
--where location like '%Nigeria%'
where continent is not null
Group by location,population
order by HighestInfectedRatedCountries desc






--select * from PortfolioProject..covidvaccinations
--order by location




--Creating a join statement to merge the two files.
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
order by location,date


------data cleaning
----select date1 
----from PortfolioProject ..covidvaccinations

----update covidvaccinations
----set date = convert(date,date)

----Alter Table covidvaccinations
----Add date1 Date;

--update covidvaccinations
--set date1 = convert(date,date)


--4.percentage of vaccinated people per country
--Using a CTE
with popvsvac (Location,continent,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.location,dea.continent,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by RollingPeopleVaccinated desc


) 
select * ,( RollingPeopleVaccinated/population)* 100
from popvsvac


--Using a Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Location nvarchar(255),
Continent nvarchar(255),
Date datetime,
Population numeric,
Total_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.location,dea.continent,dea.date,dea.population,vac.total_vaccinations,
MAX(vac.total_vaccinations) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by RollingPeopleVaccinated desc

select * ,( RollingPeopleVaccinated/population)* 100
from #PercentPopulationVaccinated




--creating a view
create view PercentPopulationVaccinated as
select dea.location,dea.continent,dea.date,dea.population,vac.total_vaccinations,
MAX(vac.total_vaccinations) Over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null



