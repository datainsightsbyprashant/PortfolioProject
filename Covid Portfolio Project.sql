Select * from dbo.[Covid Deaths]
order by 3,4;

--Select * from dbo.[Covid Vaccinations]
--order by 3,4;

Select location, date, total_cases,new_cases,total_deaths,population 
from p3.dbo.[Covid Deaths]
order by 1,2;

--Total cases vs Total Deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100
from P3.dbo.[Covid Deaths]
order by 1,2;

-- Set a default value for a column if the actual value is NULL
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P3.dbo.[Covid Deaths]
order by 1,2;

-- Set a default value for a column if the actual value is NULL
Select location, date, total_deaths, total_cases,
(CONVERT(float, total_deaths) /NULLIF(CONVERT(float, total_cases),0)) * 100 AS Deathpercentage
from P3.dbo.[Covid Deaths]
order by 1,2;

Select location, date, total_deaths, total_cases, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from P3.dbo.[Covid Deaths]
where location like '%States'
order by 1,2;

Select location, date, total_deaths, total_cases, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [P3].[dbo].[Covid.Deaths1]
where location like '%India'
order by 1,2;

--Percentage of population affected by Covid
Select location, date, total_cases, population, 
(CONVERT(float, total_cases) / population) * 100 AS InfectionPercentage
from [P3].[dbo].[Covid.Deaths1]
where location like '%India'
order by 1,2;

--Highest Infection Count
Select location,population, MAX(cast(total_cases as int)) as HighestInfectionCount, (MAX(cast(total_cases as int))/population) * 100 AS InfectionPercentage
from [P3].[dbo].[Covid.Deaths1]
--where location like '%India'
Group by location, population
order by 4 desc;

--Showing the countries with highest death count per population
Select location,population, MAX(cast(total_deaths as int)) as HighestDeathCount, (MAX(cast(total_deaths as int))/population) * 100 AS DeathPercentage
from [P3].[dbo].[Covid.Deaths1]
--where location like '%India'
where continent is not null
Group by location, population
order by 4 desc;

--Grouping by Continent
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from [P3].[dbo].[Covid.Deaths1]
--where location like '%India'
where continent is null
Group by location
order by 2 desc;

--Showing the continent with the highest death continent
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from P3.dbo.[Covid.Deaths1]
where location is not null
Group by continent
order by 2 desc;

--Global Numbers

Select SUM(new_cases) as NewCases,Sum(New_deaths) as NewDeaths, SUM(new_deaths)/nullif(Sum(new_cases),0)*100 as DeathPercentage
from p3.dbo.[Covid.Deaths1]
where continent is not null
order by 1,2;

--Looking at total population and the percent vaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from p3..[Covid.Deaths1] dea
join p3..[Covid Vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (PARTITION BY DEA.location order by dea.location, dea.date) as RunningVaccinationTotals
from p3..[Covid.Deaths1] dea
join p3..[Covid Vaccinations] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations,RunningVaccinationsTotals) 
as
(
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (PARTITION BY DEA.location order by dea.location, dea.date) as RunningVaccinationTotals
from p3..[Covid.Deaths1] dea
join p3..[Covid Vaccinations] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null
)

Select *, (RunningVaccinationsTotals/population) * 100 as VaccinationPercentage from PopvsVac
order by 2,3

--Use View
Create View PercentPopulationVaccinated
as
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (PARTITION BY DEA.location order by dea.location, dea.date) as RunningVaccinationTotals
from p3..[Covid.Deaths1] dea
join p3..[Covid Vaccinations] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null

--Creating Temp Table
Create Table VaccinationAndPopulation
(continent nvarchar(255),
location nvarchar(255),
date Date,
Population Numeric,
new_vaccination numeric,
RunningVaccinationTotals numeric)

Insert into VaccinationAndPopulation
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (PARTITION BY DEA.location order by dea.location, dea.date) as RunningVaccinationTotals
from p3..[Covid.Deaths1] dea
join p3..[Covid Vaccinations] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null

--
--Total cases vs Total Deaths
--Death Percentage
--Percentage of population affected by Covid
--Highest Infection Count
--Showing the countries with highest death count per population
--Grouping by Continent
--Showing the continent with the highest death continent
--Global Numbers
--Looking at total population and the percent vaccinated