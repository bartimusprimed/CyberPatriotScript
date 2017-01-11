Function ReadCSV {
    clear
#Get File Location
    Write-Host "Please enter the location of your .csv"
    Write-Host "ex. c:\data.csv"
    Read-Host "File Location: "
}


Function recordCount($csvFile) {
#Ensure Proper Records
    Write-Host "Found $($csvFile.length) Records"
    Write-Host "These are the following Records"

    ForEach ($record in $csvFile) {
        Write-Host $record 
    }

    $answer = Read-Host "Is this correct? (Y/N)"
    
    switch ($answer) {
     Y { return }
     N { Menu }
    }


}

Function DoCSV($fields) {
#Grab CSV and set headers
    $csvLocation = ReadCSV
    Clear
    Write-Host "Reading in csv File (format: $fields)"
    $csvFile = Import-Csv $csvLocation  -Header $($fields.split(","))
    recordCount($csvFile)
    return $csvFile
}

Function Addusers {
#Add users
    $csvFile = DoCSV("Username,Password,AccountType,Status")

    
    ForEach ($record in $csvFile) {

        Write-Host "Creating $($record.Username) with password: $($record.Password)"
        net user $record.Username $record.Password /ADD

        if ($record.AccountType -eq "Admin" -or  $record.AccountType -eq "Administrator") {
            Write-Host "$($record.Username) is part of Admin Group"
            net localgroup administrators $record.Username /ADD
        }
        if ($record.Status -eq "Disabled") {
            Write-Host "$($record.Username) is Disabled"
            net user $record.Username /ACTIVE:NO
        }

    }
    Write-Host "Users added"
    net users
    Read-Host "Press Enter to Continue"
    Menu
}


Function CreateDirectory {
#Add Directories
    $csvFile = DoCSV("Path,HiddenVisible,Owner")

    ForEach($record in $csvFile) {
        
        Write-Host "Creating Directory with $($record.Path) as $($record.HiddenVisible) with owner $($record.owner)"
        New-Item $record.Path -ItemType Directory
        takeown /S %computername% /U $record.owner /F $record.Path /R /D Y

        if ($record.HiddenVisible -eq "Hidden") {
            Write-Host "Changing $($record.Path) to hidden"
            attrib +h $record.Path
        }
        dir $record.Path
    }
    Read-Host "Press Enter to Continue"
    Menu
}


Function Menu {
    clear
    Write-Host "Cyber Patriot V1"
    Write-Host "-----------------------"
    Write-Host "1. Add Users"
    Write-Host "2. Create Directories"
    Write-Host "3. Basic Configuration"
    Write-Host "4. Registry Keys"
    Write-Host "5. Run Commands"
    Write-Host "6. Create Shortcuts"
    Write-Host "0. Exit"
    Write-Host "-----------------------"
    Write-Host "All commands take a .csv file location. Please ensure they are in the correct format"

    $selection = Read-Host "Selection: "

    switch ($selection) {
        1 {AddUsers}
        2 {CreateDirectory}
        0 {Exit}
        default {Menu}

    }





}

Menu
