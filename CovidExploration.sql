/*

This datasets can be found on https://ourworldindata.org/covid-deaths 
Functions used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Convert Data Types 

*/

--Filter out all the results that contains data from the WHOLE CONTINENT Or people income
SELECT *
FROM Covid..CovidDeaths
WHERE continent is not null
order by 3,4; 

--Organize the table by column 1 and 2 ( location, date)
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Look at the possibility of death if you got covid in Finland
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal)/total_cases) *100  as DeathPercentage 
FROM Covid..CovidDeaths
WHERE location like '%Finland%'
ORDER BY 1,2;

--Look at the percentage of the population that got covid in Finland 
SELECT location, date,population, total_cases, (CAST(total_cases AS decimal)/population)*100 as  PercentageCovid
FROM Covid..CovidDeaths
WHERE  location like '%Finland%'
ORDER BY 1,2;

--Look at the percentage of the population that got covid in the world  
SELECT location, date,population, total_cases, (CAST(total_cases AS decimal)/population)*100 as  PercentageCovid
FROM Covid..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;

--Look at countries that have the highest infection rate 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST (total_cases AS decimal)/population))*100 as  PercentPopulationInfected
FROM Covid..CovidDeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
--Cyprus is the country that has the highest percentage

--Look at the country with the highest death count 
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Look at the continent with the highest death count and filter out the rows that contain people with high or upper middle income 
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is  null AND location not in ('High income','Upper middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Total number of deaths across all countries by date 
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, CAST(SUM(new_deaths)AS decimal)/SUM(new_cases)* 100  as DeathPercentage 
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY date  
ORDER BY 1,2;

--Death percentage across all countries 
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, CAST(SUM(new_deaths)AS decimal) /SUM(new_cases)* 100  as DeathPercentage 
FROM Covid..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--Look at Covid Vaccinations 
--Join the two tables using date and location
SELECT * 
FROM Covid..CovidDeaths  dea
JOIN Covid..CovidVacinations  vac 
ON dea.location = vac.location
AND dea.date = vac.date;
--Looking at Total Population vs Vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as AccumulatedPeopleVaccinated 
FROM Covid..CovidDeaths dea 
JOIN Covid..CovidVacinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;
--PERCENTAGE of people vaccinated by population 

WITH PopvsVac (continent, location, date, population, new_vaccinations, AccumulatedPeopleVaccinated)
AS(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as AccumulatedPeopleVaccinated
    FROM Covid..CovidDeaths dea 
    JOIN Covid..CovidVacinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent is not null
  )
SELECT *, (CAST(AccumulatedPeopleVaccinated AS decimal)/population)*100
FROM PopvsVac; 


--Create a temp table 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME, 
    population NUMERIC,
    new_vaccinations NUMERIC,
    AccumulatedPeopleVaccinated NUMERIC
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as AccumulatedPeopleVaccinated
    FROM Covid..CovidDeaths dea 
    JOIN Covid..CovidVacinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent is not null
SELECT *, (CAST(AccumulatedPeopleVaccinated AS decimal)/population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3; 

--Create view to store data for visualizations

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as AccumulatedPeopleVaccinated
    FROM Covid..CovidDeaths dea 
    JOIN Covid..CovidVacinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent is not null; 
    
SELECT * 
FROM PercentPopulationVaccinated; 
