
##########################################################################
##########################################################################
##  
##  File: besp_main.ps1
##  Usage: ./besp_main.ps1 
##  S.O: Windows Server 2016 STD
##  Options: No options 
##  Requiriments: 
##      - Enable Unrestricted Script Executions
##      - DHCP Enable on prefered network (Service Interface)
##
##  Autor: SQUAD BESP XXXXX
##  DEV: Miguel Angel Amador Lorca <miguelcl@devnet.cl> 
##                                 github: @miguelcl
##       
##
##
##  
##  COMPANY: XXXXXXXXXXX
##  VERSION: 1.0
##  CREATED: 10-DIC-2018
##  
##
###########################################################################
###########################################################################


## Global Vars:

$vSW = "C:\besp\sw.pid"           #Archivo para llevar el control de reinicios/bloques de script
$vTmpVars = "C:\besp\vars.ini"    #Archivo de paso para variables entre Reinicios 
$DNSSERVER="10.108.1.1"           # IP del servidor DNS
$vRestartCount = 0                # Numero de Reinicios 

if(!(Test-Path $vSW -PathType Leaf)){
    SetswitchCase -NumberOfRestart $vRestartCount 
}

# setSwitchCase:  
# Increase value in file after restart
function setSwitchCase($NumberOfRestart){
    echo "$numberOfRestart" | Set-Content -Path $vSW
}

# getSwitchCase():
# Get the last execution after restart
# And Run the next block of code
 
function getSwitchCase(){
    
    #numero extraido desde el archivo

    $i = Get-Content  -Path $vSW
    
    #echo $i
    #echo $i.Length
    #echo $i.Substring(0,1)
    if ( $i -eq 0){ 
        Write-Host "0" 
        $vRestartCount = 1
        setSwitchCase  -NumberOfRestart $vRestartCount
        }

    if ( $i -eq 1){ 
        Write-Host "1" 
        $vRestartCount = 2
        setSwitchCase  -NumberOfRestart $vRestartCount
        }
    if ( $i -eq 2){ 
        Write-Host "2" 
        $vRestartCount = 3
        setSwitchCase  -NumberOfRestart $vRestartCount
        }
    if ( $i -eq 3){ 
        Write-Host "3" 
        $vRestartCount = 4
        setSwitchCase  -NumberOfRestart $vRestartCount
        }
    if ( $i -eq 4){ 
        Write-Host "4" 
        $vRestartCount = 5
        setSwitchCase  -NumberOfRestart $vRestartCount
        }
    if ( $i -eq 5){ 
        Write-Host "5" 
        $vRestartCount = 6
        setSwitchCase  -NumberOfRestart $vRestartCount
        }
}

getSwitchCase


#######################################################################################



#### Test OK ########################################################################### 
########################################################################################
########################################################################################

#echo "" | Set-Content -Path C:\besp\besp_win2016std.log

    $vSTR = "script:besp_main.ps1:Executed-OK" 
    #REM Invoke-Expression -Command "echo $vSTR >> C:\besp\besp_win2016std.log" 

#### Disable IPv6  #####################################################################
########################################################################################
########################################################################################


    #REM Get-NetAdapterBinding -ComponentID 'ms_tcpip6' | disable-NetAdapterBinding -ComponentID ms_tcpip6 -PassThru


#### SetDNSClient to 10.108.1.1  #######################################################
########################################################################################
########################################################################################

$vIfaces = Get-NetAdapter

foreach ( $vIface in $vIfaces ){
    #echo $vIface
    $vsw = Get-DnsClientServerAddress -InterfaceAlias $vIface.Name
    #echo $vsw.ServerAddresses
    $vv = $vsw.ServerAddresses
    if ( $vv -eq $DNSSERVER ){
      #echo $vv
      $vNICLan = $vIface.Name
      #REM Set-DnsClientServerAddress  -InterfaceAlias $vNICLan -ServerAddresses $DNSSERVER
    }
}


#### Set NIC Lan Productiva con IP's de manera Manual (quitar DHCP y configurar estatica)
########################################################################################
########################################################################################


