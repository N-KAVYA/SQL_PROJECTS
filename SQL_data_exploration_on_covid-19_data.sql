select *
from PotfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PotfolioProject..CovidVaccinations$
--where continent is not null
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases,total_deaths,population
from PotfolioProject..CovidDeaths$
where continent is not null
order by 1, 2

--Looking at total cases vs total deaths
-- shows likelihood of dying if you contracted in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PotfolioProject..CovidDeaths$
where location like 'indi%' and continent is not null
order by 1, 2

--Looking a total cases vs population
--total percentage of population got covid
select location, date, total_cases, population,(total_cases/population)*100 as positive_patients
from PotfolioProject..CovidDeaths$
--where location like 'indi%'
where continent is not null
order by 1,2

--looking at the county with highest +ve rate
select location, population, max(total_cases)as highestinfection, max((total_cases)/population)*100 as percentagepopulation 
from PotfolioProject..CovidDeaths$
--where location like 'indi%'
where continent is not null
group by location, population
order by 4 desc

-- highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PotfolioProject..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

-- highest death in continent
select continent, max(cast(total_deaths as int)) as totaldeathcount
from PotfolioProject..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

-- global  number
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as total_new_death_percentage
from PotfolioProject..CovidDeaths$
--where location like 'indi%' 
where continent is not null
--group by date
order by 1, 2


--JOINS
--total population vs vaccination
select dea.continent,dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopvsVac (continent, location, date, population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


--Temp table
drop table if exists perpopulvacc
create table perpopulvacc(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into perpopulvacc
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from perpopulvacc

--View table

create view viewpercentagepopulationvaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PotfolioProject..CovidDeaths$ dea
join PotfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

drop view if exists viewpercentagepopulationvaccinated

select * 
from viewpercentagepopulationvaccinated
