-- VoteRange

SET SEARCH_PATH TO parlgov;

select * from q5 order by
countryName asc, partyName asc, stateMarket desc;