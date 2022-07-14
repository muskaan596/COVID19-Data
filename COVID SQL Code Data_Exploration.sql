select * from CovidDeaths
order by 3,4;

--select * from CovidVaccinations
--order by 3,4

 --select data that we are going to be using
select Location,date,total_cases,new_cases,total_deaths ,population
from CovidDeaths
order by 1,2

--looking at total cases vs total deaths
select Location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 percentage_death
from CovidDeaths
order by 1,2
offset (select count(*) from CovidDeaths)-5 rows
--shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths ,(total_deaths/total_cases)*100 percentage_death
from CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
--shows what percentage of population got covid
select Location,date,total_cases,population ,(total_cases/population)*100 percentage_covid
from CovidDeaths
where location like '%states%'
order by 1,2
--offset (select count(*) from CovidDeaths)-5 rows


-- country which has highest infection rate compared to population
select Location,date,population,total_cases ,(total_cases/population)*100 percentage_covid
from CovidDeaths
where (total_cases/population)*100=
(select max(percentage_covid) from (select (total_cases/population)*100 percentage_covid from CovidDeaths) a)
order by 1,2


--each country's highest rate of infection 
select location, max(percentage_covid)
from(
select Location ,(total_cases/population)*100 percentage_covid
from CovidDeaths) b
group by location
order by 2 desc


--total locations
select  location, count(location) from CovidDeaths
group by location
order by 1

--  showing countries with highest death count
select location, max(cast(total_deaths as int)) total_deaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- lets break down things by continent
select continent, max(cast(total_deaths as int)) total_deaths
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- global numbers
select date,sum(new_cases) as total_case ,
sum(cast(new_deaths as int)) as total_death,(sum(cast(new_deaths as int))/sum(new_cases))*100 percentage_death
from CovidDeaths
where continent is not null
group by date

-- joining the two tables

select * 
from CovidDeaths dea inner join
CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) cumulative_vaccine
from CovidDeaths dea inner join
CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3

--use cte
with popVSvac
(continent,location,date,population,new_vaccinations,cumulative_vaccine)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) cumulative_vaccine
from CovidDeaths dea inner join
CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
select * ,(cumulative_vaccine/population)*100 
from popVSvac


--Creating view to store data for later visualisation
create view percent_population_vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) cumulative_vaccine
from CovidDeaths dea inner join
CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
