<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];

//Applying User Login query with email and password.
$deleteQuery = "DELETE FROM history where userid='$userid';";

$result = mysqli_query($db,$deleteQuery);

$mgs = '삭제 성공';
$success = json_encode($mgs);
echo $success;

mysqli_close($db);
?>