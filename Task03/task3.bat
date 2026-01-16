#!/bin/bash
chcp 65001

# создать и заполнить базу из скрипта
sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year\
FROM movies m\
JOIN ratings r ON r.movie_id = m.id\
GROUP BY m.id, m.title, m.year\
ORDER BY m.year, m.title\
LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT u.id, u.name, u.register_date\
FROM users u\
WHERE substr(u.name, instr(u.name, ' ') + 1, 1) = 'A'\
ORDER BY u.register_date\
LIMIT 5;"
echo " "

echo "3. Запрос, возвращающий информацию о рейтингах: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать по имени эксперта, затем названию фильма и оценке. Оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT u.name AS expert_name, m.title AS movie_title, m.year, r.rating, date(r.timestamp, 'unixepoch') AS rating_date\
FROM ratings r\
JOIN users u   ON u.id = r.user_id\
JOIN movies m  ON m.id = r.movie_id\
ORDER BY u.name, m.title, r.rating\
LIMIT 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year, t.tag\
FROM tags t\
JOIN movies m ON m.id = t.movie_id\
ORDER BY m.year, m.title, t.tag\
LIMIT 40;"
echo " "

echo "5. Вывести список самых свежих фильмов (все фильмы последнего года выпуска). Год определяется автоматически."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
WITH max_year AS (SELECT max(year) AS y FROM movies WHERE year IS NOT NULL)\
SELECT m.title, m.year\
FROM movies m, max_year\
WHERE m.year = max_year.y\
ORDER BY m.title;"
echo " "

echo "6. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма вывести название, год выпуска и количество таких оценок. Отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT m.title, m.year, COUNT(*) AS num_high_ratings\
FROM ratings r\
JOIN users u  ON u.id = r.user_id\
JOIN movies m ON m.id = r.movie_id\
WHERE u.gender = 'male'\
  AND r.rating >= 4.5\
  AND m.year > 2000\
  AND m.genres LIKE '%Comedy%'\
GROUP BY m.id, m.title, m.year\
ORDER BY m.year, m.title;"
echo " "

echo "7. Анализ профессий пользователей: количество пользователей по каждому роду занятий."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS user_count\
FROM users\
GROUP BY occupation\
ORDER BY user_count DESC, occupation;"
echo " "

echo "7a. Самая распространенная профессия"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS user_count\
FROM users\
GROUP BY occupation\
ORDER BY user_count DESC, occupation\
LIMIT 1;"
echo " "

echo "7b. Самая редкая профессия"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "\
SELECT occupation, COUNT(*) AS user_count\
FROM users\
GROUP BY occupation\
ORDER BY user_count ASC, occupation\
LIMIT 1;"
echo " "

# Сделать файл исполняемым в Git (после добавления в индекс):
# git update-index --chmod=+x task3.bat


