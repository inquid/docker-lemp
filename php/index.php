<?php

require 'vendor/autoload.php';


$works = "<p>If you see this, that means it works!</p>\n\n";
echo PHP_SAPI == 'cli' ? strip_tags($works) : $works;

$mdb = new PDO(
    'mysql:host=127.0.0.1;port=3306;dbname=' . (getenv('MYSQL_DATABASE') ?: 'test'),
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: '1234567890'
);

if (PHP_SAPI !== 'cli') echo "<pre>\n";

echo 'MySQL NOW(): ', $mdb->query('SELECT NOW()')->fetchColumn() . "\n";
echo 'PHP: ', phpversion(), "\n\n";

$extensions = get_loaded_extensions();
$extensions = array_map('strtolower', $extensions);

echo "Extensions: ", count($extensions), "\n\n";

sort($extensions);
foreach (array_chunk($extensions, 4) as $exts) {
    foreach ($exts as $ext) {
        echo '- ' . str_pad($ext, 18, ' ', STR_PAD_RIGHT);
    }
    echo "\n";
}

echo PHP_SAPI === 'cli'
    ? "\nSource code: https://github.com/adhocore/docker-lemp\n\n"
    : "</pre>\n\n"
        . 'Source code: <a href="https://github.com/adhocore/docker-lemp" target="_blank">adhocore/docker-lemp</a>'
        . ' | Adminer: <a href="/adminer?server=127.0.0.1%3A3306&username=root" target="_blank">mysql</a>, '
        . "\n";

$user = getenv('MONGODB_USER') ?: 'admin';
$pass = getenv('MONGODB_PASSWORD') ?: '123456';

// MongoDB
$client = new MongoDB\Client("mongodb://${user}:${pass}@localhost:27017");
$collection = $client->demo->beers;
$result = $collection->insertOne(['name' => 'Hinterland', 'brewery' => 'BrewDog']);

echo "Inserted with Object ID '{$result->getInsertedId()}'";
