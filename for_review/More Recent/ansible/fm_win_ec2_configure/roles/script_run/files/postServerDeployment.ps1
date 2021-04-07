############################################################################
##### 		        Created by: Steve Frizzle
#####	Leveraging parts of an automation script created by Jake Wanamaker
#####
#####     This script MUST be ran using 64bit PowerShell ISE		
#####     This script MUST be ran as an administrator/elevated credentials 			
#####     Many errors will take place when using x86 instead of 64bit	
##### 									
##### 						  	
##### 				Date Modified: 9/17/2019
############################################################################

#Begin Script
#---------------------------------------------------------------------
#Configure AD Settings


#Import AD & RSAT Modules
Add-WindowsFeature RSAT-AD-Powershell | Out-Null
Import-Module ActiveDirectory | Out-Null

#Set Constant Variables
#Staging OUs
$StagingAWSEC2 = "OU=Amazon,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"
$StagingAWSSDDC = "OU=AWS SDDC EAST,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"
$StagingFishers = "OU=Fishers,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"
$StagingMoorestown = "OU=Moorestown,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"
$StagingLakeCenter = "OU=Lake Center,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"
$StagingRemote = "OU=Remote,OU=Staging Servers,OU=Domain Servers,DC=fhmc,DC=local"

#System Groups
$BackupSystems = "CN=Backup Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$CorporateReportingSystems = "CN=Corporate Reporting Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$DatabaseSystems = "CN=Database Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$EntAndSecSystems = "CN=Enterprise and Security Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FileAndPrintSystems = "CN=File and Print Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FinAndAcctSystems = "CN=Financial and Accounting Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$InfrastructureSystems = "CN=Infrastructure Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$LendingSystems = "CN=Lending Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MessagingSystems = "CN=Messaging Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ServicingSystems = "CN=Servicing Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SharepointSystems = "CN=Sharepoint Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$TelephonySystems = "CN=Telephony Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPSystems = "CN=Non-Production Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPDBSystems = "CN=Non-Production Database Systems,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"

#PatchGroups
$BSPG1PG1 = "CN=Backup Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$BSPG2PG1 = "CN=Backup Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$CRSPG1PG1 = "CN=Corporate Reporting Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$CRSPG2PG1 = "CN=Corporate Reporting Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$DBSPG1PG1 = "CN=Database Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$DBSPG2PG1 = "CN=Database Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ESSPG1PG1 = "CN=Enterprise and Security Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ESSPG2PG1 = "CN=Enterprise and Security Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FPSPG1PG1 = "CN=File and Print Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FPSPG2PG1 = "CN=File and Print Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FASPG1PG1 = "CN=Financial and Accounting Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$FASPG2PG1 = "CN=Financial and Accounting Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ISPG1PG1 = "CN=Infrastructure Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ISPG1PG2 = "CN=Infrastructure Systems ProdGroup1_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ISPG2PG1 = "CN=Infrastructure Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ISPG2PG2 = "CN=Infrastructure Systems ProdGroup2_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$ISPG2PG3 = "CN=Infrastructure Systems ProdGroup2_PatchGroup3,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$LSPG1PG1 = "CN=Lending Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$LSPG2PG1 = "CN=Lending Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MSPG1PG1 = "CN=Messaging Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MSPG1PG2 = "CN=Messaging Systems ProdGroup1_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
#$MSPG1PG3 = "CN=Messaging Systems ProdGroup1_PatchGroup3,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MSPG2PG1 = "CN=Messaging Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MSPG2PG2 = "CN=Messaging Systems ProdGroup2_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$MSPG2PG3 = "CN=Messaging Systems ProdGroup2_PatchGroup3,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
#REMOVE - $NPDBSPG1PG1 = "CN=Non-Prod Database Systems Group1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
#REMOVE - $NPDBSPG1PG2 = "CN=Non-Prod Database Systems Group1_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPSPG1PG1 = "CN=Non-Prod Systems Group1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPSPG1PG2 = "CN=Non-Prod Systems Group1_PatchGroup2,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPSPG1PG3 = "CN=Non-Prod Systems Group1_PatchGroup3,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$NPSPG2PG1 = "CN=Non-Prod Systems Group2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SSLRSPG1PG1 = "CN=Servicing Systems LRS ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SSPG1PG1 = "CN=Servicing Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SSPG2PG1 = "CN=Servicing Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SPSPG1PG1 = "CN=Sharepoint Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$SPSPG2PG1 = "CN=Sharepoint Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$TSPG1PG1 = "CN=Telephony Systems ProdGroup1_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$TSPG2PG1 = "CN=Telephony Systems ProdGroup2_PatchGroup1,OU=Patch Groups,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"

