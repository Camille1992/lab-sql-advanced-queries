# Lab | SQL Advanced queries
# In this lab, you will be using the Sakila database of movie rentals.

# Instructions
# List each pair of actors that have worked together.

SELECT
	CONCAT(A.name_A, " ", B.name_B) AS pair_of_actor									# optional: , A.film_id, A.actor_id, A.name_A, B.actor_id, B.name_B
FROM
	(
	SELECT
		F.film_id, F.actor_id, CONCAT(A.last_name, " ", A.first_name) AS name_A
	FROM
		film_actor F
        LEFT JOIN
			actor A
		ON
			F.actor_id = A.actor_id
	) AS A
CROSS JOIN
	(
  SELECT
		F.film_id, F.actor_id, CONCAT(A.last_name, " ", A.first_name) AS name_B
	FROM
		film_actor F
        LEFT JOIN
			actor A
		ON
			F.actor_id = A.actor_id
	) AS B
WHERE 
	A.film_id = B.film_id AND  A.actor_id < B.actor_id
ORDER BY
	A.film_id ASC, A.actor_id, B.actor_id;
    
    










SELECT
	F.film_id, FA.actor_id AS actor_A, FB.actor_id AS actor_B
FROM
	film_actor F
    JOIN
		film_actor FA
	USING (actor_id)
    JOIN
		film_actor FB
	USING (actor_id)
GROUP BY
	film_id, FA.actor_id, FB.actor_id;
    
WITH actor_A AS (
	SELECT
		film_id, actor_id
	FROM
		film_actor
	GROUP BY
		film_id, actor_id),
	actor_B AS (
    	SELECT
		film_id, actor_id
	FROM
		film_actor
	GROUP BY
		film_id, actor_id)
SELECT DISTINCT
	F.film_id, A.actor_id, B.actor_id 					#CONCAT(CONCAT(NA.last_name, " ", NA.first_name), " AND ", CONCAT(NB.last_name, " ", NB.first_name)) AS pair_of_actors
FROM
	film_actor F
    INNER JOIN
		actor_A A
	ON
		F.actor_id = A.actor_id
	INNER JOIN
		actor_B B
	ON
		A.actor_id < B.actor_id 
ORDER BY
	F.film_id, A.actor_id, B.actor_id;

WITH actor_A AS (
	SELECT
		F.film_id, F.actor_id, CONCAT(A.last_name, " ", A.first_name) AS name_A
	FROM
		film_actor F
	INNER JOIN
		actor A
	ON
		F.actor_id = A.actor_id
	GROUP BY
		F.film_id, F.actor_id, name_A),
	actor_B AS (
    	SELECT
		F.film_id, F.actor_id, CONCAT(B.last_name, " ", B.first_name) AS name_B
	FROM
		film_actor F
	INNER JOIN
		actor B
	ON
		F.actor_id = B.actor_id
	GROUP BY
		F.film_id, B.actor_id, name_B)
SELECT DISTINCT
	F.film_id, A.actor_id, B.actor_id, CONCAT(name_A, " AND ", name_B) AS pair_of_actors			#CONCAT(CONCAT(NA.last_name, " ", NA.first_name), " AND ", CONCAT(NB.last_name, " ", NB.first_name)) AS pair_of_actors
FROM
	film_actor F
    INNER JOIN
		actor_A A
	ON
		F.actor_id = A.actor_id
	INNER JOIN
		actor_B B
	ON
		A.actor_id < B.actor_id 
WHERE
	A.film_id = B.film_id
ORDER BY
	F.film_id, pair_of_actors, A.actor_id, B.actor_id;															#pair_of_actors ASC;
    
# For each film, list actor that has acted in more films.
# FIRST LET'S CHECK THE MAX PER ACTOR ORDERED BY TITLE NAME
WITH count_actor AS (
	SELECT
		actor_id,
		COUNT(film_id) AS num_films
	FROM
		film_actor
	GROUP BY
		actor_id)
