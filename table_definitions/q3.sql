-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;
drop view if exists first_step cascade;
drop view if exists step_with_ratio cascade;
drop view if exists decreasing cascade;
drop view if exists not_decreasing cascade;
drop view if exists final_result cascade;

-- Define views for your intermediate steps here.

-- Extracts all relevant information from the last 15 years for all countries
create view first_step as
select country_id, extract(year from e_date) as year, electorate, votes_cast, id
from election
where extract(year from e_date) < 2017 and extract(year from e_date) > 2000;

-- Converts the data from first step by combining electorate and votes_cast to find the participationRatio
create view step_with_ratio as
select country_id, year, (1.00*sum(votes_cast))/(1.00*sum(electorate)) as ratio
from first_step
-- Group by country and year to sum and find the average
group by country_id, year;

-- Find the country id of all countries who had a decreasing ratio within the last 15 years
create view decreasing as
select distinct step_with_ratio.country_id
from step_with_ratio, step_with_ratio as temp
-- Check to see if year y > year x, but ratio y < ratio x
where step_with_ratio.country_id = temp.country_id
and step_with_ratio.year > temp.year
and step_with_ratio.ratio < temp.ratio;

-- Use left join to find the set difference between the original and the decreasing, these will be the non-decreasing country id
create view not_decreasing as
select step_with_ratio.country_id, year, ratio
from step_with_ratio left join decreasing on step_with_ratio.country_id = decreasing.country_id
where decreasing.country_id is null;

--bind a country name to non_decreasing for final result
create view final_result as
select country.name as countryName, year, ratio as participationRatio
from country, not_decreasing
where country.id = not_decreasing.country_id;

-- the answer to the query
insert into q3 select * from final_result;