#WeekendGroups
$1A = "CN=1a - Non-Production Group 1 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$1B = "CN=1b - Non-Production Group 1 - Patch Group 2,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$1C = "CN=1c - Non-Production Group 1 - Patch Group 3,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$2A = "CN=2a - Production Backup Systems Group 1 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$3A = "CN=3a - Production Systems Group 1 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$3B = "CN=3b - Production Systems Group 1 - Patch Group 2,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$4A = "CN=4a - Production LRS Servicing Group 1 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$5A = "CN=5a - Non-Production Group 2 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$6A = "CN=6a - Production Backup Systems Group 2 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$7A = "CN=7a - Production Systems Group 2 - Patch Group 1,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$7B = "CN=7b - Production Systems Group 2 - Patch Group 2,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"
$7C = "CN=7c - Production Systems Group 2 - Patch Group 3,OU=Patch Weekends,OU=Server Groups,OU=Groups,DC=fhmc,DC=local"

Clear-Host

#Administrator Credentials
Write-Host "Please enter your Administrative AD Credentials. Start with domain\"
$Credentials = Get-Credential


#Obtain Computer Name
$ServerName = Read-Host -Prompt "Please Enter Server Name"
$ComputerName = Get-ADComputer -Identity $ServerName


#Server System Group
$SchemaGroupList=
@(
"POC Servers"
"Development Servers"
"Test Servers"
"UAT Servers"
"Production Servers"
)
$SchemaGroup = $SchemaGroupList | Out-GridView -Title "Select system schema:" -OutputMode Single


#Server System Group
$SystemGroupList=
@(
"Backup Systems"
"Corporate Reporting Systems"
"Database Systems"
"Enterprise and Security Systems"
"File and Print Systems"
"Financial and Accounting Systems"
"Infrastructure Systems"
"Lending Systems"
"Messaging Systems"
"Servicing Systems"
"Sharepoint Systems"
"Telephony Systems"
)
$SystemGroup = $SystemGroupList | Out-GridView -Title "Select system type:" -OutputMode Single


#Server Location Field
$LocationGroupList=
@(
"Altamonte Springs"
"Chicago (SIS DR)"
"Cleveland"
"Clifton Park"
"Columbia"
"Deerfield Beach"
"Fishers (10500 Kincaid Fishers IN)"
"Fort Washington"
"Great Neck"
"Jacksonville"
"Marlton (Lake Center NJ)"
"Moorestown (301 Harper Moorestown NJ)"
"Mount Laurel (907 Pleasant Valley Mt Laurel NJ)"
"New York City"
"North Virginia (Amazon EC2 US East)"
"North Virginia (vCenter AWS SDDC)"
"Phoenix"
"San Diego"
"San Dimas"
"Singapore (Amazon EC2 Asia)"
"Tempe"
)
$Location = $LocationGroupList | Out-GridView -Title "Select system location:" -OutputMode Single 
Set-ADComputer -Identity $ServerName -Location $Location


#Server Description
$Description = Read-Host -Prompt "Please enter a brief server description."


