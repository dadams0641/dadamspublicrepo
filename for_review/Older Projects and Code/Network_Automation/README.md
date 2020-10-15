README File for Network Automation

Author: David Adams
Email: dadams@dentalhero.com
Mobile: (470)955-4213

Initial Version: 22- Oct - 2018
Latest Update: 19 - Nov - 2018

What It Does:
	This role-based Ansible script was created to ease and automate the creation of default network layouts for use in DR scenarios. NOTE* this process has been obsoleted in favour of CloudFormation templates. Please reference this for informational purposes only. 
	
Why It Does It: 
	As RES migrates into the cloud, having our infrastructure laid out as code will exponentially decrease the amount of time required to have a network back up and running in the event of a disaster. 
	
How It Does It:

	- Once the commandline action is given (whether manual or orchestrated) the script will kick off the first role which will chain into the others. 
	- The VPC is created using the supplied parameters in the Ansible Vault secrets file. 
	- Based upon the VPC information, the security groups are then spawned and linked. 
	- From there, the internet gateway is created and references the above listed VPC and SG.
	- It then moves on to creating the subnets (both public and private) and applies them to the items listed above and creates availability for the internal systems to talk to each other. 
	- The routing table is then created and gives a proper route from the Internet Gateway to the subnet and all items below. 
