# Lecture 3
Noted by: Mark Fuller

#### List all cities of people who were born in Ireland

1. Which table will have our data?

        People

2. Which attributes do we want?

        birthCity

3. What is our filter?

        birthCountry = 'Ireland'


``` sql
select birthCity where birthCountry = 'Irealnd';
```

### To remove duplicates

``` sql
select distinct ...
```

This will treat `null` as all the same value, even though `null != null`

#### List all playerId's  and the total bases for each batter with at least 600 at bats in 2018 

1. Which table will have our data?  Batting

2. Which attributes do we want?

        playerId, yearId, H + 2b + 2 * 3b + 3 * hr

3. What is our filter?

        Ab >= 600


``` sql
select playerId, H + 2b + 2 * 3b + 3 * hr, 
from batting 
where abs >= 600 
and yearId = 2018;
```

### String operations

#### Find first and last names of people ...

``` sql
select concat(nameFirst,' ',nameLast) as fullName
```

#### Wildcards

```sql
select nameFirst from People where nameLast like "%son";
```

### Date Operations

#### Find the number of days a person played

```sql
select datediff(finalGame, debut) ...
```
or
```sql
select ... where datediff(finalGame, debut) > 100;
```
It can be used in either instance.

### If statements

#### Find batting averages of all players on 2018 Tigers

1. Batting
2. h / ab
3. yearid = 2018 and teamId = 'DET'

``` sql
select case when h/ab  is null then 0.000 else h/ab end ...
```
or 
```sql
select coalesce(h/ab, 0) ...
```