#Server Application Selection
$ServerApplicationList=
@(
"AD Audit"
"AD/Certificate Authority"
"AD/DirectorySync"
"AD/DNS"
"AD/Federation Services"
"AD/Key Management Service"
"ADP"
"Avaya"
"Azure AD Connect"
"Bitlocker Administration Reporting"
"BusinessObjects"
"Calyx Point Central"
"CatTools"
"CommVault"
"DailyHealthCheckAutomation"
"DataProtector"
"DHCP"
"Doc-Link"
"EDM Conversion/Extraction"
"Elynx"
"Encompass Lakewood Migration"
"Encompass3.5"
"Ericom Web Connect"
"ERWIN Mart"
"Exchange"
"Express"
"FICS"
"File Server"
"File Server - DFS"
"FixedAssets"
"Footprints - Client Management"
"Footprints - Service Core"
"FRx"
"HP Openview"
"HUB/Loader"
"Hyper-V"
"Hyper-V Virtual Machine Manager"
"IdentityIQ"
"Idera"
"IIS"
"IIS / FTP"
"Jenkins"
"LeadPoint DataConnect"
"Learn Upon LDAP Connector"
"Loanstacker"
"LRS"
"MAS500"
"Mindbox"
"Oracle"
"Oracle ERP Fusion Integration"
"Oracle to Progress Conversion"
"Palo Alto Connector"
"PCFS"
"Portal"
"PowerShell"
"Print Server"
"QRM"
"Radius Authentication"
"RD Web App"
"Rekon"
"Retina"
"SAN Administrator"
"Sharepoint"
"Solarwinds"
"Speech Analytics"
"SQL"
"Symantec Endpoint Encryption"
"Symantec Endpoint Protection"
"Tableau"
"Telephony"
"Telephony Calabrio"
"Telephony Media"
"TenA Secondlook"
"Tradeweb Market Data Services"
"UiPath"
"UPS Trackpad"
"vBrick"
"Wolters Kluwer - CRA Wiz"
"Wolters Kluwer - E-Sign"
"Wolters Kluwer - Expere"
"Wolters Kluwer - SDX"
"WSUS"
"XL Deploy"
"Zerto"
)
$ServerApplication = $ServerApplicationList | Out-Gridview -Title "Select server application:" -OutputMode Single
$ComputerName.extensionAttribute10 = $ServerApplication


#Server Business Channel Selection
$BusinessChannelList= 
@(
"Accounting"
"Business Services"
"Call Center"
"Capital Markets"
"Collateral"
"Corporate Analytics"
"Correspondent"
"Credit Risk"
"Enterprise Solutions"
"Enterprise"
"Executive Office"
"Finance"
"First Flyer's"
"Funding"
"Human Resources"
"Information Technology"
"Insuring"
"Investor Relations"
"Leased Services"
"Legal"
"Marketing"
"PMO"
"Portfolio Seconds"
"Public Relations"
"QA"
"Risk Mgmt"
"Servicing"
"Traditional Retail"
"Vendor Management"
"Wholesale"
)
$BusinessChannel = $BusinessChannelList | Out-GridView -Title "Select channel who utilizes this system. For more than one, select Enterprise" -OutputMode Single
$ComputerName.extensionAttribute13 = $BusinessChannel


#Server Description 
$FinalDescription = "$SystemGroup" + " - " + "$Description" + " - " + "$BusinessChannel"
$ComputerName.Description = $FinalDescription

#Server Application Owner
$ApplicationOwnerList=
@(
"BSGDevelopmentTeam@FreedomMortgage.com"
"CapitalMarketsGroup@FreedomMortgage.com"
"DBATeam@FreedomMortgage.com"
"EnterpriseArchitecture@FreedomMortgage.com"
"EnterpriseMonitoring@freedommortgage.com"
"ISJava@FreedomMortgage.com"
"ISNETDevelopers@FreedomMortgage.com"
"itEnterpriseApplicationAdministration@FreedomMortgage.com"
"ITEPMGroup@FreedomMortgage.com"
"itqaautomation@FreedomMortgage.com"
"MessagingAdmins@FreedomMortgage.com"
"RulesEngineGroup@FreedomMortgage.com"
"SecOps@FreedomMortgage.com"
"SharePoint@FreedomMortgage.com"
"SysAdminSql@FreedomMortgage.com"
"SysAdminWin@FreedomMortgage.com"
"SysBackups@FreedomMortgage.com"
"TelecomEngineering2@FreedomMortgage.com"
"websphere@freedommortgage.com"
)
$ApplicationOwner = $ApplicationOwnerList | Out-Gridview -Title "Select application owner:" -OutputMode Single
$ComputerName.adminDescription = $ApplicationOwner


#Server Application Validator(s)
$ApplicationValidatorList=
@(
"BSGDevelopmentTeam@FreedomMortgage.com"
"CapitalMarketsGroup@FreedomMortgage.com"
"DBATeam@FreedomMortgage.com"
"EnterpriseArchitecture@FreedomMortgage.com"
"EnterpriseMonitoring@freedommortgage.com"
"ISJava@FreedomMortgage.com"
"ISNETDevelopers@FreedomMortgage.com"
"itEnterpriseApplicationAdministration@FreedomMortgage.com"
"ITEPMGroup@FreedomMortgage.com"
"itqaautomation@FreedomMortgage.com"
"MessagingAdmins@FreedomMortgage.com"
"RulesEngineGroup@FreedomMortgage.com"
"SecOps@FreedomMortgage.com"
"SharePoint@FreedomMortgage.com"
"SysAdminSql@FreedomMortgage.com"
"SysAdminWin@FreedomMortgage.com"
"SysBackups@FreedomMortgage.com"
"TelecomEngineering2@FreedomMortgage.com"
"websphere@freedommortgage.com"
)
$ApplicationValidator = $ApplicationValidatorList | Out-Gridview -Title "Select Application Validator:" -OutputMode Single
$ComputerName.extensionAttribute11 = $ApplicationValidator


#Server Owner
$ServerOwnerList=
@(
"SysAdminWin@FreedomMortgage.com"
)
$ServerOwner = $ServerOwnerList | Out-Gridview -Title "Select Server Owner:" -OutputMode Single
$ComputerName.extensionAttribute12 = $ServerOwner


#Server Uptime
$ServerUptimeList=
@(
"24x7"
"24x6"
"24x5"
"20x7"
"20x6"
"20x5"
"16x7"
"16x6"
"16x5"
"12x6"
"12x5"
"9x6"
"9x5"
)
$ServerUptime = $ServerUptimeList | Out-Gridview -Title "Select Uptime Requirement:" -OutputMode Single
$ComputerName.extensionAttribute14 = $ServerUptime


#Apply AD Attributes to Server
Set-ADComputer -Instance $ComputerName

#--------------------------------------------------------------------------------
#COMPUTERGUIDSTUFF

#Obtain Computer GUID
$ComputerGUID = Get-ADComputer -Identity $ServerName -Credential $Credentials | Select -ExpandProperty ObjectGUID

