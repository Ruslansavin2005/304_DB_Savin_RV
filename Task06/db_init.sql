-- Database initialization script for student academic performance tracking
-- Факультет математики и информационных технологий
PRAGMA foreign_keys = ON;

-- Drop existing tables (in reverse order of dependencies)
DROP TABLE IF EXISTS credits;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS student_groups;
DROP TABLE IF EXISTS curriculum;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS disciplines;
DROP TABLE IF EXISTS academic_years;
DROP TABLE IF EXISTS directions;

-- Create reference tables

-- Направления подготовки
CREATE TABLE directions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  degree_level TEXT NOT NULL CHECK (degree_level IN ('бакалавриат', 'магистратура', 'специалитет'))
);

-- Учебные годы
CREATE TABLE academic_years (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year_start INTEGER NOT NULL,
  year_end INTEGER NOT NULL,
  label TEXT NOT NULL UNIQUE,
  CHECK (year_end = year_start + 1)
);

-- Дисциплины
CREATE TABLE disciplines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  lecture_hours INTEGER NOT NULL DEFAULT 0 CHECK (lecture_hours >= 0),
  practical_hours INTEGER NOT NULL DEFAULT 0 CHECK (practical_hours >= 0),
  assessment_type TEXT NOT NULL CHECK (assessment_type IN ('экзамен', 'зачет'))
);

-- Группы (базовый номер группы и направление)
CREATE TABLE groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_number INTEGER NOT NULL,
  direction_id INTEGER NOT NULL,
  start_year INTEGER NOT NULL,
  UNIQUE(base_number, direction_id, start_year),
  FOREIGN KEY (direction_id) REFERENCES directions(id) ON DELETE RESTRICT
);

-- Студенты
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  middle_name TEXT,
  birth_date DATE NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('М', 'Ж')),
  created_at DATETIME NOT NULL DEFAULT (datetime('now'))
);

-- Учебный план (связь направлений и дисциплин)
CREATE TABLE curriculum (
  direction_id INTEGER NOT NULL,
  discipline_id INTEGER NOT NULL,
  semester INTEGER NOT NULL CHECK (semester >= 1 AND semester <= 12),
  PRIMARY KEY (direction_id, discipline_id, semester),
  FOREIGN KEY (direction_id) REFERENCES directions(id) ON DELETE CASCADE,
  FOREIGN KEY (discipline_id) REFERENCES disciplines(id) ON DELETE RESTRICT
);

-- История групп студентов (привязка студента к группе в учебном году)
CREATE TABLE student_groups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  group_id INTEGER NOT NULL,
  academic_year_id INTEGER NOT NULL,
  UNIQUE(student_id, academic_year_id),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE RESTRICT,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT
);

-- Экзамены
CREATE TABLE exams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  discipline_id INTEGER NOT NULL,
  academic_year_id INTEGER NOT NULL,
  grade INTEGER NOT NULL CHECK (grade >= 2 AND grade <= 5),
  exam_date DATE NOT NULL DEFAULT (date('now')),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (discipline_id) REFERENCES disciplines(id) ON DELETE RESTRICT,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
  UNIQUE(student_id, discipline_id, academic_year_id)
);

-- Зачеты
CREATE TABLE credits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  discipline_id INTEGER NOT NULL,
  academic_year_id INTEGER NOT NULL,
  is_passed INTEGER NOT NULL DEFAULT 1 CHECK (is_passed IN (0, 1)),
  credit_date DATE NOT NULL DEFAULT (date('now')),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (discipline_id) REFERENCES disciplines(id) ON DELETE RESTRICT,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
  UNIQUE(student_id, discipline_id, academic_year_id)
);

-- Create indexes for performance
CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_students_birth_date ON students(birth_date);
CREATE INDEX idx_exams_student ON exams(student_id);
CREATE INDEX idx_exams_discipline ON exams(discipline_id);
CREATE INDEX idx_exams_academic_year ON exams(academic_year_id);
CREATE INDEX idx_credits_student ON credits(student_id);
CREATE INDEX idx_credits_discipline ON credits(discipline_id);
CREATE INDEX idx_student_groups_student ON student_groups(student_id);
CREATE INDEX idx_student_groups_group ON student_groups(group_id);

