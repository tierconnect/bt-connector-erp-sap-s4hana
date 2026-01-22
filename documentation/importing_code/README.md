## Importing the Plugin Code

>**NOTE**
Connect to the repository in the systems of your 3-system landscape in the following sequence: development, test, and production systems.

---

## Description

The following procedure describes the process to connect to the repository on one system, here JXZ.

## Procedure
In the SAP Fiori launchpad of your SAP S/4HANA Cloud Public Edition development system, search for the app called **Git-Enabled CTS**. To open the gCTS app, select the **Git-Enabled CTS** tile.


To provide credentials for the Git provider of the repository containing the extension, click the **key** icon (Manage settings of current user).
![image](/documentation/images/loio596bf27226a94ca09495b14b966e1371_LowRes.png)

Choose **Create Credentials**.
![image](/documentation/images/loioc3fe6a1aff5a49d485b8bb84e2123f02_LowRes.png)

Enter the information as shown below including the token provided to you by Seagull Software, and choose **Save**.
![image](/documentation/images/loio59a5125e12444083a31bbd611b5af268_LowRes.png)

Confirm saving the credentials.
![image](/documentation/images/loio5066f2675f4142aeba48f2f86069a126_LowRes.png)

If gCTS can validate the authentication of the user specified, you can find the Git user name in the **Endpoint User** column. Choose **Close**.
![image](/documentation/images/loioa8310d4e27314dd09dd1568913ceefce_LowRes.png)

In the gCTS app, choose **Create**.
![image](/documentation/images/loio1ef5be9d1bc1414f8e01164596b73caa_LowRes.png)

Enter the **URL** of the repository and select the value help in the **vSID** field.
The **Description** is derived from the URL.
![image](/documentation/images/loiob0abd1e8245c48c1bda8ccd831579ac9_LowRes.png)

Select **1GT**.
![image](/documentation/images/loioa4322ca3590941dd80706a75ff6cb481_LowRes.png)

Select **Provided** as the **Role** of the repository.
Caution
It is important that you select the **Provided** role to be able to pull changes from remote.
![image](/documentation/images/loioa48cb66084fb4f14832f3dda223ea00f_LowRes.png)

Select the correct **Type**.
![image](/documentation/images/loio9e677d313922492aaabd9c787754c3cd_LowRes.png)

Leave the **Visibility** setting as **Public** and choose **Save**.
![image](/documentation/images/loiocac5b91e6b99484cb4244483978a1549_LowRes.png)

This setting defines the visibility in your system and doesn't impact the visibility of the remote repository. If you need to set the Visibility to Private, you can do so by editing the repository after you finished the creation process. If you do so, you will need to add collaborators to the repository in the gCTS app, if other users need access, too.

The gCTS app now displays the repository view of your new repository, in the **CREATED** status.
![image](/documentation/images/loio270e0773776f47f9bc905c2b7229225e_LowRes.png)

To finalize the connection with your remote repository, choose **Clone Repository**.
![image](/documentation/images/loio23b4a479627643619f8cb8334bf6a988_LowRes.png)

Confirm that you want to clone the repository.
![image](/documentation/images/loiob3fe5eed990d483f81123554bfba9319_LowRes.png)

Cloning pulls the commits of the repository to the local repository and imports the objects to the ABAP system.
When the cloning process is completed, verify that the status of the repository is READY, the expected branch (most likely main) is set as the active branch, and the latest commit of this branch is active.

---
If everything works correctly in the development system, repeat the previous steps on your test system. Once the extension has been successfully cloned to the test system, you can continue with the production system.
Note

You are now ready to use the extension.

>**Note**
When you clone a repository or pull a commit of a repository containing an SAP Fiori application to your system, all development objects of the app are imported. After the import, certain activation actions are performed, such as publishing the service binding. This process may take some time to complete. We recommend that you wait for the activation process to finish before starting to test the app. Don't use ABAP development tools for Eclipse for manual actions, like publishing the service binding.
