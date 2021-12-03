<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];
$freindid = $obj['freindid'];


//Applying User Login query with email and password.
$loginQuery = "select * from user where userid = '$freindid';";

$result = mysqli_query($db,$loginQuery);


$check = mysqli_fetch_array($result);

if(isset($check)){
    
    $insertQuery = "INSERT INTO friend VALUES ('$userid','$freindid');";
    $result = mysqli_query($db,$insertQuery);

    $onAddSuccess = "친구추가 완료";
    $SuccessMSG = json_encode($onAddSuccess);
    
    // Echo the message.
    echo $SuccessMSG ; 
}
else{

    $onAddFail = '친구추가 실패';
    
    // Converting the message into JSON format.
    $FailMSG = json_encode($onAddFail);
    
    // Echo the message.
    echo $FailMSG ; 

    
}

mysqli_close($db);
?>