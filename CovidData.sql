

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

-- Showing continents with the highest death count per population

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
-- Shows Percentage of the Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
        On dea.location= vac.location
		and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated )
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
        On dea.location= vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated / population)*100 as PopuVac
FROM PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
        On dea.location= vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PopVac
From PercentPopulationVaccinated




-- Identify COVID-19 hotspots by calculating the percentage change in new cases

SELECT location, date, new_cases,
       (new_cases - LAG(new_cases, 30) OVER (PARTITION BY location ORDER BY date)) / NULLIF(LAG(new_cases, 7) OVER (PARTITION BY location ORDER BY date), 0) * 100 AS percentage_change
FROM CovidData.dbo.CovidDeaths$
WHERE location = 'Iran' AND date >= '2020-01-03 00:00:00.000'
ORDER BY date;




-- Analyze vaccination rates and their impact

SELECT dea.location, MAX(dea.date) AS latest_date, MAX(total_cases) AS cases,
       MAX(total_deaths) AS deaths, MAX(total_vaccinations) AS total_vaccinations
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
GROUP BY dea.location
ORDER BY deaths DESC;



-- Analyze the relationship between smoking prevalence and COVID-19 deaths
SELECT
  dea.location,
  MAX(dea.date) AS latest_date,
  AVG (cast(male_smokers as float)) AS male_smokers,
  AVG(cast(female_smokers as float)) AS female_smokers,
  SUM(cast(total_deaths as float)) AS total_deaths
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  GROUP BY dea.location;



	  -- Analyze the relationship between population density and the number of cases
SELECT
  dea.location,
  population_density,
  SUM(cast(total_cases as float)) AS total_cases
FROM CovidData.dbo.CovidDeaths$ dea
Join CovidData.dbo.CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where total_cases is not null
	  and population_density is not null
	  GROUP BY dea.location, population_density
	  Order by 3



