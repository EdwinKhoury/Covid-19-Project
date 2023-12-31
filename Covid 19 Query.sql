
--1) Looking at the total cases vs. the total deaths

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE location = 'Lebanon'
ORDER BY Date
-- It shows the likelihood of dying if you contract COVID-19 in Lebanon.
--Starting March 12 2020, the death percentage was at its highest (4.5%), but only because very few people were infected.
--With time, the number of cases and deaths kept increasing.


----------------


--2) Looking at the total cases vs. the population

SELECT Location, Date, population, total_cases,(total_cases/population)*100 AS case_percentage
FROM CovidProject..CovidDeaths
WHERE location = 'Lebanon'
ORDER BY 2
--Shows what percentage of the population got COVID-19 in Lebanon. By the end of 2020, 3.24% of the Lebanese had contracted the virus.
--By the end of 2021, 13.18% of the population had contracted COVID-19, more than three times more than the previous year.
--Up until the 30th of August 2023, 22.58% of the population contracted COVID-19. Almost 1/4 of the Lebanese population tested positive.


----------------


--3) Looking at countries with the highest infection rate compared to the population

SELECT Location, population, MAX (total_cases) AS highest_infection_count,MAX ((total_cases/population))*100 AS max_cases_infected
FROM CovidProject..CovidDeaths
GROUP BY Location, Population
ORDER BY max_cases_infected DESC
--Cyprus is the country with the highest infection rate; up until August 2023, 73.75% of the population contracted COVID-19.
--Yemen, Niger, Chad, Tanzania, and Sierra Leone have an infection rate lower than 0.1% of their populations; this is not because of 
--low propagation in these countries, but rather the unavailability of medical care and PCR tests in these countries: Most of the cases and deaths are not recorded. 


----------------


--4) Showing the countries with the highest death count per population

SELECT Location, MAX(total_deaths) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY total_death_count DESC         
--The United States is the country that counts the highest number of deaths due to COVID-19, with a toll of 1,127,152 deaths, followed by Brazil and India.


----------------


--5) Total death by continent and social status

SELECT location, MAX(total_deaths) AS total_death_count
FROM CovidProject..CovidDeaths
WHERE continent  is NULL
GROUP BY location
ORDER BY total_death_count DESC    
--The world has a total death toll of 6,956,160.
--Europe is the continent with the highest number of deaths, with 2,075,623, which accounts for a little bit less than one-third of the deaths.
--Africa is ranked as one of the continents with the fewest deaths, with 259,006. This is due to the unavailability of medical care and PCR tests.
--in these countries: Most of the cases and deaths are not recorded.


----------------


--6) Total cases, total deaths, and death percentage worldwide

SELECT date, SUM(new_cases) AS total_cases_per_day, SUM (new_deaths) AS total_deaths_per_day, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage_per_day
FROM CovidProject..CovidDeaths
WHERE continent is not NULL 
	AND new_cases > 0
GROUP BY date
ORDER BY date
--The first covid cases were recorded on the 4th of January 2020, whereas the first death was reported in 8 days.
--Mid-April 2020, almost 10% of the cases were fatal.
--By the end of December 2021, the death percentage was below 1%


----------------


--7) Global death percentage

SELECT SUM(new_cases) AS total_cases, SUM (new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE  continent is not NULL
	AND new_cases > 0
ORDER BY 1,2 
--Up until the 30th of August 2023, we count 770,166,399 cases and 6,912,380 which accounts for a death percentage of 0.9%


----------------


--8) Looking at total population vs vaccinations using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Cumulative_Sum) AS
(
SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Cumulative_Sum
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (Cumulative_Sum/Population)*100 AS vaccination_rate
FROM PopvsVac
--WHERE location = 'Lebanon'


----------------


--9) Looking at total population vs vaccinations using Temp table
-- If planning on making any alteration to the temp tables i.e delete the WHERE clause, add above the CREATE clause:

DROP TABLE IF exists #PercentPopulationVacc
CREATE TABLE #PercentPopulationVacc
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
Cumulative_Sum numeric
)

INSERT INTO  #PercentPopulationVacc
SELECT DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date, dea.location) AS Cumulative_Sum
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (Cumulative_Sum/Population)*100
FROM #PercentPopulationVacc
--WHERE location = 'Lebanon'

