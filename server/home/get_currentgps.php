<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];


//Applying User Login query with email and password.
$loginQuery = "select * from currentgps where userid ='$userid';";

$result = mysqli_query($db,$loginQuery);

$currentgps =mysqli_fetch_array($result);



if(isset($currentgps)){
    echo json_encode($currentgps);
}
else{
    // If Email and Password did not Matched.
   $InvalidMSG = '현재 로그인 중이 아님' ;
    
   // Converting the message into JSON format.
   $InvalidMSGJSon = json_encode($InvalidMSG);
    
   // Echo the message.
    echo $InvalidMSGJSon ;

}

mysqli_close($db);
?>