-- Insert reference data
BEGIN;

-- Направления подготовки
INSERT INTO directions (name, degree_level) VALUES 
  ('Прикладная математика и информатика', 'бакалавриат'),
  ('Математика и компьютерные науки', 'бакалавриат'),
  ('Информатика и вычислительная техника', 'бакалавриат'),
  ('Прикладная математика и информатика', 'магистратура'),
  ('Математика', 'бакалавриат');

-- Учебные годы
INSERT INTO academic_years (year_start, year_end, label) VALUES
  (2020, 2021, '2020/2021'),
  (2021, 2022, '2021/2022'),
  (2022, 2023, '2022/2023'),
  (2023, 2024, '2023/2024');

-- Дисциплины
INSERT INTO disciplines (name, lecture_hours, practical_hours, assessment_type) VALUES
  ('Базы данных', 36, 36, 'экзамен'),
  ('Математический анализ', 72, 72, 'экзамен'),
  ('Алгебра и геометрия', 54, 54, 'экзамен'),
  ('Программирование', 36, 72, 'экзамен'),
  ('Дискретная математика', 36, 36, 'экзамен'),
  ('Операционные системы', 36, 36, 'зачет'),
  ('Компьютерные сети', 36, 36, 'зачет'),
  ('Веб-программирование', 18, 54, 'зачет'),
  ('Теория вероятностей', 54, 54, 'экзамен'),
  ('Машинное обучение', 36, 36, 'экзамен');

-- Группы
INSERT INTO groups (base_number, direction_id, start_year) VALUES
  (303, 1, 2020),  -- ПМИ, бакалавриат, группа 303 (2020/2021), 403 (2021/2022), 503 (2022/2023)
  (304, 1, 2020),  -- ПМИ, бакалавриат, группа 304
  (301, 2, 2020),  -- МКН, бакалавриат, группа 301
  (401, 1, 2021),  -- ПМИ, бакалавриат, новая группа 2021 года
  (501, 1, 2022);  -- ПМИ, бакалавриат, новая группа 2022 года

-- Студенты
INSERT INTO students (first_name, last_name, middle_name, birth_date, gender) VALUES
  ('Иван', 'Иванов', 'Иванович', '2002-05-15', 'М'),
  ('Мария', 'Петрова', 'Сергеевна', '2002-08-20', 'Ж'),
  ('Александр', 'Сидоров', 'Александрович', '2002-03-10', 'М'),
  ('Елена', 'Козлова', 'Владимировна', '2002-11-25', 'Ж'),
  ('Дмитрий', 'Новиков', 'Петрович', '2002-07-08', 'М'),
  ('Анна', 'Морозова', 'Андреевна', '2002-01-30', 'Ж'),
  ('Сергей', 'Волков', 'Игоревич', '2002-09-12', 'М'),
  ('Ольга', 'Лебедева', 'Николаевна', '2002-04-18', 'Ж'),
  ('Павел', 'Семенов', 'Дмитриевич', '2002-06-22', 'М'),
  ('Татьяна', 'Егорова', 'Викторовна', '2002-12-05', 'Ж'),
  ('Никита', 'Павлов', 'Сергеевич', '2003-02-14', 'М'),
  ('Юлия', 'Козлова', 'Александровна', '2003-10-08', 'Ж');

