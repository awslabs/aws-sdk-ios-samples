<html>
<body>
<h2>Running the S3_S3TransferManager Sample</h2>
<p>This sample demonstrates the pause and resume features of the S3TransferManager found in the S3 SDK.</p>
<p>For a more detailed description of the code, please visit this <a href="S3TransferManager.html">writeup</a>.
<ol>
  <li>Open the <code>S3TransferManager.xcodeproj</code> project file in Xcode. </li>
  <li>Configure the sample with your AWS security credentials:
    <ol>
      <li>Open the <code>Constants.h</code> file. </li>
      <li>Modify the <code>ACCESS_KEY</code> and <code>SECRET_KEY</code> definitions with your AWS Credentials. </li>
    </ol>
  </li>
  <li>Add the AWS SDK for iOS Frameworks to the sample. Get it <a href="http://aws.amazon.com/sdkforios/">here</a>.
  	<ol>In the Project Navigator, Right-Click on the Frameworks group.</ol>
  	<ol>In the Menu select Add Files to "S3TransferManager"</ol>
  	<ol>Navigate to the location where you downloaded and expanded the AWS SDK for iOS.</ol>
  	<ol>Select the follwing frameworks and click Add
  		<ol>AWSRuntime.framework</ol>
  		<ol>AWSS3.framework</ol>
  	<ol>
  </li>
  <li>Run the project.</li>
</ol>
</body>
</html>