#Establish Patch Groups
#Determine system and group to present for patching
#Production Groups
Clear-Host
    if ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Backup Systems")
		{
		Add-ADGroupMember -Identity $BackupSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Backup Systems are patched Thursday afternoon prior to main patching"
		Write-Host "Production Group 1 = First Production Patch Cycle - Non-Fishers CV Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Fishers CV Servers"

		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $BSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $2A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $BSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $6A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Corporate Reporting Systems")
		{
		Add-ADGroupMember -Identity $CorporateReportingSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $CRSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $CRSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}		
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Database Systems")
		{
		Add-ADGroupMember -Identity $DatabaseSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Stand-Alone & Secondary Clustered SQL Nodes"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Clustered Primary SQL Nodes"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $DBSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $DBSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Enterprise and Security Systems")
		{
		Add-ADGroupMember -Identity $EntAndSecSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $ESSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $ESSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}		
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "File and Print Systems")
		{
		Add-ADGroupMember -Identity $FileAndPrintSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $FPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $FPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}			
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Financial and Accounting Systems")
		{
		Add-ADGroupMember -Identity $FinAndAcctSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $FASPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $FASPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}					
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Infrastructure Systems")
		{
		Add-ADGroupMember -Identity $InfrastructureSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 1 - Patch Group 2"
		Write-Host "3. Production Group 2 - Patch Group 1"
		Write-Host "4. Production Group 2 - Patch Group 2"
		Write-Host "5. Production Group 2 - Patch Group 3"
		Write-Host ""
		Write-Host "Prod Group 1 - Patch Group 1 = 1st Prod Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Prod Group 1 - Patch Group 2 = 1st Prod Patch Cycle - Secondary Servers out of Group 1"
		Write-Host "Prod Group 2 - Patch Group 1 = 2nd Prod Patch Cycle - Secondary Servers"
		Write-Host "Prod Group 2 - Patch Group 2 = 2nd Prod Patch Cycle - Secondary Clustered/HA Servers"
		Write-Host "Prod Group 2 - Patch Group 3 = 2nd Prod Patch Cycle - Secondary Clustered/HA Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, 4, or 5"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $ISPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $ISPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $ISPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $ISPG2PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 5)
				{
				Add-ADGroupMember -Identity $ISPG2PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7C -Members $ComputerGUID
				}				
			elseif ($Patchgroup -ne 1,2,3,4,5)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}							
		}	
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Lending Systems")
		{
		Add-ADGroupMember -Identity $LendingSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Prod Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Prod Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $LSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $LSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}			
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Messaging Systems")
		{
		Add-ADGroupMember -Identity $MessagingSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 1 - Patch Group 2"
		Write-Host "3. Production Group 2 - Patch Group 1"
		Write-Host "4. Production Group 2 - Patch Group 2"
		Write-Host "5. Production Group 2 - Patch Group 3"
		Write-Host ""
		Write-Host "Prod Group 1 - Patch Group 1 = 1st Prod Patch Cycle - Secondary Servers or Stand-Alone"
		Write-Host "Prod Group 1 - Patch Group 2 = 1st Prod Patch Cycle - Secondary Clustered w/ Group 1 Servers"
		Write-Host "Prod Group 2 - Patch Group 1 = 2nd Prod Patch Cycle - Primary Servers"
		Write-Host "Prod Group 2 - Patch Group 2 = 2nd Prod Patch Cycle - Primary Secondary Clustered/HA Servers"
		Write-Host "Prod Group 2 - Patch Group 3 = 2nd Prod Patch Cycle - Primary Tertiary Clustered/HA Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, 4, or 5"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $MSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $MSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $MSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $MSPG2PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 5)
				{
				Add-ADGroupMember -Identity $MSPG2PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7C -Members $ComputerGUID
				}				
			elseif ($Patchgroup -ne 1,2,3,4,5)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}		
		}

	elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Servicing Systems")
		{
		Add-ADGroupMember -Identity $ServicingSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host "3. **Prod LRS Servers ONLY**"
		Write-Host ""
		Write-Host "Prod Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Prod Group 2 = Second Production Patch Cycle - Secondary Servers"
		Write-Host "Option 3 = **LRS SERVERS ONLY** Patched Sunday Evening After Prod Patch Date"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $SSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $SSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $SSLRSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $4A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}			
		}

	elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Sharepoint Systems")
		{
		Add-ADGroupMember -Identity $SharepointSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Primary or Stand-Alone Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Secondary Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $SPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $SPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}		
		}
	
    elseif ($SchemaGroup -eq "Production Servers" -AND $SystemGroup -eq "Telephony Systems")
        {
		Add-ADGroupMember -Identity $TelephonySystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Production Group 1 - Patch Group 1"
		Write-Host "2. Production Group 2 - Patch Group 1"
		Write-Host ""
		Write-Host "Production Group 1 = First Production Patch Cycle - Non-Fishers Telecom Servers"
		Write-Host "Production Group 2 = Second Production Patch Cycle - Fishers Servers"
		$PatchGroup = Read-Host -Prompt "Select option 1 or 2"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $TSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $3A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $TSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $7A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}			
		}
	
