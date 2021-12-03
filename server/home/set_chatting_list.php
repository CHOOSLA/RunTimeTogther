<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$user_id = $obj['user_id'];
$friend_id = $obj['friend_id'];
$time = $obj['time'];
$context = $obj['context'];


//Applying User Login query with email and password.
$Query = "INSERT INTO chatting VALUES ('$user_id','$friend_id','$time','$context');";

$result = mysqli_query($db,$Query);


$mewdata = "새로운 데이터 ($userid,$friend_id,$time,$context)";
$msg = json_encode($mewdata);
echo $msg; 

mysqli_close($db);
?>