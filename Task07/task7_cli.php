<?php
/**
 * Console PHP script for displaying students list
 * Task 7 - CLI version
 */

// Database configuration
$dbPath = __DIR__ . '/students.db';
$currentYear = (int)date('Y');

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
    
    if (empty($activeGroups)) {
        echo "No active groups found in database.\n";
        exit(1);
    }
    
    // Display available groups
    echo "Available group numbers:\n";
    foreach ($activeGroups as $groupNumber) {
        echo "  - $groupNumber\n";
    }
    echo "\n";
    
    // Get user input
    echo "Enter group number to filter (or press Enter for all groups): ";
    $input = trim(fgets(STDIN));
    
    // Validate input
    $selectedGroup = null;
    if (!empty($input)) {
        if (!in_array($input, $activeGroups)) {
            echo "Error: Invalid group number '$input'. Please run the script again.\n";
            exit(1);
        }
        $selectedGroup = $input;
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
    
    if ($selectedGroup !== null) {
        $query .= " AND g.group_number = :group_number";
        $params['group_number'] = $selectedGroup;
    }
    
    $query .= " ORDER BY g.group_number, st.last_name, st.first_name";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($students)) {
        echo "No students found.\n";
        exit(0);
    }
    
    // Display table with pseudographics
    displayTable($students);
    
} catch (PDOException $e) {
    echo "Database error: " . $e->getMessage() . "\n";
    exit(1);
}

/**
 * Display students data in table format with pseudographics
 */
function displayTable($students) {
    // Calculate column widths
    $widths = [
        'group_number' => max(12, mb_strlen('Номер группы')),
        'specialization_name' => max(40, mb_strlen('Направление подготовки')),
        'full_name' => max(30, mb_strlen('ФИО')),
        'gender_display' => max(6, mb_strlen('Пол')),
        'birth_date' => max(12, mb_strlen('Дата рождения')),
        'student_id' => max(15, mb_strlen('Студенческий билет'))
    ];
    
    foreach ($students as $student) {
        $widths['group_number'] = max($widths['group_number'], mb_strlen($student['group_number']));
        $widths['specialization_name'] = max($widths['specialization_name'], mb_strlen($student['specialization_name']));
        $widths['full_name'] = max($widths['full_name'], mb_strlen($student['full_name']));
        $widths['gender_display'] = max($widths['gender_display'], mb_strlen($student['gender_display']));
        $widths['birth_date'] = max($widths['birth_date'], mb_strlen($student['birth_date']));
        $widths['student_id'] = max($widths['student_id'], mb_strlen($student['student_id']));
    }
    
    // Draw top border
    echo "\n";
    echo "┌" . str_repeat("─", $widths['group_number'] + 2) . 
         "┬" . str_repeat("─", $widths['specialization_name'] + 2) .
         "┬" . str_repeat("─", $widths['full_name'] + 2) .
         "┬" . str_repeat("─", $widths['gender_display'] + 2) .
         "┬" . str_repeat("─", $widths['birth_date'] + 2) .
         "┬" . str_repeat("─", $widths['student_id'] + 2) . "┐\n";
    
    // Draw header
    echo "│ " . str_pad('Номер группы', $widths['group_number'], ' ', STR_PAD_RIGHT) . " │" .
         " " . str_pad('Направление подготовки', $widths['specialization_name'], ' ', STR_PAD_RIGHT) . " │" .
         " " . str_pad('ФИО', $widths['full_name'], ' ', STR_PAD_RIGHT) . " │" .
         " " . str_pad('Пол', $widths['gender_display'], ' ', STR_PAD_RIGHT) . " │" .
         " " . str_pad('Дата рождения', $widths['birth_date'], ' ', STR_PAD_RIGHT) . " │" .
         " " . str_pad('Студенческий билет', $widths['student_id'], ' ', STR_PAD_RIGHT) . " │\n";
    
    // Draw separator
    echo "├" . str_repeat("─", $widths['group_number'] + 2) . 
         "┼" . str_repeat("─", $widths['specialization_name'] + 2) .
         "┼" . str_repeat("─", $widths['full_name'] + 2) .
         "┼" . str_repeat("─", $widths['gender_display'] + 2) .
         "┼" . str_repeat("─", $widths['birth_date'] + 2) .
         "┼" . str_repeat("─", $widths['student_id'] + 2) . "┤\n";
    
    // Draw data rows
    foreach ($students as $student) {
        echo "│ " . str_pad($student['group_number'], $widths['group_number'], ' ', STR_PAD_RIGHT) . " │" .
             " " . str_pad($student['specialization_name'], $widths['specialization_name'], ' ', STR_PAD_RIGHT) . " │" .
             " " . str_pad($student['full_name'], $widths['full_name'], ' ', STR_PAD_RIGHT) . " │" .
             " " . str_pad($student['gender_display'], $widths['gender_display'], ' ', STR_PAD_RIGHT) . " │" .
             " " . str_pad($student['birth_date'], $widths['birth_date'], ' ', STR_PAD_RIGHT) . " │" .
             " " . str_pad($student['student_id'], $widths['student_id'], ' ', STR_PAD_RIGHT) . " │\n";
    }
    
    // Draw bottom border
    echo "└" . str_repeat("─", $widths['group_number'] + 2) . 
         "┴" . str_repeat("─", $widths['specialization_name'] + 2) .
         "┴" . str_repeat("─", $widths['full_name'] + 2) .
         "┴" . str_repeat("─", $widths['gender_display'] + 2) .
         "┴" . str_repeat("─", $widths['birth_date'] + 2) .
         "┴" . str_repeat("─", $widths['student_id'] + 2) . "┘\n";
    echo "\n";
}

