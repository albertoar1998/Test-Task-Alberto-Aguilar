For Testing purposes:

Create two Folders, for example in Desktop. 'FileA' and 'FileB'. Generate some files in 'FileA' so content
will be copied to 'FileB'. Script 'Sync-Source-Replica.ps1' must be placed in 'FileA'.

Open Powershell, cd to Desktop / FileA.

Run command .\yourScriptName.ps1 -sourceFolder "C:\Users\User\Desktop\yourFileA" -replicaFolder "C:\Users\User\Desktop\yourFileB" -logFile "C:\logfile.txt"

After running this, synchronization will start. User will see some logs in console indicating:
- Directory created / removed
- File copied / removed

If user wants to open the .txt log, run command notepad "C:\path\to\logfile.txt"

