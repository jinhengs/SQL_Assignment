-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS election_data CASCADE;


-- This table lists the relevant information for all elections within the past 20 years
create VIEW election_data as
select extract(year from e_date) as year, country_id, votes_valid, votes, party_id
from election_result, election
-- check if within the past 20 years
where election_result.election_id = election.id and extract(year from election.e_date) > 1995 and extract(year from election.e_date) < 2017;

drop table if exists ranges cascade;

-- This table is to create columns representing the different percentage ranges 0-5 etc.
create TABLE ranges(
under_five VARCHAR(20),
five_to_ten VARCHAR(20),
ten_to_twenty VARCHAR(20),
twenty_to_thirty VARCHAR(20),
thirty_to_fourty VARCHAR(20),
over_fourty VARCHAR(20)
);

-- inserts the ranges as varchar to the columns respective to their names.
insert into ranges(under_five, five_to_ten, ten_to_twenty, twenty_to_thirty, thirty_to_fourty, over_fourty)
values ('(0-5]', '(5-10]', '(10-20]', '(20-30]', '(30-40]', '(40-100]');

drop view if exists under_five cascade;
drop view if exists five_to_ten cascade;
drop view if exists ten_to_twenty cascade;
drop view if exists twenty_to_thirty cascade;
drop view if exists thirty_to_fourty cascade;
drop view if exists over_fourty cascade;


-- create a separate view for each one of the ranges, to crossover later on
create view under_five as
select under_five
from ranges;

create view five_to_ten as
select five_to_ten
from ranges;

create view ten_to_twenty as
select ten_to_twenty
from ranges;

create view twenty_to_thirty as
select twenty_to_thirty
from ranges;

create view thirty_to_fourty as
select thirty_to_fourty
from ranges;

create view over_fourty as
select over_fourty
from ranges;



DROP VIEW IF EXISTS underFive CASCADE;

-- Gets the country, party, and year from election averages that are less than 5%
create VIEW underFive as
select year, country.name as countryName, under_five as voteRange, party.name_short as partyName
-- Cross with under_five to set the voteRange to the appropriate varchar
from election_data, under_five, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
-- Group by variables to be selected and sum votes to find the average
group by year, country.name, party.name_short, under_five
having (100.0*sum(votes))/(sum(votes_valid)) <= 5;

DROP VIEW IF EXISTS fiveToTen CASCADE;

-- The below four views are based on the same idea as underFive

create VIEW fiveToTen as
select year, country.name as countryName, five_to_ten as voteRange, party.name_short as partyName
from election_data, five_to_ten, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
group by year, country.name, party.name_short, five_to_ten
having (100.0*sum(votes))/(sum(votes_valid)) <= 10 and (100.0*sum(votes))/(sum(votes_valid)) > 5;

DROP VIEW IF EXISTS tenToTwenty CASCADE;

create VIEW tenToTwenty as
select year, country.name as countryName, ten_to_twenty as voteRange, party.name_short as partyName
from election_data, ten_to_twenty, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
group by year, country.name, party.name_short, ten_to_twenty
having (100.0*sum(votes))/(sum(votes_valid)) <= 20 and (100.0*sum(votes))/(sum(votes_valid)) > 10;

DROP VIEW IF EXISTS twentyToThirty CASCADE;

create VIEW twentyToThirty as
select year, country.name as countryName, twenty_to_thirty as voteRange, party.name_short as partyName
from election_data, twenty_to_thirty, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
group by year, country.name, party.name_short, twenty_to_thirty
having (100.0*sum(votes))/(sum(votes_valid)) <= 30 and (100.0*sum(votes))/(sum(votes_valid)) > 20;

DROP VIEW IF EXISTS thirtyToFourty CASCADE;

create VIEW thirtyToFourty as
select year, country.name as countryName, thirty_to_fourty as voterange, party.name_short as partyName
from election_data, thirty_to_fourty, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
group by year, country.name, party.name_short, thirty_to_fourty
having (100.0*sum(votes))/(sum(votes_valid)) <= 40 and (100.0*sum(votes))/(sum(votes_valid)) > 30;

DROP VIEW IF EXISTS fourtyAbove CASCADE;

create VIEW fourtyAbove as
select year, country.name as countryName, over_fourty as voteRange, party.name_short as partyName
from election_data, over_fourty, country, party
where country.id = election_data.country_id and party.id = election_data.party_id
group by year, country.name, party.name_short, over_fourty
having (100.0*sum(votes))/(sum(votes_valid)) > 40;
-- Define views for your intermediate steps here.

DROP VIEW IF EXISTS finalResult CASCADE;

-- Union all the different views that represent different ranges, this is the final result

create VIEW finalResult as
select * from underFive
union
select * from fiveToTen
union
select * from tenToTwenty
union
select * from twentyToThirty
union
select * from thirtyToFourty
union
select * from fourtyAbove;

-- the answer to the query
insert into q1 select * from finalResult;
