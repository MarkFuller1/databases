-- use database
use baseball;

-- for ease of re running
drop table if exists analytics;

-- create index on baseball so we can create foreign key
-- do alter table so that if you do already have an index it does not throw an error
ALTER TABLE
    batting
ADD
    INDEX (playerID);

-- analytics table structure
create table analytics (
    playerID varchar(9),
    RC int not null,
    PARC numeric(10, 6) not null,
    PARC27 numeric(10, 6) not null,
    PARCA numeric(10, 6) not null,
    PRIMARY KEY (playerID),
    constraint foreign key (playerID) references batting(playerID)
) DEFAULT CHARACTER SET = latin1;

select
    coalesce(
        (H + 2B + (2 * 3B) + (3 * HR)) + ((BB + HBP - IBB) * 0.26) / (SH + SF + SB) * 0.52,
        0
    ) as RC,
    playerid
from
    batting
group by
    playerid
order by
    RC desc;

insert into
    analytics(playerID, RC, PARC, PARC27, PARCA)
select
    RC,
    PARC,
    PARC / 27 as PARC27
from
    (
        select
            f.RC as RC,
            f.RC / (t.BPF + 100) / 200 as PARC
        from
            (
                select
                    playerID,
                    coalesce(
                        (b.H + b.2B + (2 * b.3B) + (3 * b.HR)) + ((b.BB + b.HBP - b.IBB) * 0.26) / (b.SH + b.SF + b.SB) * 0.52,
                        0
                    ) as RC
                from
                    batting
                group by
                    playerID
            ) as f,
            teams as t
    );

select
    *
from
    analytics;