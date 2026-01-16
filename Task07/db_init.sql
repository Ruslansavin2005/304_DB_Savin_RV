-- Database initialization script for students management system
-- SQLite database

PRAGMA foreign_keys = ON;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS specializations;

-- Create specializations table (направления подготовки)
CREATE TABLE specializations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- Create groups table (группы)
CREATE TABLE groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_number TEXT NOT NULL,
    specialization_id INTEGER NOT NULL,
    graduation_year INTEGER NOT NULL,
    FOREIGN KEY (specialization_id) REFERENCES specializations(id),
    UNIQUE(group_number, graduation_year)
);

-- Create students table (студенты)
CREATE TABLE students (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    middle_name TEXT,
    gender TEXT NOT NULL CHECK(gender IN ('male', 'female')),
    birth_date TEXT NOT NULL,
    student_id TEXT NOT NULL UNIQUE,
    group_id INTEGER NOT NULL,
    FOREIGN KEY (group_id) REFERENCES groups(id)
);

-- Insert test data
BEGIN;

-- Insert specializations
INSERT INTO specializations (name) VALUES 
    ('Прикладная математика и информатика'),
    ('Математика и компьютерные науки'),
    ('Информатика и вычислительная техника'),
    ('Программная инженерия');

-- Insert groups
-- Group 303, graduation year 2025
INSERT INTO groups (group_number, specialization_id, graduation_year) VALUES 
    ('303', 1, 2025),
    ('304', 1, 2025),
    ('403', 1, 2024),
    ('404', 1, 2024),
    ('503', 2, 2023),
    ('504', 2, 2023);

-- Insert students
-- Students in group 303
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Иван', 'Иванов', 'Иванович', 'male', '2003-05-15', 'ST-2021-001', 1),
    ('Мария', 'Петрова', 'Сергеевна', 'female', '2003-08-20', 'ST-2021-002', 1),
    ('Александр', 'Сидоров', 'Александрович', 'male', '2003-03-10', 'ST-2021-003', 1),
    ('Елена', 'Козлова', 'Владимировна', 'female', '2003-11-25', 'ST-2021-004', 1),
    ('Дмитрий', 'Новиков', 'Дмитриевич', 'male', '2003-07-08', 'ST-2021-005', 1);

-- Students in group 304
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Анна', 'Морозова', 'Андреевна', 'female', '2003-04-12', 'ST-2021-006', 2),
    ('Сергей', 'Волков', 'Сергеевич', 'male', '2003-09-18', 'ST-2021-007', 2),
    ('Ольга', 'Соколова', 'Игоревна', 'female', '2003-12-05', 'ST-2021-008', 2),
    ('Павел', 'Лебедев', 'Павлович', 'male', '2003-06-22', 'ST-2021-009', 2);

-- Students in group 403
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Николай', 'Семенов', 'Николаевич', 'male', '2002-02-14', 'ST-2020-001', 3),
    ('Татьяна', 'Егорова', 'Татьяновна', 'female', '2002-10-30', 'ST-2020-002', 3),
    ('Андрей', 'Павлов', 'Андреевич', 'male', '2002-05-19', 'ST-2020-003', 3);

-- Students in group 404
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Екатерина', 'Козлова', 'Екатериновна', 'female', '2002-08-07', 'ST-2020-004', 4),
    ('Игорь', 'Степанов', 'Игоревич', 'male', '2002-01-25', 'ST-2020-005', 4);

-- Students in group 503
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Виктор', 'Николаев', 'Викторович', 'male', '2001-03-17', 'ST-2019-001', 5),
    ('Юлия', 'Орлова', 'Юрьевна', 'female', '2001-07-11', 'ST-2019-002', 5);

-- Students in group 504
INSERT INTO students (first_name, last_name, middle_name, gender, birth_date, student_id, group_id) VALUES
    ('Роман', 'Андреев', 'Романович', 'male', '2001-11-28', 'ST-2019-003', 6),
    ('Наталья', 'Макарова', 'Натальевна', 'female', '2001-04-09', 'ST-2019-004', 6);

COMMIT;

-- Create indexes for better performance
CREATE INDEX idx_students_group_id ON students(group_id);
CREATE INDEX idx_students_last_name ON students(last_name);
CREATE INDEX idx_groups_group_number ON groups(group_number);
CREATE INDEX idx_groups_graduation_year ON groups(graduation_year);

