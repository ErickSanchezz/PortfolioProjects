--Erick Sanchez Covid Project
--11/12/2021

--Select Data for observation purposes 
select *
from CovidProject..Covid_Deaths
where continent is not null 
order by 3,4;

select *
from CovidProject..Covid_Vaccinations
order by 3,4;


--Select Data that we are going to use

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
order by 
	location,
	date;

--	US Numbers
-- Total Cases vs Total Deaths
-- Likelihood of dying in the US
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as Percentage_of_Death
from 
	CovidProject..Covid_Deaths
where 
	location = 'United States'
order by 
	location,
	date;

--Total Cases vs Population
-- Percentage of population that got covid
select 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as Percentage_of_Population
from 
	CovidProject..Covid_Deaths
where 
	location = 'United States'
order by 
	location,
	date;


--WORLDWIDE NUMBERS
-- Countries with highest covid rates compared to their population
select 
	location,
	population,max(cast(total_cases as int)) as Highest_Case_Count,
	max((total_cases/population))*100 as Percentage_of_Population_with_covid
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
group by 
	location,
	population
order by 
	Percentage_of_Population_with_covid desc;


-- Countries with the highest number of deaths per Population 
select 
	location,
	max(cast(total_deaths AS int)) as Total_Number_of_Deaths
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
group by 
	location
order by 
	Total_Number_of_Deaths desc;


-- Continents with the highest number of deaths per Population 
select 
	location,
	max(cast(total_deaths AS int)) as Total_Number_of_Deaths
from 
	CovidProject..Covid_Deaths
where 
	continent is null
	and location != 'High income' 
	and location !='Low income' 
	and location !='Upper middle income' 
	and location !='Lower middle income' 
group by 
	location
order by 
	Total_Number_of_Deaths desc;


select continent,
	max(cast(total_deaths AS int)) as Total_Number_of_Deaths
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
group by 
	continent
order by 
	Total_Number_of_Deaths desc;

-- Continents with the highest number of deaths
select continent,
	max(cast(total_deaths AS int)) as Total_Number_of_Deaths
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
group by 
	continent
order by 
	Total_Number_of_Deaths desc;

--Worldwide new cases per date
select 
	date,
	sum(new_cases) as Cases,
	sum(cast(new_deaths as int)) as Deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_of_Death
from 
	CovidProject..Covid_Deaths
where 
	continent is not null
group by 
	date
order by 
	date;

--Worldwide total cases as of today (11/7/21)

select 
	distinct max(date) as Date,
	sum(new_cases) as Cases,
	sum(cast(new_deaths as int)) as Deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_of_Death
from 
	CovidProject..Covid_Deaths
where 
	continent is not null


--Vaccination Table 

select *
from 
	CovidProject..Covid_Vaccinations
where 
	continent is not null;

--Join Deaths Table with Vaccination Table
select *
from CovidProject..Covid_Deaths as d
join CovidProject..Covid_Vaccinations as v
	on d.location = v.location
	and d.date = v.date
	and d.continent = v.continent;

--Population and Number of Vaccinated people
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as New_Total_Vaccinations
from CovidProject..Covid_Deaths as d
join CovidProject..Covid_Vaccinations as v
	on d.location = v.location
	and d.date = v.date
	and d.continent = v.continent
where 
	d.continent is not null
order by 
	2,3;


--Temp table (with)

with PvsV (continent, location, date, population, new_vaccinations,New_Total_Vaccinations)
as
(
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as New_Total_Vaccinations
from CovidProject..Covid_Deaths as d
join CovidProject..Covid_Vaccinations as v
	on d.location = v.location
	and d.date = v.date
	and d.continent = v.continent
where 
	d.continent is not null
)
select 
	*,
	(New_Total_Vaccinations/population)*100 as Percentage_of_People_Vaccinated
from 
	PvsV
order by 
	location,
	date


--temp table

drop table if exists Percent_of_Population_Vaccinated
create table Percent_of_Population_Vaccinated 
( 
	continent nvarchar (255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	New_Total_Vaccinations numeric
)
insert into Percent_of_Population_Vaccinated 
select 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as New_Total_Vaccinations
from CovidProject..Covid_Deaths as d
join CovidProject..Covid_Vaccinations as v
	on d.location = v.location
	and d.date = v.date
	and d.continent = v.continent
where 
	d.continent is not null


select *, (New_Total_Vaccinations/Population)*100 as Percentage_of_People_Vaccinated
from 
	Percent_of_Population_Vaccinated 



--Create Views to use them in Tableau 
-- Total Cases vs Total Deaths
CREATE VIEW LikelihoodofdyingUS AS 
select 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as Percentage_of_Death
from 
	CovidProject..Covid_Deaths
where 
	location = 'United States';


--Total Cases vs Population
CREATE VIEW Percentageofpopulationcovid AS 
select 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as Percentage_of_Population
from 
	CovidProject..Covid_Deaths
where 
	location = 'United States'
order by 
	location,
	date;


--Percent of Population Vaccinated
Create view PercentofPopulationVaccinated as 
select d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location,d.date) as New_Total_Vaccinations
from CovidProject..Covid_Deaths as d
join CovidProject..Covid_Vaccinations as v
	on d.location = v.location
	and d.date = v.date
	and d.continent = v.continent
where d.continent is not null;
