DROP DATABASE baseball;

CREATE DATABASE baseball;

USE baseball;

\. C:\Users\MarkF\Desktop\DATABASES\baseball.sql 

CREATE INDEX piindex ON pitching(playerid);

CREATE INDEX pindex ON people(playerid);

CREATE INDEX appindex ON appearances(playerid);

CREATE INDEX teamsindex ON teams(teamid);

-- 1. Consider the people whose final game was in 2018 to be 
-- active players. Find the name of all active players who have 
-- played for all teams that won 100 or more games in 2003. 
-- Note, the player could have played on the team at any
-- time in their career.
/*
 set difference of valid players and valid teams
 */
SELECT
    concat(nameFirst, ' ', nameLast) as player_name
FROM
    People AS p
WHERE
    NOT EXISTS ((
        SELECT
            distinct teamid
        FROM
            teams t
        WHERE
            w >= 100
            AND yearid = 2003
    )
EXCEPT
    (
        SELECT
            DISTINCT(teamId)
        FROM
            appearances a
        WHERE
            a.playerid = p.playerid
            AND YEAR(p.finalgame) = 2018


-- 2 Create the table PitchingAnalytics which contains the 
-- playerid, yearid, stint and teamid of all pitchers.
CREATE TABLE PitchingAnalytics AS (
    SELECT
        playerid,
        yearid,
        stint,
        teamid
    FROM
        Pitching
);

CREATE INDEX pa ON PitchingAnalytics(playerid);

-- 3 Add the column WHIP (Walks+Hits per Inning Pitched) 
-- as a numeric field with 3 decimal digits and 2 whole number 
-- digits.
ALTER TABLE
    PitchingAnalytics
ADD
    COLUMN WHIP decimal(5, 3);

-- 4 Update the PitchingAnalytics table to add the value 
-- for WHIP (3*(H+BB)/IPOUTS) for each player.
UPDATE
    PitchingAnalytics pa,
    Pitching p
SET
    pa.WHIP = (
        3 *(p.H + p.BB) / IF(
            IF(p.IPOUTS = 0, -1, p.ipouts) < 0,
            NULL,
            p.ipouts
        )
    )
WHERE
    pa.playerid = p.playerid;

-- 5 Insert a "Totals" Rows into PitchingAnalytics. The 
-- playerid is "Totals", the year, stint and team are all 
-- null, and the WHIP is 3*(Total(Hits)+Total(BB))/Total(IPOUTS) 
-- where the Total is the sum of all rows in the Pitching table.
INSERT INTO
    pitchinganalytics (playerid, stint, yearid, teamid, WHIP)
VALUES
    (
        'Totals',
        NULL,
        NULL,
        NULL,
        (
            SELECT
                3 * (sum(h) + sum(bb)) / sum(ipouts)
            FROM
                pitching
        )
    );