

# 📋 5S Audit Tool Manual  
*Internal Audit Services Office - Province of Pangasinan*  
**Version**: 1.0.0  
*Built with Flutter & SQLite*

## 🏠 Home Page 
The home page displays your past saved audits. You can:

- **View audit results**: Tap on any audit to see its detailed results
- **Delete an audit**: Press and hold an audit, then select "Delete"
- **Start new audit**: Tap the "Start New Audit" button to begin a new evaluation

## 🆕 New Audit Page  
This is where you configure a new audit:

1. **Select audit type**: Choose the type of audit you want to conduct
2. **Audit period**: Select the semester and year
3. **Team leader**: Enter the team leader's name in the text field
4. **Team Members**: Enter the team Members's name in the text field up to 5 Members
5. **Department management**:
   - Add new departments
   - Rename existing departments
   - Delete departments 
6. **Area management(only in Hard S)** (within selected department):
   - Add new areas
   - Rename existing areas
   - Delete areas 

Once all required fields are completed, the "Start Audit" button will become active. Tap it to proceed to the checklist.

## ✔️ Checklist Evaluation Page
**Evaluation Interface**:  
✔ Yes/No toggle buttons for each criteria  
📝 Remarks field for additional notes  
📊 Real-time scoring display  
🔢 Questions remaining counter  
📷 Attach images (camera/gallery) - multiple allowed

**Submission**:  
✅ "Submit" button appears when all items are answered  

## 📊 Results Page
Displays the complete audit results including:

1. **Audit information**:
   - Audit Type
   - Department and area
   - Team leader
   - Team Members
   - Audit period
   - Date conducted

2. **Scoring summary**:
   - Overall score
   - Breakdown by 5S categories

3. **Detailed question responses**:
   - All questions with your answers
   - Any remarks you entered
   - All attached images 
**Available actions**:
- : 🏠: **Home button**: Returns to the main screen
- : ✏️: **Edit button**: Lets you modify your answers
- : 📄: **PDF button**: Generates a shareable report

## 📄 PDF Report System
When generating a PDF:

- **File naming**: Automatically saved as:  
  `[Date]_[Department]_[Area].pdf`
  
- **Storage location**:  
  `Internal Storage/Download/Brum PDF Files/`

- **Sharing options**:
  - Email clients (Gmail, Outlook, etc.)
  - Messaging apps (WhatsApp, Messenger, etc.)
  - Cloud services (Google Drive, Dropbox, etc.)

- **Printing capabilities**:
  - Mobile printer compatible
  - AirPrint supported
  - Other wireless printing protocols

---
**Developed by**:  
Ernes Glenn C. Dalope  
Kwincy Camille Pacis  

**Copyright © 2025**  
All rights reserved  