-- Учебный план для направления "Прикладная математика и информатика" (id=1)
INSERT INTO curriculum (direction_id, discipline_id, semester) VALUES
  -- 1 семестр
  (1, 2, 1),  -- Математический анализ
  (1, 3, 1),  -- Алгебра и геометрия
  (1, 4, 1),  -- Программирование
  -- 2 семестр
  (1, 2, 2),  -- Математический анализ (продолжение)
  (1, 3, 2),  -- Алгебра и геометрия (продолжение)
  (1, 4, 2),  -- Программирование (продолжение)
  (1, 5, 2),  -- Дискретная математика
  -- 3 семестр
  (1, 1, 3),  -- Базы данных
  (1, 5, 3),  -- Дискретная математика (продолжение)
  (1, 6, 3),  -- Операционные системы
  (1, 9, 3),  -- Теория вероятностей
  -- 4 семестр
  (1, 1, 4),  -- Базы данных (продолжение)
  (1, 7, 4),  -- Компьютерные сети
  (1, 8, 4),  -- Веб-программирование
  (1, 9, 4),  -- Теория вероятностей (продолжение)
  -- 5 семестр
  (1, 10, 5); -- Машинное обучение

-- История групп студентов (2020/2021 учебный год)
INSERT INTO student_groups (student_id, group_id, academic_year_id) VALUES
  (1, 1, 1),  -- Иванов в группе 303
  (2, 1, 1),  -- Петрова в группе 303
  (3, 1, 1),  -- Сидоров в группе 303
  (4, 2, 1),  -- Козлова в группе 304
  (5, 2, 1),  -- Новиков в группе 304
  (6, 2, 1);  -- Морозова в группе 304

-- История групп студентов (2021/2022 учебный год)
INSERT INTO student_groups (student_id, group_id, academic_year_id) VALUES
  (1, 1, 2),  -- Иванов в группе 403 (базовая группа 303, год +1)
  (2, 1, 2),  -- Петрова в группе 403
  (3, 1, 2),  -- Сидоров в группе 403
  (4, 2, 2),  -- Козлова в группе 404
  (5, 2, 2),  -- Новиков в группе 404
  (6, 2, 2),  -- Морозова в группе 404
  (7, 4, 2),  -- Волков в новой группе 401
  (8, 4, 2);  -- Лебедева в новой группе 401

-- История групп студентов (2022/2023 учебный год)
INSERT INTO student_groups (student_id, group_id, academic_year_id) VALUES
  (1, 1, 3),  -- Иванов в группе 503
  (2, 1, 3),  -- Петрова в группе 503
  (3, 1, 3),  -- Сидоров в группе 503
  (4, 2, 3),  -- Козлова в группе 504
  (5, 2, 3),  -- Новиков в группе 504
  (6, 2, 3),  -- Морозова в группе 504
  (7, 4, 3),  -- Волков в группе 501
  (8, 4, 3),  -- Лебедева в группе 501
  (9, 5, 3),  -- Семенов в новой группе 501
  (10, 5, 3); -- Егорова в новой группе 501

-- Экзамены (2020/2021 учебный год)
INSERT INTO exams (student_id, discipline_id, academic_year_id, grade, exam_date) VALUES
  -- Группа 303
  (1, 2, 1, 5, '2021-01-15'),  -- Иванов: Математический анализ - 5
  (1, 3, 1, 4, '2021-01-20'),  -- Иванов: Алгебра и геометрия - 4
  (1, 4, 1, 5, '2021-01-25'),  -- Иванов: Программирование - 5
  (2, 2, 1, 4, '2021-01-15'),  -- Петрова: Математический анализ - 4
  (2, 3, 1, 4, '2021-01-20'),  -- Петрова: Алгебра и геометрия - 4
  (2, 4, 1, 5, '2021-01-25'),  -- Петрова: Программирование - 5
  (3, 2, 1, 3, '2021-01-15'),  -- Сидоров: Математический анализ - 3
  (3, 3, 1, 3, '2021-01-20'),  -- Сидоров: Алгебра и геометрия - 3
  (3, 4, 1, 4, '2021-01-25'),  -- Сидоров: Программирование - 4
  -- Группа 304
  (4, 2, 1, 5, '2021-01-16'),  -- Козлова: Математический анализ - 5
  (4, 3, 1, 5, '2021-01-21'),  -- Козлова: Алгебра и геометрия - 5
  (4, 4, 1, 5, '2021-01-26'),  -- Козлова: Программирование - 5
  (5, 2, 1, 2, '2021-01-16'),  -- Новиков: Математический анализ - 2
  (5, 3, 1, 3, '2021-01-21'),  -- Новиков: Алгебра и геометрия - 3
  (5, 4, 1, 3, '2021-01-26'),  -- Новиков: Программирование - 3
  (6, 2, 1, 4, '2021-01-16'),  -- Морозова: Математический анализ - 4
  (6, 3, 1, 4, '2021-01-21'),  -- Морозова: Алгебра и геометрия - 4
  (6, 4, 1, 4, '2021-01-26');  -- Морозова: Программирование - 4

