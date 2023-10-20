

SELECT *
FROM CovidData.dbo.CovidDeaths$
WHERE continent is not null
order by 3,4

--Select data that we are going to be starting with 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidData.dbo.CovidDeaths$
WHERE continent is not null
order by 1, 2


--Total cases VS Total Deaths 
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM CovidData.dbo.CovidDeaths$
WHERE location like '%iran%'
and continent is not null
order by 1, 2



--Total Cases VS Population 
-- Shows what percentage of population infected with Covid

Select location, date, total_cases, population, 
(CONVERT(float, total_cases) /  population) * 100 AS PercentPopulationInfected
FROM CovidData.dbo.CovidDeaths$
--WHERE location like '%iran%'
--and continent is not null
order by 1, 2



-- Countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) as HighestInfectionCount, population, 
MAX((CONVERT(float, total_cases) /  population)) * 100 AS PercentPopulationInfected
FROM CovidData.dbo.CovidDeaths$
--WHERE location like '%Iran%'
GROUP BY location, population
order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount, 
MAX((CONVERT(float, total_deaths) /  population)) * 100 AS PercentPopulationDeath
FROM CovidData.dbo.CovidDeaths$
--WHERE location like '%Iran%'
WHERE continent is not null
GROUP BY location
order by PercentPopulationDeath desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidData.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidData.dbo.CovidDeaths$
WHERE continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
        On dea.location= vac.location
		and dea.date = vac.date
Where dea.continent is not null
order by 2,3






