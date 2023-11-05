git rm unwanted-file.txt

select*
from [Portfolio project]..CovidDeaths
where continent is not null
order by 3,4

--select*
--from [Portfolio project]..CovidVaccinations
--order by 3,4

--Select the data that I will use

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..CovidDeaths
where continent is not null
order by 1,2

--Im looking for total cases vs total deaths - this will tell me the likelihood of dying 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from [Portfolio project]..CovidDeaths
--where location like 'poland'
where continent is not null
order by 1,2

--looking at total cases vs popuation
--It will show what % of pop got covid

select location, date, population, total_cases, (total_cases/population)*100 as Percentage_population_infected
from [Portfolio project]..CovidDeaths
--where location like 'poland'
where continent is not null
order by 1,2

-- Checking for countries with highest infection rate vs pop

select location, population, MAx(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 as Percentage_population_infected
from [Portfolio project]..CovidDeaths
where continent is not null
group by location, population
order by Percentage_population_infected desc

--countries with highest death count per pop

select location, max(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc

--Checking eerything per continent - highest death count

select continent, max(cast(total_deaths as int)) as Total_death_count
from [Portfolio project]..CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc

--GLOBAL

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from [Portfolio project]..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with Pop_vs_Vac (continent, location, date, population,new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*, (Rolling_People_Vaccinated/population)*100 
from Pop_vs_Vac

--Creating view for later visualisation

Create view Pop_vs_Vac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from [Portfolio project]..CovidDeaths dea
join [Portfolio project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from Pop_vs_Vac