-- Экзамены (2021/2022 учебный год)
INSERT INTO exams (student_id, discipline_id, academic_year_id, grade, exam_date) VALUES
  -- Группа 403 (бывшая 303)
  (1, 2, 2, 5, '2022-01-15'),  -- Иванов: Математический анализ - 5
  (1, 5, 2, 5, '2022-01-20'),  -- Иванов: Дискретная математика - 5
  (2, 2, 2, 4, '2022-01-15'),  -- Петрова: Математический анализ - 4
  (2, 5, 2, 4, '2022-01-20'),  -- Петрова: Дискретная математика - 4
  (3, 2, 2, 4, '2022-01-15'),  -- Сидоров: Математический анализ - 4
  (3, 5, 2, 3, '2022-01-20'),  -- Сидоров: Дискретная математика - 3
  -- Группа 404 (бывшая 304)
  (4, 2, 2, 5, '2022-01-16'),  -- Козлова: Математический анализ - 5
  (4, 5, 2, 5, '2022-01-21'),  -- Козлова: Дискретная математика - 5
  (5, 2, 2, 3, '2022-01-16'),  -- Новиков: Математический анализ - 3
  (5, 5, 2, 3, '2022-01-21'),  -- Новиков: Дискретная математика - 3
  (6, 2, 2, 5, '2022-01-16'),  -- Морозова: Математический анализ - 5
  (6, 5, 2, 4, '2022-01-21'),  -- Морозова: Дискретная математика - 4
  -- Группа 401 (новая)
  (7, 2, 2, 4, '2022-01-17'),  -- Волков: Математический анализ - 4
  (7, 5, 2, 4, '2022-01-22'),  -- Волков: Дискретная математика - 4
  (8, 2, 2, 5, '2022-01-17'),  -- Лебедева: Математический анализ - 5
  (8, 5, 2, 5, '2022-01-22');  -- Лебедева: Дискретная математика - 5

-- Экзамены (2022/2023 учебный год)
INSERT INTO exams (student_id, discipline_id, academic_year_id, grade, exam_date) VALUES
  -- Группа 503 (бывшая 303)
  (1, 1, 3, 5, '2023-01-15'),  -- Иванов: Базы данных - 5
  (1, 9, 3, 5, '2023-01-20'),  -- Иванов: Теория вероятностей - 5
  (2, 1, 3, 4, '2023-01-15'),  -- Петрова: Базы данных - 4
  (2, 9, 3, 4, '2023-01-20'),  -- Петрова: Теория вероятностей - 4
  (3, 1, 3, 4, '2023-01-15'),  -- Сидоров: Базы данных - 4
  (3, 9, 3, 3, '2023-01-20'),  -- Сидоров: Теория вероятностей - 3
  -- Группа 504 (бывшая 304)
  (4, 1, 3, 5, '2023-01-16'),  -- Козлова: Базы данных - 5
  (4, 9, 3, 5, '2023-01-21'),  -- Козлова: Теория вероятностей - 5
  (5, 1, 3, 3, '2023-01-16'),  -- Новиков: Базы данных - 3
  (5, 9, 3, 3, '2023-01-21'),  -- Новиков: Теория вероятностей - 3
  (6, 1, 3, 5, '2023-01-16'),  -- Морозова: Базы данных - 5
  (6, 9, 3, 4, '2023-01-21'),  -- Морозова: Теория вероятностей - 4
  -- Группа 501 (новая)
  (9, 1, 3, 4, '2023-01-18'),  -- Семенов: Базы данных - 4
  (9, 9, 3, 4, '2023-01-23'),  -- Семенов: Теория вероятностей - 4
  (10, 1, 3, 5, '2023-01-18'), -- Егорова: Базы данных - 5
  (10, 9, 3, 5, '2023-01-23'); -- Егорова: Теория вероятностей - 5

