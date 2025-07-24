import-Module "$PWD\NoveLib\NoveLib.psm1" -Force

# Force - Errore se ci sono file
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\"

# DispalyMode con e senza file info e decimal place
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileOnly -DecimalPlaces 1
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileOnly -DisplayFileInfo -DecimalPlaces 2
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode ByteOnly -DecimalPlaces 3
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode ByteOnly -DisplayFileInfo -DecimalPlaces 4
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileAndByte -DecimalPlaces 5
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileAndByte -DisplayFileInfo -DecimalPlaces 6



# Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileOnly -DecimalPlaces 1 -Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileOnly -DisplayFileInfo -DecimalPlaces 2 -Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode ByteOnly -DecimalPlaces 3 -Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode ByteOnly -DisplayFileInfo -DecimalPlaces 4 -Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileAndByte -DecimalPlaces 5 -Stream
Copy-FileProgress -Source "C:\Temp\1\" -Destination "C:\Temp\2\" -Force -DisplayMode FileAndByte -DisplayFileInfo -DecimalPlaces 6 -Stream