/*
Hello, my name is Renz Llenarez, a Data analyst. Thank you for checking out this code. I use a lot of comments for proper documentation.
Sometimes, next to a line of code, for me to remember what it actually does.
These are the queries I used for the Tableau Project.
For this project, I had to export 4 total excel tables to be imported to tableau.
*/

-- Table 1
-- First table shows the total cases and total deaths. Comparing the two to get the death percentage of covid around the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project.dbo.CovidDeaths
where continent is not null 
order by 1,2

-- Table 2
-- Second table is to determine the total count of deaths per continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Project.dbo.CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International') -- this line is to eliminate global/world data, to filter out other summations
Group by location
order by TotalDeathCount desc

-- Table 3
-- Third table shows the countries with the highest infection count and highest percentage of people infected per their respective total population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project.dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Table 4
-- Fourth table is to show the average of infection rate per country with respect to time/date

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project.dbo.CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc