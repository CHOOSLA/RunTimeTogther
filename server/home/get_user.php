<?php
include 'db.php';

$json = file_get_contents('php://input');

$obj = json_decode($json,true);

$userid = $obj['userid'];

$query = "select * from user where userid = '$userid';";

$result = mysqli_query($db,$query);


$iamge_list = array();
while($row = mysqli_fetch_array($result,MYSQLI_ASSOC)){
    $image_list[] = $row;
}

echo json_encode($image_list);

mysqli_close($db);

?>