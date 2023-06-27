
/*
Hello, my name is Renz Llenarez, a Data analyst. Thank you for checking out this code. I use a lot of comments for proper documentation.
Sometimes, next to a line of code, for me to remember what it actually does.
The Project Title is 'Exploring Covid 19 Data with SQL'
For this project, I imported two excel tables: dbo.CovidDeaths and dbo.CovidVaccinations.
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.
*/

-- Always, from starting a query. Initial checking of two imported tables
Select *
From Project.dbo.CovidDeaths
order by 3,4

Select *
From Project.dbo.CovidVaccinations
order by 3,4

-- Selecting the actual data to be used in the project
Select location, date, total_cases, new_cases, total_deaths, population
From Project.dbo.CovidDeaths
order by 1,2

-- Comparing Total Cases and Total Deaths
-- Looking for the percentage of covid death in a specific country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_rate
From Project.dbo.CovidDeaths
where location = 'Philippines'
order by 1,2

-- Comparing Total Cases and Population
-- Looking for the percentage of infection rate in a specific country
Select location, date, total_cases, population, (total_cases/population)*100 as infection_rate
From Project.dbo.CovidDeaths
where location = 'Philippines'
order by 1,2

-- Looking for the country that has the highest infection rate
Select location, population, max(total_cases) as highest_infection_count, (max(total_cases)/population)*100 as infection_rate
From Project.dbo.CovidDeaths
group by location, population
order by infection_rate desc

-- Showing countries with the highest death counts
Select location, max(cast(total_deaths as int)) as total_death_count -- Also converted the column 'total_deaths' to int, it was NVARCHAR initially
From Project.dbo.CovidDeaths
where continent is not null -- Some data in the location has actual 'continents' as the value. This line of code eliminate those
group by location
order by total_death_count desc

-- Showing continents with the highest death counts
Select location, max(cast(total_deaths as int)) as total_death_count
From Project.dbo.CovidDeaths
where continent is null -- had to declare null values of the continent column to reveal the actual total numbers
group by location
order by total_death_count desc

-- Showing Global numbers per day
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From Project..CovidDeaths
where continent is not null
group by date -- grouping by date to show total numbers per day
order by 1

-- Showing Global total numbers
-- Same as the code above, without the date column, the output is only the totals
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
From Project..CovidDeaths
where continent is not null
order by 1

-- Comparing Total Population and Total Vaccinations
-- Showing the percentage of population who has received vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rolling_number_vaccinated -- this line is for rolling summation of 'new_vaccination' number. also partition by location to divide each summation per location.
-- the 'order by' within the partition is needed to separate each sum of new vaccination per day, and not display only the 'total' number each row. the order by is what needed for the increment
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Still to show the percentage of people vaccinated
-- In this next query, I needed to use the CTE function because we cannot use a 'new column created' as a data set. In this case the 'rolling_number_vaccinated'.
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_number_vaccinated) -- insert all previous columns, the number of columns should be equal to the previous table
as
( -- just copy and pasted the code above
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rolling_number_vaccinated
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3 -- needed to remove, not allowed in CTE, causes error
)
Select *, (rolling_number_vaccinated/population)*100 as percent_people_vaccinated
From PopvsVac
where location = 'philippines' -- if you need to look at a specific country

-- Creating the exact same result as above, but using 'temp table' (can be used as a CTE alternative)
DROP Table if exists #PercentPeopleVaccinated -- this line is needed if you need to edit the table, if this line is not included running this query for the 2nd time will have an error
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_number_vaccinated numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rolling_number_vaccinated
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rolling_number_vaccinated/population)*100 as percent_people_vaccinated
From #PercentPeopleVaccinated

-- This next query creates a view to store data for visualizations in Tableau
Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rolling_number_vaccinated
From Project..CovidDeaths as dea
Join Project..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null