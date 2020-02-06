-- Mark Fuller
-- Assignment 8 
USE baseball;

-- 1. Using a subquery in the WHERE clause, find the names of the first 
-- players inducted into the Hall of Fame.
SELECT
    concat(nameFirst, ' ', nameLast)
FROM
    People,
    HallOfFame
WHERE
    HallOfFame.playerId = People.playerId
    AND HallOfFame.yearId = (
        SELECT
            MIN(yearid)
        FROM
            HallOfFame
    );

-- 2. Using a subquery in the WHERE clause, find the names of players 
-- with 3000 or more career hits who are not in the Hall of Fame.
SELECT
    concat(nameFirst, ' ', nameLast)
FROM
    People
WHERE
    People.playerId IN (
        SELECT
            Batting.playerID
        FROM
            Batting
            JOIN HallOfFame USING(playerId)
        WHERE
            inducted = 'n'
        GROUP BY
            playerId
        HAVING
            sum(Batting.H) > 3000
    );

-- 3. Using a Set operator, find the playerid of players with 3000 or 
-- more career hits who are not in the Hall of Fame.
(
    SELECT
        playerId
    FROM
        Batting
    GROUP BY
        Batting.playerID
    HAVING
        sum(Batting.H) >= 3000
)
INTERSECT
(
    SELECT
        playerID
    FROM
        HallOfFame
    WHERE
        inducted = 'n'
);

-- 4. Find the playerid of players who played for both the Anaheim 
-- Angels and the Miami Marlins. Note! It can be in different seasons. 
-- Note! I only want one attribute in the result set.
-- 5. Find the number of players who hit more home runs in a stint 
-- than Babe Ruth hit in a season for each season in Ruth's career. 
-- Include years that Ruth hit the most as 0. Include the year in the 
-- output. Don't worry about years in which Ruth had multiple stints 
-- (he did not have any).