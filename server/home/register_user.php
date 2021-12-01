<?php

include 'db.php';

// Storing the received JSON into $json variable.
$json = file_get_contents('php://input');
 
// Decode the received JSON and Store into $obj variable.
$obj = json_decode($json,true);

$user_id = $obj['userid'];

// Getting name from $obj object.
$name = $obj['username'];
 
// Getting Email from $obj object.
$email = $obj['email'];

// Getting Password from $obj object.
$password = $obj['password'];

$phone = $obj['phone'];

$image = $obj['image'];

// Checking whether Email is Already Exist or Not in MySQL Table.
$CheckemailSQL = "SELECT * FROM user WHERE email='$email'";
 
// Executing Email Check MySQL Query.
$result1 = mysqli_query($db,$CheckemailSQL);
$checkemail = mysqli_fetch_array($result1);

$CheckuseridSQL = "SELECT * FROM user WHERE userid='$user_id'";

$result2 = mysqli_query($db,$CheckuseridSQL);
$checkuserid = mysqli_fetch_array($result2);

$ChecknameSQL = "SELECT * FROM user WHERE username='$name'";

$result3 = mysqli_query($db,$ChecknameSQL);
$checkname = mysqli_fetch_array($result3);


$CheckphoneSQL = "SELECT * FROM user WHERE phone='$phone'";

$result4 = mysqli_query($db,$CheckphoneSQL);
$checkphone = mysqli_fetch_array($result4);


if(isset($checkemail, $checkuserid, $checkname)){

	$AlreadyregisteredExist = "등록된 회원 입니다.";

	$existAlreadyregistered = json_encode($AlreadyregisteredExist);

	echo $existAlreadyregistered;
  }
  elseif(isset($checkemail)) {

	$emailExist = '이미 등록된 이메일 입니다.';
	 
	// Converting the message into JSON format.
   	$existEmailJSON = json_encode($emailExist);
	
	// Echo the message on Screen.
	echo $existEmailJSON; 

  }
  elseif(isset($checkuserid)){

	$user_idExist = "이미 등록된 아이디 입니다.";

	$existuser_idJSON = json_encode($user_idExist);

	echo $existuser_idJSON; 
  }
  elseif(isset($checkname)){

	$nameExist = "이미 등록된 닉네임 입니다.";

	$exitnameJSON = json_encode($nameExist);

	echo $exitnameJSON;

  }
  elseif(isset($checkphone)){

	$phoneExist = "이미 등록된 핸드폰 입니다.";

	$exitphoneJSON = json_encode($phoneExist);

	echo $exitphoneJSON;

  }
else{
 
	 // Creating SQL query and insert the record into MySQL database table.
	 $Sql_Query = "insert into user (userid,username,email,password,phone,image) values ('$user_id','$name','$email', '$password','$phone','$image')";
	 
	 
	 if(mysqli_query($db,$Sql_Query)){
	 
		 // If the record inserted successfully then show the message.
		$MSG = '회원가입 성공!' ;
		 
		// Converting the message into JSON format.
		$json = json_encode($MSG);
		 
		// Echo the message.
		 echo $json ;
	 
	 }
	 else{
	 
		echo 'Try Again';
	 
	 }
 }
 mysqli_close($db);
?>