function Get-MSOLUser
<#
.Synopsis
   Finds a user in Office 365
.DESCRIPTION
   Input a users Office 365 User Principle Name and this CMDlet will output more details on it.
   The CMDlet allows you to search for a user without having to specify the MsolPartnerContract ID
   as it uses the domain name to search for this.
.EXAMPLE
   Get-MsolUser Someuser@someDomain.com
#>
{

    Param
    (
        [cmdletbinding()]
        #Input needs to be a string and the full UPN name of the user. Script will fail if format is not username@domainname.com
        [Parameter(Mandatory=$true, Position=0)]
        [string]$UserPrincipalName

    )

    Begin
    {
        try{
            write-verbose "Getting the user and splitting the domain name from the user"
            $username = $UserPrincipalName.split('@')[0]
            Write-Verbose "Storing the domain name and user section in seperate variables"
            $domain = $UserPrincipalName.split('@')[1]
            }
        catch{
            #Do not want the command to keep running if it cannot split the UPN
            $caughtError = $error[0]
            $caughtError
            break
            }
        }
    Process
    {
        Write-Verbose "Getting the domain name and searching for the tenant ID from it"
        #This does not need to be in a try block as it should fail itself if it cannot find the MsolPartnerContract.
        $tenant = Get-MsolPartnerContract -DomainName $domain

        try{
            Write-verbose "Takes the tenantID and the full UPN to find the user in office365"
            $user = Get-MsolUser -TenantId $tenant.tenantID -UserPrincipalName $UserPrincipalName -ErrorAction stop
        }

        catch{
            #I want the script to fail if it cannot find the user within that tenancy.
            $CaughtError = $error[0]
            $CaughtError
            Break
        }

        Write-Verbose "Creates an object with the users information"
        #using the [ordered] means it outputs the same order as specified below.
        $object =[ordered]@{
            UPN = $user.userprincipalname
            FirstName = $user.Firstname
            LastName = $user.Lastname
            Displayname = $user.displayname
            Role = $user.title
            OtherEmail = $user.proxyaddresses
            ImmutableID = $user.immutableID
            License = $user.Licenses
        }

        $details = New-Object PSCustomObject -Property $object

    }
    End
    {
        $details
    }
}