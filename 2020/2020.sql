-- use database
USE baseball;

-- for ease of re running
DROP TABLE IF EXISTS analytics;

-- create index on baseball so we can create foreign key
-- do alter table so that if you do already have an index it does not throw an error
ALTER TABLE
    Batting
ADD
    INDEX (playerID);

-- new batting table contains no nulls
DROP VIEW IF EXISTS BattingNoNulls;

CREATE VIEW BattingNoNulls AS
SELECT
    playerid,
    yearID,
    stint,
    teamID,
    lgID,
    IFNULL(G, 0) AS G,
    IFNULL(AB, 0) AS AB,
    IFNULL(R, 0) AS R,
    IFNULL(H, 0) AS H,
    IFNULL(2B, 0) AS 2B,
    IFNULL(3B, 0) AS 3B,
    IFNULL(HR, 0) AS HR,
    IFNULL(RBI, 0) AS RBI,
    IFNULL(SB, 0) AS SB,
    IFNULL(CS, 0) AS CS,
    IFNULL(BB, 0) AS BB,
    IFNULL(SO, 0) AS SO,
    IFNULL(IBB, 0) AS IBB,
    IFNULL(HBP, 0) AS HBP,
    IFNULL(SH, 0) AS SH,
    IFNULL(SF, 0) AS SF,
    IFNULL(GIDP, 0) AS GIDP
FROM
    Batting;

-- create view for easier RC calculation
DROP VIEW IF EXISTS RCBatting;

CREATE VIEW RCBatting AS
SELECT
    b.playerID,
    b2.teamID,
    b2.yearID,
    b2.stint,
    RC
FROM
    (
        SELECT
            playerId,
            yearid,
            teamID,
            stint,
            -- ifnull only applies if denominator is 0 which surprisignly happends a lot.
            (
                (
                    (
                        SUM(H) + SUM(BB) - SUM(CS) + SUM(HBP) - SUM(GIDP)
                    ) * (SUM(H) + SUM(2B) + (2 * SUM(3B)) + (3 * SUM(HR))) + (0.26 * (SUM(BB) - SUM(IBB) + SUM(HBP))) + 0.52 * (SUM(SH) + SUM(SF) + SUM(SB))
                ) / IF(
                    (SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF) + SUM(SH)) = 0,
                    0.00001,
                    (SUM(AB) + SUM(BB) + SUM(HBP) + SUM(SF) + SUM(SH))
                )
            ) AS RC
        FROM
            BattingNoNulls b
        GROUP BY
            b.playerID,
            b.yearID,
            teamID,
            stint
    ) AS b
    JOIN (
        SELECT
            *
        FROM
            BattingNoNulls
    ) AS b2 USING (playerID, yearID, teamID, stint)
ORDER BY
    playerID,
    teamID,
    yearID,
    RC;

-- create view for easier RC calculation
DROP VIEW IF EXISTS RCPitching;

CREATE VIEW RCPitching AS
SELECT
    b.playerID,
    b2.teamID,
    b2.yearID,
    b2.stint,
    RCPitching
FROM
    (
        SELECT
            playerId,
            yearid,
            teamID,
            stint,
            -- ifnull only applies if denominator is 0 which surprisignly happends a lot.
            (
                (
                    (
                        SUM(H) + SUM(BB) + SUM(HBP) - SUM(GIDP)
                    ) * (SUM(H) + (3 * SUM(HR))) + (0.26 * (SUM(BB) - SUM(IBB) + SUM(HBP))) + 0.52 * (SUM(SH) + SUM(SF))
                ) / IF(
                    (SUM(BB) + SUM(HBP) + SUM(SF) + SUM(SH)) = 0,
                    0.00001,
                    (SUM(BB) + SUM(HBP) + SUM(SF) + SUM(SH))
                )
            ) AS RCPitching
        FROM
            PitchingNoNulls b
        GROUP BY
            b.playerID,
            b.yearID,
            teamID,
            stint
    ) AS b
    JOIN (
        SELECT
            *
        FROM
            PitchingNoNulls
    ) AS b2 USING (playerID, yearID, teamID, stint)
ORDER BY
    playerID,
    teamID,
    yearID,
    RCPitching;

-- analytics table structure
CREATE TABLE Analytics (
    playerID varchar(9),
    yearID int NOT NULL,
    teamID char(3) NOT NULL,
    stint int(11) NOT NULL,
    RC int NOT NULL,
    PARC numeric(10, 6) NOT NULL,
    PARC27 numeric(10, 6) NOT NULL,
    PARCA numeric(10, 6) NOT NULL,
    PRIMARY KEY (playerID, yearID, teamID, stint),
    CONSTRAINT FOREIGN KEY (playerID) REFERENCES Batting(playerID)
) DEFAULT CHARACTER SET = latin1;

INSERT INTO
    Analytics(
        playerID,
        yearID,
        teamID,
        stint,
        RC,
        PARC,
        PARC27,
        PARCA
    )
SELECT
    playerID,
    yearID,
    teamID,
    stint,
    RC,
    PARC,
    PARC / 27,
    0
FROM
    (
        SELECT
            playerID,
            yearID,
            teamID,
            stint,
            RC,
            PARC,
            PARC / 27 AS PARC27,
            0
        FROM
            (
                SELECT
                    playerID,
                    RC AS RC,
                    RC / (BPF + 100) / 2 AS PARC,
                    yearID,
                    teamID,
                    stint
                FROM
                    (
                        SELECT
                            *
                        FROM
                            (
                                SELECT
                                    *
                                FROM
                                    RCPitching
                            ) AS rc
                            JOIN (
                                SELECT
                                    teamID,
                                    BPF,
                                    yearID
                                FROM
                                    Teams
                            ) AS t USING(yearID, teamID)
                    ) AS PARC
            ) AS PARCA
    ) AS p
ORDER BY
    PARC DESC;