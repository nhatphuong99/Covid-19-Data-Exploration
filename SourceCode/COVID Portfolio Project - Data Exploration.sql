/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from PortfolioProject..CovidDeaths
order by location, date;

select * 
from PortfolioProject..CovidVaccinations
order by location,date;


--- Select the data gonna use
select location, date, total_cases, new_cases, total_deaths, new_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date;


--- Total Cases vs Total Deaths
--- Shows the likelihood of dying if you contract covid in a country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date;

-- In US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'united states'
order by location, date;

-- In Vietnam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location = 'vietnam'
order by location, date;


--- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date;

-- In US
select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from PortfolioProject..CovidDeaths
where location = 'united states'
order by location, date;

-- In Vietnam
select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from PortfolioProject..CovidDeaths
where location = 'vietnam'
order by location, date;


--- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as highest_percent_population_infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by highest_percent_population_infected desc;


--- Countries with Highest Death Count per Population

select location, max(total_deaths) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null -- when continent is null, the location become the continent instead of the country
group by location
order by total_death_count desc;


--- Continents with Highest Death Count per Population

select continent, max(total_deaths) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc;


--- global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null;


--- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Creates a rolling count of vaccinated - sum the new vaccination by the location 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;



--- Using CTE to perform Calculation on Partition By in previous query
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vaccinated/population)*100 as vaccinate_percentage
from pop_vs_vac
order by location, date;


--- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (rolling_people_vaccinated/population)*100 as vaccinate_percentage
from #percent_population_vaccinated
order by location, date;


--- Create view to store data for later visualizations

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

select *
from percent_population_vaccinated;
