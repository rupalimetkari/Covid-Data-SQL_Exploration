
--database name
use Data_Exploration_covid 

--CovidDeaths table
select * from CovidDeaths
order by 3,4

--select cloumns from CovidDeaths table
select location,date, total_cases, new_cases, total_deaths,population
 from CovidDeaths order by 1,2


 --looking at total cases vs total deaths in USA state
select location,date, total_cases, total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
 from CovidDeaths 
 where location like '%states%'
 order by 1,2

 --looking at total cases vs population , shows what percentage of population got covid
 select location,date, total_cases, population,(total_cases/population) *100 as PercentPopulationInfected
 from CovidDeaths 
 --where location like '%states%'
 order by 1,2

 --looking at countries with highest infection rat compared to population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
 from CovidDeaths 
 --where location like '%states%'
 group by location,population
 order by PercentPopulationInfected desc

 --Lets break things down by continent
 select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from CovidDeaths 
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc


 --showing countries with highest death count per population
 select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
 from CovidDeaths 
 --where location like '%states%'
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 --Global numbers
 select  SUM(new_cases), SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
 from CovidDeaths 
 --where location like '%states%'
 where continent is not null
 --group by date
 order by 1,2


--join covide death table aND Covidvaccination table
select * from CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccnation
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location)
 from CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using with (cte)

With PopvsVac (Continent, location, date, population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population) *100 from PopvsVac


--Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
 from CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population) *100 from #PercentPopulationVaccinated

--create view to store data for visulizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
 from CovidDeaths dea Join CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3