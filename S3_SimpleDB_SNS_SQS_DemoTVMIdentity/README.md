<html>
<body>
<h2>Running the S3_SimpleDB_SNS_SQS_DemoTVMIdentity Sample</h2>
<p>This sample demonstrates interaction with a <a href="http://aws.amazon.com/articles/4611615499399490">Token Vending Machine</a> where a username/password combination is required.  The user is expected to register with the App first by connecting to  an external website.  In this sample the the website is a specific page on the Token Vending Machine.  After registering, the user would be able to start the App by logging in.</p>
<p>It is assumed that you were able to run the S3_SimpleDB_SNS_SQS_Demo sample and that you are currently running an <a href="http://aws.amazon.com/code/7351543942956566">Identity</a> version of the TVM, token vending machine.</p>
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
  <li>Add the AWS SDK for iOS Frameworks to the sample.
    <ol>In the Project Navigator, Right-Click on the Frameworks group.</ol>
    <ol>In the Menu select Add Files to "AWSiOSDemoTVMIdentity"</ol>
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
