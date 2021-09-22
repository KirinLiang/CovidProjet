

use PortfolioProjet
--select * from dbo.coviddeaths
--order by 3,4

--select * from dbo.covidvaccination
--order by 3,4


-- LOOK UP THE DATA FIRSTTHAT WE ARE GOING TO USE
select 
location,date,total_cases,new_cases,total_deaths,population
from dbo.coviddeaths
WHERE continent IS NOT NULL
order by 1,2


-- Looking TOTAL DEATH,TOTAL INFECTED CASES WHICH ALSO CONTRATCS THE DEATH PERCENTAGE IN COUNTRY 'CANADA'
-- THE DEATH PERCENTAGE HAS BEEN DECRESED LATELY TO 1.7% COMPARING TO SAME TIME AT 20/SEPTEMBER/2020 LAST YEAR WHICH IS 6.4%
select
location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as deathpercentage
from dbo.coviddeaths
where location like '%anad%'
AND continent IS NOT NULL
ORDER BY 1,2
;



-- LOOKING TOTAL CASES, POPULATION
-- SHOWING THAT THE PERCENTAGE OF INFECTED PERSONS IN 'CANADA'
-- THE DATA HAS BEEN RISEN UP FROM 0% TO 4.1%
select
location,date,population,total_cases,
(total_cases/population)*100 as Percentage_Infected
from dbo.coviddeaths
where location like '%ANADA%'
AND continent IS NOT NULL
ORDER BY 1,2
;

-- LOOKING THAT COUNTRIES HAS THE HIGEST INFECTED RATE 
-- WHICH IS 'SEYCHELLES' , WTIH TOTAL POPULATION OF 98,910 BUT 20,593 PERSONS GET INFECTED 
--  'SEYCHELLES' HAS THE HIGHEST INFECTED RATE 21.2%
select
location,population,MAX(total_cases),MAX((total_cases/population))*100 as Percentage_Infected
from dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Percentage_Infected DESC 



-- LOOKING UP COUNTRIES WITH HIGHEST DEATH COUNT 

Select
location,MAX(CAST(total_deaths AS INT)) as Totaldeathscount
from dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  Totaldeathscount DESC 


--LOOKING UP HIGHEST DEATH COUNT FOR EACH CONTINENT

Select
location,MAX(CAST(total_deaths AS INT)) as Totaldeathscount
from dbo.coviddeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY  Totaldeathscount DESC 



-- GLOBAL INFECTED NUMBERS AND DEATHS NUMBERS EACH DAY
select
date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)
*100 as death_percentage
from dbo.coviddeaths
where continent IS NOT NULL
group by date
ORDER BY 1,2


--UNTIL 22//SEPTEMBER/2021, GLOBAL TOTAL CASES , TOTAL DEATHS AND DEATH PERCENTAGE
select
sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)
*100 as death_percentage
from dbo.coviddeaths
where continent IS NOT NULL
ORDER BY 1,2



-- LOOKING UP TOTAL POPULATION WAS VACCINATED
SELECT 
dbo.coviddeaths.continent,dbo.coviddeaths.location,dbo.coviddeaths.date,dbo.coviddeaths.population,
dbo.covidvaccination.new_vaccinations,
sum(convert(int,dbo.covidvaccination.new_vaccinations)) over 
(partition by dbo.coviddeaths.location order by dbo.coviddeaths.location,dbo.coviddeaths.date ) as ACCUMU_PEOPLE_VACCINATED
FROM dbo.coviddeaths
join dbo.covidvaccination
on dbo.coviddeaths.location=dbo.covidvaccination.location
and dbo.coviddeaths.date=dbo.covidvaccination.date
where dbo.coviddeaths.continent IS NOT NULL
ORDER BY 2,3


--TEMPORARY TABLE
DROP TABLE IF EXISTS #Percentage_population_vaccinated
Create table #Percentage_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
ACCUMU_PEOPLE_VACCINATED numeric
)


Insert into #Percentage_population_vaccinated
SELECT 
dbo.coviddeaths.continent,dbo.coviddeaths.location,dbo.coviddeaths.date,dbo.coviddeaths.population,
dbo.covidvaccination.new_vaccinations,
sum(convert(int,dbo.covidvaccination.new_vaccinations)) over 
(partition by dbo.coviddeaths.location order by dbo.coviddeaths.location,dbo.coviddeaths.date ) as ACCUMU_PEOPLE_VACCINATED
FROM dbo.coviddeaths
join dbo.covidvaccination
on dbo.coviddeaths.location=dbo.covidvaccination.location
and dbo.coviddeaths.date=dbo.covidvaccination.date
where dbo.coviddeaths.continent IS NOT NULL
ORDER BY 2,3

SELECT *,(ACCUMU_PEOPLE_VACCINATED/POPULATION)*100
FROM #Percentage_population_vaccinated

