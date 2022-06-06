create table Occupations(Name varchar, Occupation varchar);
insert into Occupations values('Samantha', 'Doctor'),('Julia', 'Actor'),
	('Maria', 'Actor'), ('Meera', 'Singer'), ('Ashely', 'Professor'),
	('Ketty', 'Professor'), ('Christeen', 'Professor'), ('Jane','Actor'), 
	('Jenny','Doctor'),('Priya','Singer');

select * from Occupations;

select count(Name) from Occupations group by occupation;
--Pivoting

SELECT a.Occupation,
         a.Name,
         (SELECT COUNT(*) 
            FROM Occupations AS b
            WHERE a.Occupation = b.Occupation AND a.Name > b.Name) AS rank
  FROM Occupations AS a

 select rank, 
 case when occupation = 'Doctor' then Name else NULL end Doctor,
  case when occupation = 'Professor' then Name else NULL end Professor,
   case when occupation = 'Singer' then Name else NULL end Singer,
    case when occupation = 'Actor' then Name else NULL end Actor
  from (SELECT a.Occupation,
         a.Name,
         (SELECT COUNT(*) 
            FROM Occupations AS b
            WHERE a.Occupation = b.Occupation AND a.Name > b.Name) AS rank
  FROM Occupations AS a) as c;
  
 select
 max(case when occupation = 'Doctor' then Name else NULL end) As Doctor,
 max(case when occupation = 'Professor' then Name else NULL end) As Professor,
  max(case when occupation = 'Singer' then Name else NULL end) As Singer,
  max(case when occupation = 'Actor' then Name else NULL end) As Actor
  from (SELECT a.Occupation,
         a.Name,
         (SELECT COUNT(*) 
            FROM Occupations AS b
            WHERE a.Occupation = b.Occupation AND a.Name > b.Name) AS rank
  FROM Occupations AS a) as c group by c.rank;
  
   select
 max(case when occupation = 'Doctor' then Name else NULL end),
 max(case when occupation = 'Professor' then Name else NULL end),
  max(case when occupation = 'Singer' then Name else NULL end),
  max(case when occupation = 'Actor' then Name else NULL end)
  from (SELECT a.Occupation,
         a.Name,
         (SELECT COUNT(*) 
            FROM Occupations AS b
            WHERE a.Occupation = b.Occupation AND a.Name > b.Name) AS rank
  FROM Occupations AS a) as c group by c.rank;
  
SELECT 
MIN(CASE WHEN Occupation = 'Doctor' THEN Name ELSE NULL END) AS Doctor,
MIN(CASE WHEN Occupation = 'Professor' THEN Name ELSE NULL END) AS Professor,
MIN(CASE WHEN Occupation = 'Singer' THEN Name ELSE NULL END) AS Singer,
MIN(CASE WHEN Occupation = 'Actor' THEN Name ELSE NULL END) AS Actor
FROM (
  SELECT a.Occupation,
         a.Name,
         (SELECT COUNT(*) 
            FROM Occupations AS b
            WHERE a.Occupation = b.Occupation AND a.Name > b.Name) AS rank
  FROM Occupations AS a
) AS c
GROUP BY c.rank