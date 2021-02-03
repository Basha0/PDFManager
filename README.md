# pdfmanager

- For now only tested/working on Android. 
- For iOS I have to change the storage handling and also add Permission options in info.plist etc. 

# TODO
- Add storage handling for iOS.
- Add Permission handling iOS.
- Add Connection hadnling.(What happens if no internet connection)

- Change the PDF Reader plugin.

# Main Plugins I am using
- "hive" for the local Database: https://pub.dev/packages/hive
- "GetX" for State Managment: https://pub.dev/packages/get
- "permission_handler" for Permission handling: https://pub.dev/packages/permission_handler
- "flutter_pdfview" for being able to open PDF files in the App: https://pub.dev/packages/flutter_pdfview (Will change that, as the pdf_reader is very basic)


# Why i created this project

For my own use. I read some stuff mostly dowloaded from the internet, and i dont like the avaible PDF managers as they doesn't have feature i like to have while reading the PDF's. I want to have something like a libarary as a App, where i can create "Books" with cover and a Custom description. Also being able to add maybe something like "chapters" to the "Books". Those "Chapters" are PDF's downloaded from the internet, where as i can give them a custom name. Also i want to persist the last page for each chapter where I stopped reading so can continue next time.
