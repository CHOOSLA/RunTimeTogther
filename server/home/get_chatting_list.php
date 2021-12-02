<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$user_id = $obj['user_id'];


//Applying User Login query with email and password.
$loginQuery = "select * from chatting where userid ='$user_id' OR friendid ='$user_id' order by time asc;";

$result = mysqli_query($db,$loginQuery);

$chatting_list = array();
while($row = mysqli_fetch_array($result,MYSQLI_ASSOC)){
    $chatting_list[] = $row;
}


if(!empty($chatting_list)){
    echo json_encode($chatting_list);
}
else{
    // If Email and Password did not Matched.
   $InvalidMSG = '채팅없음' ;
    
   // Converting the message into JSON format.
   $InvalidMSGJSon = json_encode($InvalidMSG);
    
   // Echo the message.
    echo $InvalidMSGJSon ;

}

mysqli_close($db);
?>