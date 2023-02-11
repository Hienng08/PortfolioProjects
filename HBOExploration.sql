/*

This datasets can be found on https://www.kaggle.com/datasets/victorsoeiro/hbo-max-tv-shows-and-movies 
Functions used: Joins, CTE's, Aggregate Functions, Convert Data Types 

*/
--Clean the columns imdb_score and tmdb_score 
SELECT (CAST(imdb_score AS decimal)/10) AS new_imdb_score , (CAST(tmdb_score AS decimal)/10) AS new_tmdb_score
FROM Hbo..HBOtiltes;

--Find the highest imdb_score movies and shows
SELECT title, type, genres, (CAST(imdb_score AS decimal)/10) AS new_imdb_score, imdb_votes 
FROM Hbo..HBOtiltes
WHERE imdb_score  is not null 
ORDER BY imdb_score DESC;


--Find the highest tmdb_score movies and shows
SELECT title, type, genres, (CAST(tmdb_score AS decimal)/10) AS new_tmdb_score
FROM Hbo..HBOtiltes
WHERE tmdb_score is not null 
ORDER BY tmdb_score DESC;


--Find movies and shows with the most number of imdb votes 
SELECT title, type, genres, (CAST(imdb_score AS decimal)/10) AS new_imdb_score, imdb_votes
FROM Hbo..HBOtiltes
WHERE imdb_score  is not null AND imdb_votes is not NULL 
ORDER BY  imdb_votes DESC; 

--Find the shows/movies with the highest total score which equals new_imdb_score * imdb_votes 
SELECT title, type, genres, (CAST(imdb_score AS decimal)/10) AS new_imdb_score, imdb_votes, imdb_votes*(CAST(imdb_score AS decimal)/10) AS total_score
FROM Hbo..HBOtiltes
WHERE imdb_score  is not null AND imdb_votes is not NULL 
ORDER BY   total_score DESC; 
-- The movie The Shawshank Redemption has the highest score 

--Find the shows with the highest total_score 
SELECT title, type, genres, (CAST(imdb_score AS decimal)/10) AS new_imdb_score, imdb_votes, imdb_votes*(CAST(imdb_score AS decimal)/10) AS total_score
FROM Hbo..HBOtiltes
WHERE imdb_score  is not null 
AND imdb_votes is not NULL 
AND type LIKE '%SHOW%'
ORDER BY   total_score DESC; 

--Find the top 5 genres that are most common in the dataset using CTE 
WITH genre_counts AS (
  SELECT genres, COUNT(genres) AS count
  FROM Hbo..HBOtiltes
  WHERE genres IS NOT NULL
  GROUP BY genres
)
SELECT TOP 5 genres, count
FROM genre_counts
ORDER BY count DESC;

--Joins hbo credits and hbo titles table based on the id 
SELECT *
FROM Hbo..HBOtiltes tle 
JOIN Hbo..HBOcredits cre
ON tle.id = cre.id;  

--Find the actors that appear most frequently in HBO movies and shows 
WITH actor_counts AS (
    SELECT name,role, COUNT(name) AS FrequentActor 
    FROM Hbo..HBOtiltes tle 
    JOIN Hbo..HBOcredits cre
    ON tle.id = cre.id 
    WHERE role = 'ACTOR'
    GROUP BY name, role
)
SELECT TOP 5 name,role, FrequentActor
FROM actor_counts
ORDER BY FrequentActor DESC;
