-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinets_in_range CASCADE;
drop view if exists all_combinations cascade;
drop view if exists non_committed cascade;
drop view if exists commited cascade;
drop view if exists committed_with_name cascade;
drop view if exists committed_with_market cascade;
drop view if exists final_result cascade;

-- extracts relevant information from the past 20 years
create view cabinets_in_range as
select cabinet_id, country_id, party_id
from cabinet, cabinet_party
where extract(year from start_date) > 1995 and extract(year from start_date) < 2017 and cabinet_id = cabinet.id;

-- gets all valid combinations of cabinets, parties, and countries from valid information
create view all_combinations as
select cabinet_id, cabinets_in_range.country_id as country_id, party.id as party_id
from cabinets_in_range, party
where party.country_id = cabinets_in_range.country_id;

-- use left join to get the set difference of all combinations from the present one to see which combos were not met
-- returns the information on the particular party from a particular country that is not commited
create view non_committed as
select distinct all_combinations.party_id as party_id, all_combinations.country_id as country_id
from all_combinations left join cabinets_in_range
on all_combinations.cabinet_id = cabinets_in_range.cabinet_id
and all_combinations.country_id = cabinets_in_range.country_id
and all_combinations.party_id = cabinets_in_range.party_id
where cabinets_in_range.cabinet_id is null;

-- use left join to get the set difference of all valid country and parties and the non_committed ones
-- the differene will be the country and party combo that were in all cabinets
create view commited as
select distinct cabinets_in_range.party_id as party_id, cabinets_in_range.country_id as country_id
from cabinets_in_range left join non_committed
on cabinets_in_range.party_id = non_committed.party_id
and cabinets_in_range.country_id = non_committed.country_id
where non_committed.party_id is null;

-- cross with party and country to get the names of the country and party
create view committed_with_name as
select country.name as countryName, party.name as partyName, commited.party_id as party_id, commited.country_id as country_id
from commited, country, party
where commited.party_id = party.id
and commited.country_id = country.id;

-- cross with position, but left join since null is acceptable
create view committed_with_market as
select countryName, partyName, committed_with_name.party_id as party_id, committed_with_name.country_id as country_id, party_position.state_market as stateMarket
from committed_with_name left join party_position
on committed_with_name.party_id = party_position.party_id;

-- cross with party family, but left join since null is acceptable
-- this will be the final result
create view final_result as
select countryName, partyName, party_family.family as partyFamily, stateMarket
from committed_with_market left join party_family
on committed_with_market.party_id = party_family.party_id;
-- Define views for your intermediate steps here.


-- the answer to the query 
insert into q5 select * from final_result;