-- Зачеты (2020/2021 учебный год)
INSERT INTO credits (student_id, discipline_id, academic_year_id, is_passed, credit_date) VALUES
  (1, 6, 1, 1, '2021-06-10'),  -- Иванов: Операционные системы - зачет
  (2, 6, 1, 1, '2021-06-10'),  -- Петрова: Операционные системы - зачет
  (3, 6, 1, 1, '2021-06-10');  -- Сидоров: Операционные системы - зачет

-- Зачеты (2021/2022 учебный год)
INSERT INTO credits (student_id, discipline_id, academic_year_id, is_passed, credit_date) VALUES
  (1, 7, 2, 1, '2022-06-10'),  -- Иванов: Компьютерные сети - зачет
  (1, 8, 2, 1, '2022-06-15'),  -- Иванов: Веб-программирование - зачет
  (2, 7, 2, 1, '2022-06-10'),  -- Петрова: Компьютерные сети - зачет
  (2, 8, 2, 1, '2022-06-15'),  -- Петрова: Веб-программирование - зачет
  (3, 7, 2, 1, '2022-06-10'),  -- Сидоров: Компьютерные сети - зачет
  (3, 8, 2, 0, '2022-06-15'),  -- Сидоров: Веб-программирование - незачет
  (4, 7, 2, 1, '2022-06-11'),  -- Козлова: Компьютерные сети - зачет
  (4, 8, 2, 1, '2022-06-16'),  -- Козлова: Веб-программирование - зачет
  (5, 7, 2, 0, '2022-06-11'),  -- Новиков: Компьютерные сети - незачет
  (5, 8, 2, 0, '2022-06-16'),  -- Новиков: Веб-программирование - незачет
  (6, 7, 2, 1, '2022-06-11'),  -- Морозова: Компьютерные сети - зачет
  (6, 8, 2, 1, '2022-06-16'),  -- Морозова: Веб-программирование - зачет
  (7, 7, 2, 1, '2022-06-12'),  -- Волков: Компьютерные сети - зачет
  (7, 8, 2, 1, '2022-06-17'),  -- Волков: Веб-программирование - зачет
  (8, 7, 2, 1, '2022-06-12'),  -- Лебедева: Компьютерные сети - зачет
  (8, 8, 2, 1, '2022-06-17');  -- Лебедева: Веб-программирование - зачет

-- Зачеты (2022/2023 учебный год)
INSERT INTO credits (student_id, discipline_id, academic_year_id, is_passed, credit_date) VALUES
  (1, 6, 3, 1, '2023-06-10'),  -- Иванов: Операционные системы - зачет
  (2, 6, 3, 1, '2023-06-10'),  -- Петрова: Операционные системы - зачет
  (3, 6, 3, 1, '2023-06-10'),  -- Сидоров: Операционные системы - зачет
  (4, 6, 3, 1, '2023-06-11'),  -- Козлова: Операционные системы - зачет
  (5, 6, 3, 0, '2023-06-11'),  -- Новиков: Операционные системы - незачет
  (6, 6, 3, 1, '2023-06-11'),  -- Морозова: Операционные системы - зачет
  (9, 6, 3, 1, '2023-06-12'),  -- Семенов: Операционные системы - зачет
  (10, 6, 3, 1, '2023-06-12'); -- Егорова: Операционные системы - зачет

COMMIT;

