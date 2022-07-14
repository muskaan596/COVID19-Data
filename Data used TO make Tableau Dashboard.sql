-- 1)Total case + TOTAL DEATH + PERCENTAGE_DEATH

select sum(new_cases) as total_case ,
sum(cast(new_deaths as int)) as total_death,(sum(cast(new_deaths as int))/sum(new_cases))*100 percentage_death
from CovidDeaths
where continent is not null

--2)
select location,sum(cast(new_deaths as int) )as TotalDeathCount
from  CovidDeaths
where continent is null
and location not in ('World','European Union','International')
group by location order by TotalDeathCount desc

--3)

select location,Population,Max(total_cases) HighestInfectedCount, max(percentage_covid) PercentPopulationInfected
from(
select Location,Population ,total_cases,(total_cases/population)*100 percentage_covid
from CovidDeaths) b
group by location,Population
order by 4 desc

--4)
select location,Population,date,Max(total_cases) HighestInfectedCount, max(percentage_covid) PercentPopulationInfected
from(
select Location,date,Population ,total_cases,(total_cases/population)*100 percentage_covid
from CovidDeaths) b
group by location,Population,date
order by 5 desc

