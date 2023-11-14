
--Checking the death Perecentage per country

select location, date, total_cases, total_deaths, (convert(float, total_deaths) / nullif(convert(float, total_cases), 0))* 100 as Det_Per
from [New Project]..CovidDeaths$
where location like 'poland'
order by 1,2

-- total cases vs population

select location, date, total_cases, total_deaths, population, (convert(float, total_cases) / nullif(convert(float, population), 0))* 100 as Covid_pop
from [New Project]..CovidDeaths$
where location like 'poland'
order by 1,2

--Highest infection rate compared to population

select location, population, Max((convert (float, total_cases))) as Highest_inf_count, MAX((convert(float, total_cases) / nullif(convert(float, population), 0)))* 100 as Perc_pop_infected
from [New Project]..CovidDeaths$
group by Location, population
order by Perc_pop_infected desc

--Checking countries with highest death count

select location, Max((convert (float, total_Deaths))) as Total_Death_count
from [New Project]..CovidDeaths$
where continent is not null
group by Location, population
order by Total_Death_count desc

-- By continent

select location, Max((convert (float, total_Deaths))) as Total_Death_count
from [New Project]..CovidDeaths$
where continent is null
group by location
order by Total_Death_count desc

--Global numbers

select SUM((convert (float, new_cases))) as total_cases, SUM((convert (float, new_deaths))) as total_deaths, SUM((convert (float,new_deaths))) / SUM(nullif(convert (float, new_cases),0)) as Death_percent
from [New Project]..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--checking total pop vs vacc

select *
from [New Project]..CovidDeaths$ dea
join [New Project]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [New Project]..CovidDeaths$ dea
join [New Project]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from [New Project]..CovidDeaths$ dea
join [New Project]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from [New Project]..CovidDeaths$ dea
join [New Project]..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select*, (Rolling_people_vaccinated/population)*100
from PopvsVac
