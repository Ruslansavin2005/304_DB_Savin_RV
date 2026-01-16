<?php
/**
 * Web application for displaying students list
 * Task 7 - Web version with template engine (alternative PHP syntax)
 */

// Database configuration
$dbPath = __DIR__ . '/students.db';
$currentYear = (int)date('Y');

// Initialize variables
$students = [];
$activeGroups = [];
$selectedGroup = null;
$error = null;

try {
    // Connect to database
    $pdo = new PDO('sqlite:' . $dbPath);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Get all active group numbers from database
    $stmt = $pdo->prepare("
        SELECT DISTINCT g.group_number 
        FROM groups g 
        WHERE g.graduation_year >= :current_year 
        ORDER BY g.group_number
    ");
    $stmt->execute(['current_year' => $currentYear]);
    $activeGroups = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    // Process form submission
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['group_number'])) {
        $selectedGroup = $_POST['group_number'];
        
        // Validate selected group
        if (!empty($selectedGroup) && !in_array($selectedGroup, $activeGroups)) {
            $error = "Invalid group number selected.";
        }
    }
    
    // Build query
    $query = "
        SELECT 
            g.group_number,
            s.name AS specialization_name,
            st.last_name || ' ' || st.first_name || ' ' || COALESCE(st.middle_name, '') AS full_name,
            CASE st.gender 
                WHEN 'male' THEN 'Мужской'
                WHEN 'female' THEN 'Женский'
            END AS gender_display,
            st.birth_date,
            st.student_id
        FROM students st
        INNER JOIN groups g ON st.group_id = g.id
        INNER JOIN specializations s ON g.specialization_id = s.id
        WHERE g.graduation_year >= :current_year
    ";
    
    $params = ['current_year' => $currentYear];
    
    if (!empty($selectedGroup)) {
        $query .= " AND g.group_number = :group_number";
        $params['group_number'] = $selectedGroup;
    }
    
    $query .= " ORDER BY g.group_number, st.last_name, st.first_name";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
} catch (PDOException $e) {
    $error = "Database error: " . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Список студентов</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            padding: 30px;
        }
        
        h1 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2em;
        }
        
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        
        .filter-form {
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        label {
            font-weight: bold;
            color: #555;
        }
        
        select {
            padding: 10px 15px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            min-width: 200px;
            background: white;
            cursor: pointer;
        }
        
        select:hover {
            border-color: #667eea;
        }
        
        select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        button {
            padding: 10px 25px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background 0.3s;
        }
        
        button:hover {
            background: #5568d3;
        }
        
        .error {
            background: #fee;
            color: #c33;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #c33;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
        }
        
        thead {
            background: #667eea;
            color: white;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        tbody tr:last-child td {
            border-bottom: none;
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 18px;
        }
        
        .stats {
            margin-top: 20px;
            padding: 15px;
            background: #e8f4f8;
            border-radius: 5px;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Список студентов</h1>
        
        <?php if ($error !== null): ?>
            <div class="error">
                <?= htmlspecialchars($error) ?>
            </div>
        <?php endif; ?>
        
        <div class="filter-section">
            <form method="POST" class="filter-form">
                <label for="group_number">Фильтр по группе:</label>
                <select name="group_number" id="group_number">
                    <option value="">Все группы</option>
                    <?php foreach ($activeGroups as $groupNumber): ?>
                        <option value="<?= htmlspecialchars($groupNumber) ?>" 
                                <?= ($selectedGroup === $groupNumber) ? 'selected' : '' ?>>
                            <?= htmlspecialchars($groupNumber) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
                <button type="submit">Показать</button>
            </form>
        </div>
        
        <?php if (!empty($students)): ?>
            <div class="stats">
                Найдено студентов: <?= count($students) ?>
                <?php if ($selectedGroup): ?>
                    (группа <?= htmlspecialchars($selectedGroup) ?>)
                <?php endif; ?>
            </div>
            
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Номер группы</th>
                            <th>Направление подготовки</th>
                            <th>ФИО</th>
                            <th>Пол</th>
                            <th>Дата рождения</th>
                            <th>Студенческий билет</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($students as $student): ?>
                            <tr>
                                <td><?= htmlspecialchars($student['group_number']) ?></td>
                                <td><?= htmlspecialchars($student['specialization_name']) ?></td>
                                <td><?= htmlspecialchars($student['full_name']) ?></td>
                                <td><?= htmlspecialchars($student['gender_display']) ?></td>
                                <td><?= htmlspecialchars($student['birth_date']) ?></td>
                                <td><?= htmlspecialchars($student['student_id']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php else: ?>
            <div class="no-data">
                Студенты не найдены.
            </div>
        <?php endif; ?>
    </div>
</body>
</html>

