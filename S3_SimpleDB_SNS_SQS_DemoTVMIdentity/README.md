<html>
<body>
<h2>Running the S3_SimpleDB_SNS_SQS_DemoTVMIdentity Sample</h2>
<p>This sample demonstrates interaction with a Token Vending Machine where a username/password combination is required.
The user is expected to register with the App first by connecting to  an external website.  In this sample the the website is a specific page on the 
Token Vending Machine.  After registering, the user would be able to start the App by logging in.</p>
<p>It is assumed that you were able to run the S3_SimpleDB_SNS_SQS_Demo sample and that you are currently running an Identity version of the TVM, token vending machine.</p>
<ol>
  <li>Open the <code>aws-sdk-ios-samples/S3_SimpleDB_SNS_SQS_DemoTVMIdentity/AWSiOSDemoTVMIdentity.xcodeproj</code> project file in Xcode. </li>
  <li>Configure the sample with your Token Vending Machine settings:
    <ol>
      <li>Open the <code>Constants.h</code> file. </li>
      <li>Modify the <code>TOKEN_VENDING_MACHINE_URL</code> with the DNS domain name where your Token Vending Machine is running (ex: tvm.elasticbeanstalk.com).</li>
      <li>Modify the <code>APP_NAME</code> with the name you configured your Token Vending Machine with (ex: MyMobileAppName).</li>
      <li>Modify the <code>USE_SSL</code> to YES or NO based on whether your Token Vending Machine is running SSL or not.</li>
    </ol>
  </li>
  <li>Run the project.</li>
</ol>
</body>
</html>
