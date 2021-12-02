<?php
include 'db.php';

$json = file_get_contents('php://input');

$obj = json_decode($json,true);

$userid = $obj['userid'];

$query = "select * from user where userid = '$userid';";

$result = mysqli_query($db,$query);

$userdata = mysqli_fetch_array($result,MYSQLI_ASSOC);

echo json_encode($userdata);

mysqli_close($db);

?>