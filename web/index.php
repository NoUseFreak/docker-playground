<?php
//var_dump($_ENV, $_SERVER);die;
try {
    $pdo = new \PDO($_ENV['DB_URI'], $_ENV['DB_USER'], $_ENV['DB_PASS']);
} catch (\PDOException $e) {
    if ($e->getCode() == 1049) {
        $pdo = new \PDO('mysql:host=mysql', 'root', 'root');
        $pdo->exec('CREATE SCHEMA test; USE test;');
        $pdo->exec('CREATE TABLE test (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, `name` varchar(255) DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;');
    }
}

if (isset($_GET['add'])) {
    $pdo->exec('INSERT INTO test (`name`) VALUES ("'.uniqid('', true).'")');

    header('Location: /');
    exit();
}
$stmt = $pdo->query('SELECT * FROM test ORDER BY id DESC');

echo '<pre>';
echo '<a href="/">list</a> ';
echo '<a href="/?add">add</a> ';
echo '<a href="/?env">env</a> ';
echo '<a href="/?info">info</a> ';
echo "\n","\n";

if (isset($_GET['info'])) {
    echo '</pre>';
    phpinfo();
} elseif (isset($_GET['env'])) {
    var_dump($_ENV);
} else {
    while ($row = $stmt->fetch(\PDO::FETCH_ASSOC)) {
        echo $row['id'], "\t", $row['name'], "\n";
    }
}
