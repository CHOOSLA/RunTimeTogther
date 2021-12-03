<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];
$time = $obj['time'];
$latitude = $obj['latitude'];
$longitude = $obj['longitude'];


//Applying User Login query with email and password.
$Query = "INSERT INTO history VALUES ('$userid','$time','$latitude','$longitude');";

$result = mysqli_query($db,$Query);


$mewdata = "history 테이블 새로운 데이터 ($userid,$time,$latitude,$longitude)";
$msg = json_encode($mewdata);
echo $msg; 

mysqli_close($db);
?>