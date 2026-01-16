#!/bin/bash

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, исключить пары с самим собой. В списке оставить первые 100 записей."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON u1.id = r1.user_id JOIN users u2 ON u2.id = r2.user_id JOIN movies m ON m.id = r1.movie_id ORDER BY m.title, user1, user2 LIMIT 100;"
echo " "

echo "2. 10 самых свежих оценок от разных пользователей: фильм, пользователь, оценка, дата (ГГГГ-ММ-ДД)."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp DESC) AS rn FROM ratings r) SELECT m.title, u.name, r.rating, date(r.timestamp, 'unixepoch') AS rating_date FROM ranked r JOIN users u ON u.id = r.user_id JOIN movies m ON m.id = r.movie_id WHERE r.rn = 1 ORDER BY r.timestamp DESC LIMIT 10;"
echo " "

echo "3. Фильмы с максимальным и минимальным средним рейтингом в одном списке. Колонка 'Рекомендуем' = 'Да' для максимального, 'Нет' для минимального."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH avg_by_movie AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year), bounds AS (SELECT MAX(avg_rating) AS max_avg, MIN(avg_rating) AS min_avg FROM avg_by_movie) SELECT a.title, a.year, ROUND(a.avg_rating, 3) AS avg_rating, 'Да' AS \"Рекомендуем\" FROM avg_by_movie a, bounds b WHERE a.avg_rating = b.max_avg UNION ALL SELECT a.title, a.year, ROUND(a.avg_rating, 3) AS avg_rating, 'Нет' AS \"Рекомендуем\" FROM avg_by_movie a, bounds b WHERE a.avg_rating = b.min_avg ORDER BY year, title;"
echo " "

echo "4. Количество оценок и средняя оценка от женщин за период 2010-2012 гг."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS ratings_count, ROUND(AVG(r.rating), 3) AS avg_rating FROM ratings r JOIN users u ON u.id = r.user_id WHERE u.gender = 'female' AND date(r.timestamp, 'unixepoch') BETWEEN '2010-01-01' AND '2012-12-31';"
echo " "

echo "5. Список фильмов с их средней оценкой и местом в рейтинге по средней оценке. Отсортировать по году и названию. Показать первые 20."
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH avg_by_movie AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year), ranked AS (SELECT id, title, year, avg_rating, DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS rank_pos FROM avg_by_movie) SELECT title, year, ROUND(avg_rating, 3) AS avg_rating, rank_pos FROM ranked ORDER BY year, title LIMIT 20;"
echo " "

echo "6. 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации'"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT (substr(u.name, instr(u.name, ' ') + 1) || ' ' || substr(u.name, 1, instr(u.name, ' ') - 1) || '|' || u.register_date) AS user_line FROM users u WHERE instr(u.name, ' ') > 0 ORDER BY u.register_date DESC LIMIT 10;"
echo " "

echo "7. Рекурсивный CTE: таблица умножения 1..10"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE a(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM a WHERE n < 10), b(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM b WHERE n < 10) SELECT printf('%dx%d=%d', a.n, b.n, a.n*b.n) AS line FROM a CROSS JOIN b ORDER BY a.n, b.n;"
echo " "

echo "8. Рекурсивный CTE: выделить все жанры из movies (каждый жанр отдельной строкой)"
echo "--------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(movie_id, rest, genre) AS (SELECT m.id, m.genres || '|', '' FROM movies m UNION ALL SELECT movie_id, substr(rest, instr(rest, '|') + 1), substr(rest, 1, instr(rest, '|') - 1) FROM split WHERE rest <> '') SELECT DISTINCT genre FROM split WHERE genre <> '' ORDER BY genre;"
echo " "

# После добавления в индекс сделайте файл исполняемым для Linux:
# git update-index --chmod=+x task4.bat


