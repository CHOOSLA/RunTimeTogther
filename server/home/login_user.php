<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$user_id = $obj['user_id'];

// Getting Password from JSON $obj array and store into $password.
$password = $obj['password'];

//Applying User Login query with email and password.
$loginQuery = "select * from user where userid = '$user_id' and password = '$password';";

$result = mysqli_query($db,$loginQuery);

$result_array = array();


$check = mysqli_fetch_array($result);

if(isset($check)){
       
    // Successfully Login Message.
    $onLoginSuccess = 'Login Matched';
    
    // Converting the message into JSON format.
    $SuccessMSG = json_encode($onLoginSuccess);
    
    // Echo the message.
    echo $SuccessMSG ; 

}

else{

    // If Email and Password did not Matched.
   $InvalidMSG = '잘못된 사용자 이름 또는 암호 다시 시도하십시오.' ;
    
   // Converting the message into JSON format.
   $InvalidMSGJSon = json_encode($InvalidMSG);
    
   // Echo the message.
    echo $InvalidMSGJSon ;

}

mysqli_close($db);
?>