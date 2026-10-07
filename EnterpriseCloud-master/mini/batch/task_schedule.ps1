Write-Host "Creating all pipeline scheduled tasks..."

# DRIVER_SAPAPI - 1:00 AM daily
schtasks /create /tn "Pipeline_DRIVER_SAPAPI_0100" /tr "F:\Shares\mini\batch\DRIVER_SAPAPI.bat" /sc daily /st 01:00 /f

# DRIVER_WISDOM - 1:15 AM daily
schtasks /create /tn "Pipeline_DRIVER_WISDOM" /tr "F:\Shares\mini\batch\DRIVER_WISDOM.bat" /sc daily /st 01:15 /f

# DRIVER_TELCUSTOMER - 4:45 AM daily
schtasks /create /tn "Pipeline_DRIVER_TELCUSTOMER" /tr "F:\Shares\mini\batch\DRIVER_TELCUSTOMER.bat" /sc daily /st 04:45 /f

# DRIVER_ECC6 - 11 pm daily
schtasks /create /tn "Pipeline_DRIVER_ECC6" /tr "F:\Shares\mini\batch\DRIVER_ECC6.bat" /sc daily /st 23:00 /f

# DRIVER_QVICS - 2 AM daily
schtasks /create /tn "Pipeline_DRIVER_QVICS" /tr "F:\Shares\mini\batch\DRIVER_QVICS.bat" /sc daily /st 02:00 /f

# DRIVER_QVICS - 2 AM daily
schtasks /create /tn "Pipeline_DRIVER_QVICS_TROUBLE" /tr "F:\Shares\mini\batch\DRIVER_QVICS_TROUBLE.bat" /sc daily /st 02:00 /f

# DRIVER_TMEA_AZURE_DEVOPS - 3 AM daily
schtasks /create /tn "DRIVER_TMEA_AZURE_DEVOPS" /tr "F:\Shares\mini\batch\DRIVER_TMEA_AZURE_DEVOPS.bat" /sc daily /st 03:00 /f


#DRIVER_FINANCE - 4 times daily (1:58 AM, 10 AM, 3 PM, 7 PM):
schtasks /create /tn "Pipeline_DRIVER_FINANCE_0158" /tr "F:\Shares\mini\batch\DRIVER_FINANCE.bat" /sc daily /st 01:58 /f
schtasks /create /tn "Pipeline_DRIVER_FINANCE_1000" /tr "F:\Shares\mini\batch\DRIVER_FINANCE.bat" /sc daily /st 10:00 /f
schtasks /create /tn "Pipeline_DRIVER_FINANCE_1500" /tr "F:\Shares\mini\batch\DRIVER_FINANCE.bat" /sc daily /st 15:00 /f
schtasks /create /tn "Pipeline_DRIVER_FINANCE_1900" /tr "F:\Shares\mini\batch\DRIVER_FINANCE.bat" /sc daily /st 19:00 /f




Write-Host "All tasks created successfully!"
