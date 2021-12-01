<?php
include 'db.php';

$json = file_get_contents('php://input');

$obj = json_decode($json,true);

$userid = $obj['userid'];

$query = "select * from friend where userid = '$userid';";

$result = mysqli_query($db,$query);


$friend_list = array();
while($row = mysqli_fetch_array($result,MYSQLI_ASSOC)){
    $friend_list[] = $row;
}

echo json_encode($friend_list);

mysqli_close($db);

?>