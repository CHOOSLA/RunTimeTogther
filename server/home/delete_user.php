<?php
include 'db.php';
// Getting the received JSON into $json variable.
$json = file_get_contents('php://input');

// Decoding the received JSON and store into $obj variable.
$obj = json_decode($json,true);

$userid = $obj['userid'];
$password = $obj['password'];



$deleteQuery = "DELETE FROM chatting where userid ='$userid' OR friendid ='$userid';";
$result = mysqli_query($db,$deleteQuery);


$deleteQuery = "DELETE FROM friend where userid ='$userid' OR friendid ='$userid';";
$result = mysqli_query($db,$deleteQuery);

// Converting the message into JSON format.
$deleteQuery = "DELETE FROM user where userid ='$userid';";
$result = mysqli_query($db,$deleteQuery);

if($result==1){
    $success = '회원 탈퇴되셨습니다!';
    $sucessMSG = json_encode($success);
    echo $sucessMSG ; 
        // Echo the message.

}else{
    $fail = '아이디 혹은 비밀번호를 확인해주세요';
    $failMSG = json_encode($fail);
    echo $failMSG ;
}

            


    

mysqli_close($db);
?>