#UAT Groups
    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Backup Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clustered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - **UAT Secondary Clustered ONLY**"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Corporate Reporting Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Database Systems")
        {
		Add-ADGroupMember -Identity $NPDBSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Enterprise and Security Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "File and Print Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Financial and Accounting Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Infrastructure Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Lending Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Messaging Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Servicing Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Sharepoint Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

    elseif ($SchemaGroup -eq "UAT Servers" -AND $SystemGroup -eq "Telephony Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host "4. Non-Prod Group 2 - Patch Group 1 - UAT Secondary Clustered ONLY"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		Write-Host "Non-Prod Group 2 = 2nd Non-Prod Patch Cycle - UAT systems patched following Prod Patching"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, 3, or 4"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 4)
				{
				Add-ADGroupMember -Identity $NPSPG2PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $5A -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3,4)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}
		}

#Remaining Non-Production Servers
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Backup Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}		
		}

	elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Corporate Reporting Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Database Systems")
        {
		Add-ADGroupMember -Identity $NPDBSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Enterprise and Security Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "File and Print Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Financial and Accounting Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Infrastructure Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Lending Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Messaging Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Servicing Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Sharepoint Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}
	
    elseif ($SchemaGroup -ne "Production Servers","UAT Servers" -AND $SystemGroup -eq "Telephony Systems")
        {
		Add-ADGroupMember -Identity $NPSystems -Members $ComputerGUID
        Write-Host "You've selected $SystemGroup that's grouped with $SchemaGroup"
		Write-Host "Select Systems Patch Group"
		Write-Host ""
		Write-Host "1. Non-Prod Group 1 - Patch Group 1 - Standalone or Primary Clustered Non-Prod"
		Write-Host "2. Non-Prod Group 1 - Patch Group 2 - Secondary Clustered Non-Prod"
		Write-Host "3. Non-Prod Group 1 - Patch Group 3 - Tertiary Clusered Non-Prod"
		Write-Host ""
		Write-Host "Non-Prod Group 1 = 1st Non-Prod Patch Cycle"
		$PatchGroup = Read-Host -Prompt "Select option 1, 2, or 3"
			if ($PatchGroup -eq 1)	
				{
				Add-ADGroupMember -Identity $NPSPG1PG1 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1A -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 2)
				{
				Add-ADGroupMember -Identity $NPSPG1PG2 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1B -Members $ComputerGUID
				}
			elseif ($PatchGroup -eq 3)
				{
				Add-ADGroupMember -Identity $NPSPG1PG3 -Members $ComputerGUID
				Add-ADGroupMember -Identity $1C -Members $ComputerGUID
				}
			elseif ($Patchgroup -ne 1,2,3)
				{
				[System.Windows.MessageBox]::Show('Erroneous Entry Detected. Exiting Script.')
				Return
				}				
		}


#Move Server to Staging OU based on location
if ($Location -eq "North Virginia (Amazon EC2 US East)"){
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingAWSEC2 -Credential $Credentials
		}
	elseif ($Location -eq "North Virginia (vCenter AWS SDDC)"){
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingAWSSDDC -Credential $Credentials
		}
	elseif ($Location -eq "Fishers (10500 Kincaid Fishers IN)"){
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingFishers -Credential $Credentials
		}
	elseif ($Location -eq "Moorestown (301 Harper Moorestown NJ)"){
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingMoorestown -Credential $Credentials
		}
	elseif ($Location -eq "Marlton (Lake Center NJ)"){
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingLakeCenter -Credential $Credentials
		}
	else{
		Move-ADObject -Identity $ComputerGUID -TargetPath $StagingRemote -Credential $Credentials
		}


Write-Host "*** You've selected $ServerName to be located at $Location"
Write-Host "*** $ServerName will be nested with $SchemaGroup"
Write-Host "*** $ServerName will be classified with $SystemGroup"
Write-Host ""
Write-Host "***PLEASE NOTIFY APPLICATION INSTALLER THAT THEIR SERVER IS READY!***"
Write-Host ""
Write-Host "Updates to Computer Object have been completed."
		