<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];


//Applying User Login query with email and password.
$historyQuery = "select * from history where userid ='$userid' order by time asc;";

$result = mysqli_query($db,$historyQuery);

$history_list = array();
while($row = mysqli_fetch_array($result,MYSQLI_ASSOC)){
    $history_list[] = $row;
}


if(!empty($history_list)){
    echo json_encode($history_list);
}
else{
    // If Email and Password did not Matched.
   $InvalidMSG = '경로없음' ;
    
   // Converting the message into JSON format.
   $InvalidMSGJSon = json_encode($InvalidMSG);
    
   // Echo the message.
    echo $InvalidMSGJSon ;

}

mysqli_close($db);
?>