SELECT 
	F.title, CONCAT(A.last_name, " ", A.first_name) AS actor_name, num_films
FROM
	film F
	JOIN
		film_actor FA
	ON
		F.film_id = FA.film_id
	JOIN
		actor A
	ON
		A.actor_id = FA.actor_id
	LEFT JOIN
		count_actor CA
	ON
		CA.actor_id = FA.actor_id
ORDER BY
	title ASC;

# MAX PER FILM ID
SELECT
	film_id,
	MAX(num_films) AS max_per_film
FROM
	(WITH count_actor AS (
	SELECT
		actor_id,
		COUNT(film_id) AS num_films
	FROM
		film_actor
	GROUP BY
		actor_id)
SELECT 
	F.film_id, CONCAT(A.last_name, " ", A.first_name) AS actor_name, num_films
FROM
	film F
	JOIN
		film_actor FA
	ON
		F.film_id = FA.film_id
	JOIN
		actor A
	ON
		A.actor_id = FA.actor_id
	LEFT JOIN
		count_actor CA
	ON
		CA.actor_id = FA.actor_id) AS count_and_film
GROUP BY
	film_id
ORDER BY
	film_id ASC;

# MAX PER ACTOR ORDERED BY FILM TITLE BUT THIS TIME WITH THE ACTOR ID BECAUSE WE NEED IT
WITH count_actor AS (
	SELECT
		actor_id,
		COUNT(film_id) AS num_films
	FROM
		film_actor
	GROUP BY
		actor_id)
SELECT 
	F.title, CA.actor_id, CONCAT(A.last_name, " ", A.first_name) AS actor_name, CA.num_films
FROM
	film F
	JOIN
		film_actor FA
	ON
		F.film_id = FA.film_id
	JOIN
		actor A
	ON
		A.actor_id = FA.actor_id
	LEFT JOIN
		count_actor CA
	ON
		CA.actor_id = FA.actor_id
ORDER BY
	F.title ASC, CA.num_films DESC;


# FINAL QUERY
WITH top_actor AS (
	WITH count_actor AS (
		SELECT
			actor_id,
			COUNT(film_id) AS num_films
		FROM
			film_actor
		GROUP BY
			actor_id)
	SELECT 
		F.title, CA.actor_id, CONCAT(A.last_name, " ", A.first_name) AS actor_name, CA.num_films
	FROM
		film F
		JOIN
			film_actor FA
		ON
			F.film_id = FA.film_id
		JOIN
			actor A
		ON
			A.actor_id = FA.actor_id
		LEFT JOIN
			count_actor CA
		ON
			CA.actor_id = FA.actor_id
	ORDER BY
		F.title ASC, CA.num_films DESC),
	maximum AS (
		SELECT
			film_id,
			MAX(num_films) AS max_per_film
		FROM
			(WITH count_actor AS (
				SELECT
					actor_id,
					COUNT(film_id) AS num_films
				FROM
					film_actor
				GROUP BY
					actor_id)
			SELECT 
				F.film_id, CONCAT(A.last_name, " ", A.first_name) AS actor_name, num_films
			FROM
				film F
				JOIN
					film_actor FA
				ON
					F.film_id = FA.film_id
				JOIN
					actor A
				ON
					A.actor_id = FA.actor_id
				LEFT JOIN
				count_actor CA
	ON
		CA.actor_id = FA.actor_id) AS count_and_film
GROUP BY
	film_id
    )
SELECT 
	F.title, CONCAT(A.last_name, " ", A.first_name) AS actor_name, M.max_per_film
FROM
	film F
	LEFT JOIN
		film_actor FA
	ON
		F.film_id = FA.film_id
    LEFT JOIN
		maximum M
	ON
		FA.film_id = M.film_id            
	LEFT JOIN
		top_actor TA
	ON
		TA.actor_id = FA.actor_id and TA.num_films = M.max_per_film
	INNER JOIN
		actor A
	ON
		A.actor_id = TA.actor_id
GROUP BY
	title, actor_name, M.max_per_film
ORDER BY
	title ASC;