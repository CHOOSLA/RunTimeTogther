<?php

$db_name = "runtime";
$db_server = "mariadb";
$db_user = "root";
$db_pass = "mariadb";

$db = mysqli_connect($db_server,$db_user,$db_pass,$db_name);

if(!$db){
    die("Connection failed".mysqli_error());
}

?>
