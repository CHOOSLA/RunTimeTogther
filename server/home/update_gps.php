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
$loginQuery = "select * from currentgps where userid = '$userid';";

$result = mysqli_query($db,$loginQuery);


$check = mysqli_fetch_array($result);

if(!isset($check)){
    //Applying User Login query with email and password.
    $insertQuery = "INSERT INTO currentgps VALUES ('$userid','$time','$latitude','$longitude');";
    $result = mysqli_query($db,$insertQuery);
    // Successfully Login Message.
    $onLoginSuccess = "새로운 데이터 ($userid,$time,$latitude,$longitude)";
    
    // Converting the message into JSON format.
    $SuccessMSG = json_encode($onLoginSuccess);
    
    // Echo the message.
    echo $SuccessMSG ; 
}
else{
    $updateQuery = "UPDATE currentgps SET time='$time',latitude='$latitude',longitude='$longitude' WHERE userid='$userid';";
    $result = mysqli_query($db,$updateQuery);
    // Successfully Login Message.
    $onLoginSuccess = '데이터 업데이트';
    
    // Converting the message into JSON format.
    $SuccessMSG = json_encode($onLoginSuccess);
    
    // Echo the message.
    echo $SuccessMSG ; 

    
}

mysqli_close($db);
?>