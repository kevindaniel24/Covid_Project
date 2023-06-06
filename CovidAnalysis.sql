
-- Total covid cases vs total deaths
-- Likelihood of dying if infected by covid in each country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS NUMERIC)/CAST(total_cases AS NUMERIC))*100 as DeathPercentage
FROM CovidDeaths
ORDER BY 1,2

-- Total cases vs population
-- Percentage of population infected by covid 
SELECT location, date, total_cases, population, (CAST(total_cases AS NUMERIC)/population)*100 as InfectedPercentage
FROM CovidDeaths
ORDER BY 1,2

-- Infected percentage compared to population
SELECT location, population, MAX(CAST(total_cases AS NUMERIC)) AS total_infected, MAX(CAST(total_cases AS NUMERIC)/population)*100 as InfectedPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest Death Count per population

SELECT location, MAX(CAST(total_deaths AS NUMERIC)) AS death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Continent with highest Death Count per population

SELECT location, MAX(CAST(total_deaths AS NUMERIC)) AS death_count
FROM CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%World%' AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY 2 DESC


-- Global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
 
SELECT *
FROM CovidDeaths cd JOIN CovidVaccination cv ON cv.location= cd.location AND cv.date = cd.date

-- Total vaccination compared to population

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS bigint))
OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccination cv ON cv.location= cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2,3

WITH VCP (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS bigint))
OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccination cv ON cv.location= cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinationPercentage
FROM VCP
ORDER BY 2,3

-- View for visualization
Create View PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS bigint))
OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccination cv ON cv.location= cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated

Create View PercentPopulationInfected AS
SELECT continent, location, population, MAX(CAST(total_cases AS NUMERIC)) AS total_infected, MAX(CAST(total_cases AS NUMERIC)/population)*100 as InfectedPercentage
FROM CovidDeaths
WHERE location NOT LIKE '%World%' AND location NOT LIKE '%income%' AND continent IS NOT NULL
GROUP BY continent, location, population

SELECT * FROM PercentPopulationInfected

Create View PercentPopulationDeaths AS
SELECT continent, location, date, total_cases, new_deaths, total_deaths, (CAST(total_deaths AS NUMERIC)/CAST(total_cases AS NUMERIC))*100 as DeathPercentage
FROM CovidDeaths
WHERE location NOT LIKE '%World%' AND location NOT LIKE '%income%' AND continent IS NOT NULL

SELECT * FROM PercentPopulationDeaths







