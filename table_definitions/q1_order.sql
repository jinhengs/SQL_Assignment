-- VoteRange

SET SEARCH_PATH TO parlgov;

select * from q1 order by year desc, countryName desc, voteRange desc, partyName desc;