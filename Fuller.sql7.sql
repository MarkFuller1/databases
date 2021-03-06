-- Mark Fuller 
-- Assignment 7 
USE baseball; 

-- 1. Using the JOIN operator with ON, for each active franchise  
-- (TeamsFranchises.active = 'y'), find the number of HallOfFame  
-- players who ever played for the franchise. Include the name of 
--  the franchise in the output. 
SELECT franchname AS FranchiseName, 
       Count(DISTINCT halloffame.playerid) AS NUM_HOF_Players 
FROM   halloffame 
       JOIN appearances 
         ON halloffame.playerid = appearances.playerid 
       JOIN teams 
         ON appearances.teamid = teams.teamid 
       JOIN teamsfranchises 
         ON teams.franchid = teamsfranchises.franchid 
WHERE  teamsfranchises.active = 'y' 
       AND halloffame.inducted = 'y' 
GROUP  BY teamsfranchises.franchname, 
          teamsfranchises.franchid; 

-- 2. Using the JOIN operator with USING, for each active  
-- franchise (TeamsFranchises.active = 'y'), find the number of 
-- HallOfFame players who ever played for the franchise.  
-- Include the name of the franchise in the output. 
SELECT franchname AS FranchiseName, 
       Count(DISTINCT h.playerid) AS NUM_HOF_Players 
FROM   halloffame AS h 
       JOIN appearances using (playerid) 
       JOIN teams using(teamid) 
       JOIN teamsfranchises AS tf using (franchid) 
WHERE  tf.active = 'y' 
       AND h.inducted = 'y' 
GROUP  BY tf.franchname, 
          tf.franchid; 

-- 3. Using the JOIN operator with ON, find the number of  
-- players who hit more home runs in a stint than Babe Ruth  
-- (playerid='ruthba01') hit that season for each season of 
-- his career. Note! Do not worry about seasons where Ruth  
-- hit the most home runs. Also, Ruth was never traded in  
-- season, so you can ignore stints for him. We'll get to  
-- these issues later! 
-- It was hard to interpret if you wanted to sum the stints of the  
-- other players so here is the query assuming yes (below is no) 
SELECT Count(babe_beaters.player) AS babe_beater_count 
FROM   (SELECT DISTINCT other.playerid AS player 
        FROM   batting AS babe 
               JOIN batting AS other 
                 ON ( other.yearid = babe.yearid ) 
        WHERE  babe.playerid = 'ruthba01' 
        GROUP  BY other.playerid, 
                  other.yearid 
        HAVING Sum(babe.hr) < Sum(other.hr) 
        ORDER  BY other.yearid) AS babe_beaters; 

-- And here is the query assuming no 
SELECT Count(DISTINCT other.playerid, other.stint) AS count 
FROM   batting AS babe 
       JOIN batting AS other 
         ON ( other.yearid = babe.yearid 
              AND other.hr > babe.hr ) 
WHERE  babe.playerid = 'ruthba01'
group by other.yearID; 

-- 4. Find the name of all people who did not appear in a 
-- major league baseball game (they are not in the Appearances table). 
SELECT DISTINCT Concat(people.namefirst, ' ', people.namelast)AS NAME 
FROM   people 
       LEFT OUTER JOIN appearances 
                    ON ( people.playerid = appearances.playerid ) 
WHERE  appearances.yearid IS NULL; 