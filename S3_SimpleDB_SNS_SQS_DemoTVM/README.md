<html>
<body>
<h2>Running the S3_SimpleDB_SNS_SQS_DemoTVM Sample</h2>
<p>This sample demonstrates interaction with the Token Vending Machine without requiring an identity from the user.</p>
<p>It is assumed that you were able to run the S3_SimpleDB_SNS_SQS_Demo sample and that you are currently running the Anonymous version of the TVM, token vending machine.</p>
<ol>
  <li>Open the <code>aws-sdk-ios-samples//S3_SimpleDB_SNS_SQS_DemoTVM/AWSiOSDemoTVM.xcodeproj</code> project file in Xcode. </li>
  <li>Configure the sample with your Token Vending Machine settings:
    <ol>
      <li>Open the <code>Constants.h</code> file. </li>
      <li>Modify the <code>TOKEN_VENDING_MACHINE_URL</code> with the DNS domain name where your Token Vending Machine is running (ex: tvm.elasticbeanstalk.com).</li>
      <li>Modify the <code>USE_SSL</code> to YES or NO based on whether your Token Vending Machine is running SSL or not.</li>
    </ol>
  </li>
  <li>Add the AWS SDK for iOS Frameworks to the sample.
  	<ol>In the Project Navigator, Right-Click on the Frameworks group.</ol>
  	<ol>In the Menu select Add Files to "AWSiOSDemoTVM"</ol>
  	<ol>Navigate to the location where you downloaded and expanded the AWS SDK for iOS.</ol>
  	<ol>Select the follwing frameworks and click Add
  		<ol>AWSRuntime.framework</ol>
  		<ol>AWSS3.framework</ol>
  		<ol>AWSSimpleDB.framework</ol>
  		<ol>AWSSQS.framework</ol>
  		<ol>AWSSNS.framework</ol>
  	<ol>
  </li>
  <li>Run the project.</li>
</ol>
</body>
</html>
