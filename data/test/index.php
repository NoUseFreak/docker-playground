<?php
echo '<pre>';

try {
    $pdo = new \PDO('mysql:host=mysql;dbname=test', 'root', 'root');
} catch (\PDOException $e) {
    if ($e->getCode() == 1049) {
        $pdo = new \PDO('mysql:host=mysql', 'root', 'root');
        $pdo->exec('CREATE SCHEMA test; USE test;');
        $pdo->exec('CREATE TABLE test (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `name` varchar(255) DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;');
    }
}


$pdo->exec('INSERT INTO test (`name`) VALUES ("'.uniqid('', true).'")');
$stmt = $pdo->query('SELECT * FROM test ORDER BY id DESC');

while ($row = $stmt->fetch(\PDO::FETCH_ASSOC)) {
    echo $row['id'], "\t", $row['name'], "\n";
}
