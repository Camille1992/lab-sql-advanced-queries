# Lab | SQL Advanced queries
# In this lab, you will be using the Sakila database of movie rentals.

# Instructions
# List each pair of actors that have worked together.
SELECT DISTINCT
	CONCAT(CONCAT(A.last_name, " ", A.first_name), " AND ", CONCAT(B.last_name, " ", B.first_name)) AS pair_of_actors
FROM
	film_actor F 
	INNER JOIN
		actor A
	ON
		F.actor_id = A.actor_id
	INNER JOIN
		actor B
	ON
		A.actor_id <> B.actor_id
ORDER BY
	pair_of_actors ASC;

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

WITH maximum AS (
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
		actor A
	ON
		A.actor_id = FA.actor_id
	LEFT JOIN
		maximum M
	ON
		FA.film_id = M.film_id
GROUP BY
	title
ORDER BY
	title ASC;