# Traer configuracion de Red dada por DHCP. se captura en las variables vNetLan_*

        echo $vNICLan
        $vIfaces = Get-NetAdapter
        echo "-------------#############-------------"
        $vIFacesTMP = Get-NetIPConfiguration -InterfaceAlias  $vNICLan
        $X = Get-NetIPConfiguration -InterfaceAlias $vNICLan
        $vNetLan_GW   = $X.IPv4DefaultGateway.NextHop
        $vNetLan_IP   = $X.IPv4Address.IpAddress
        $vNetLan_Prefix = $X.IPv4Address.PrefixLength 
        $vNetLan_DNS  = $DNSSERVER
    
        if ( $vNetLan_Prefix -eq 22 ){  $vNetLan_Mask = "255.255.252.0" }
        elseif ( $vNetLan_Prefix -eq 23 ){ $vNetLan_Mask = "255.255.254.0"         }
        elseif ( $vNetLan_Prefix -eq 24 ){ $vNetLan_Mask = "255.255.255.0"         }
        elseif ( $vNetLan_Prefix -eq 25 ){ $vNetLan_Mask = "255.255.255.128"       }
        elseif ( $vNetLan_Prefix -eq 26 ){ $vNetLan_Mask = "255.255.255.192"       }
        elseif ( $vNetLan_Prefix -eq 27 ){ $vNetLan_Mask = "255.255.252.224"       }
        elseif ( $vNetLan_Prefix -eq 28 ){ $vNetLan_Mask = "255.255.252.240"       }
        elseif ( $vNetLan_Prefix -eq 29 ){ $vNetLan_Mask = "255.255.252.248"       }
        else { $vNetLan_Mask = "" }


   
        Write-Host "IP Lan Prod        :  $vNetLan_IP"   
        Write-Host "Mascara de Red Lan :  $vNetLan_Mask"
        Write-Host "IP Gateway         :  $vNetLan_GW"
        Write-Host "Servidor DNS       :  $vNetLan_DNS"         
        
        # opcion PS en Desarrollo:
        #New-NetIPAddress -InterfaceAlias $vNICLan  -IPAddress $vNetLan_IP  -AddressFamily IPv4 -DefaultGateway $vNetLan_GW -Confirm -PrefixLength $vNetLan_M
       

        ## Configura Interfaz de Red que tenia como DHCP a configuracion IP estatica.
        #REM Invoke-Expression -Command "netsh interface ipv4 set address name=$vNICLan static $vNetLan_IP  $vNetLAN_Mask $vNetLan_GW"
        # Get-NetIPConfiguration -InterfaceAlias $vNICLan 


########################################################################################
##### DNS :: Configuracion de nombre de Equipo #########################################
########################################################################################

Write-Host "###########################################################################" -ForegroundColor Yellow
Write-Host "###########################################################################" -ForegroundColor Cyan



#Invoke-WebRequest -Uri http://besp.falabella.com/repo/site.dat  -Method Get -UserAgent BespAgent  | Select-String -Pattern $vNetLan_GW

$vStrTMP = Invoke-WebRequest -Uri http://besp.falabella.com/repo/win2016std -UserAgent "BESPScriptAgent" -Method Get| Select-String -Pattern "fqdn"
$ServerNameNew = $vStrTMP.ToString().Substring(7,9)
$ServerNameOld = $env:COMPUTERNAME


Write-Host $ServerNameNew  -ForegroundColor Green
Write-Host $ServerNameOld -ForegroundColor Green

Rename-Computer -ComputerName $ServerNameOld -NewName $ServerNameNew   -Force 

#-LocalCredential $OldName\administrator
  

########################################################################################
########################################################################################
########################################################################################        

#SubSTR
#$TextlabelUsername.text = $str.Substring(0, [math]::Min(5, $str.Length))

# Trae Linea con GW de red: 
# $X = (Get-Content .\site.dat.txt ) -match '10.245.12.1'
# $X = Get-ChildItem .\site.dat.txt | Select-String -Pattern 10.245.12.1

#### Comandos de Limpieza.
####

#Set-ExecutionPolicy Unrestricted -Force
#REM Invoke-Expression -Command "mkdir C:\besp\tmp"
#REM Invoke-Expression -Command "del C:\besp\*.ps1"


########################################################################################
########################################################################################
########################################################################################
###########****  EOC SCRIPT - START RUN  ****##################################
