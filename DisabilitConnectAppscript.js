function doPost(e) {
  try {
    // Use your specific sheet ID
    const sheet = SpreadsheetApp.openById('1EX_9SJZ1Au4NOMag91YtZC48Fs5kWBlXtyK3auolzA8').getActiveSheet();
    const rawData = e.postData.contents;

    // Parse JSON (handles text/plain from frontend)
    const data = JSON.parse(rawData);

    // CHANGE 1: Validation - Require email, trim/validate basics
    if (!data.email || typeof data.email !== 'string' || data.email.trim() === '') {
      return ContentService.createTextOutput(JSON.stringify({
        success: false,
        error: 'Missing or invalid email address required for registration.'
      })).setMimeType(ContentService.MimeType.JSON);
    }
    data.email = data.email.toLowerCase().trim();  // Normalize for case-insensitivity

    // Optional: Validate name if present
    if (data.name) {
      data.name = data.name.trim().substring(0, 100);  // Sanitize: trim & limit length
    }
    if (data.userCountry) {
      data.userCountry = data.userCountry.trim().substring(0, 50);
    }
    if (data.serviceCountry) {
      data.serviceCountry = data.serviceCountry.trim().substring(0, 50);
    }
    // --- NEW: Sanitize city and postcode ---
    if (data.city) {
      data.city = data.city.trim().substring(0, 100);
    }
    if (data.postcode) {
      data.postcode = data.postcode.trim().substring(0, 20);
    }
    // ----------------------------------------


    const lastRow = sheet.getLastRow();
    let rowFound = false;

    // Look for existing user by normalized email
    if (lastRow > 1) {
      const emailColumn = sheet.getRange(2, 3, lastRow - 1, 1).getValues();
      for (let i = 0; i < emailColumn.length; i++) {
        const existingEmail = emailColumn[i][0] ? emailColumn[i][0].toString().toLowerCase().trim() : '';
        if (existingEmail === data.email) {
          // CHANGE 2: Update existing row - Refresh all fields + timestamp
          const rowIndex = i + 2;
          const timestamp = new Date();  // CHANGE 3: Use formatted date
          const formattedDate = Utilities.formatDate(timestamp, Session.getScriptTimeZone(), 'yyyy-MM-dd HH:mm:ss');

          sheet.getRange(rowIndex, 1).setValue(formattedDate);  // Timestamp (Col 1)
          sheet.getRange(rowIndex, 2).setValue(data.name || '');  // Name (Col 2)
          sheet.getRange(rowIndex, 3).setValue(data.email);  // Email (Col 3)
          sheet.getRange(rowIndex, 4).setValue(data.userCountry || '');  // User Country (Col 4)
          sheet.getRange(rowIndex, 5).setValue(data.serviceCountry || '');  // Service Country (Col 5)
          // --- NEW: Update city and postcode (Cols 6 & 7) ---
          sheet.getRange(rowIndex, 6).setValue(data.city || '');
          sheet.getRange(rowIndex, 7).setValue(data.postcode || '');
          // ----------------------------------------------------
          // Status remains unchanged (Col 8, assuming 2 new columns were added)

          rowFound = true;
          Logger.log(`Updated row ${rowIndex} for email: ${data.email}`);
          break;
        }
      }
    }

    // If not found, add new row
    if (!rowFound) {
      const timestamp = new Date();
      const formattedDate = Utilities.formatDate(timestamp, Session.getScriptTimeZone(), 'yyyy-MM-dd HH:mm:ss');
      sheet.appendRow([
        formattedDate,  // Timestamp (Col 1)
        data.name || '',  // Name (Col 2)
        data.email,  // Email (Col 3)
        data.userCountry || '',  // User Country (Col 4)
        data.serviceCountry || 'Not yet selected',  // Service Country (Col 5)
        // --- NEW: Append city and postcode (Cols 6 & 7) ---
        data.city || '',
        data.postcode || '',
        // ----------------------------------------------------
        'Active' // Status (Col 8)
      ]);
      Logger.log(`Added new row for email: ${data.email}`);
    }

    return ContentService.createTextOutput(JSON.stringify({
      success: true,
      message: 'Data saved successfully'
    })).setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    // CHANGE 4: Enhanced logging
    Logger.log('Error in doPost: ' + error.toString() + '\nRaw data: ' + (e ? e.postData.contents : 'No data'));
    return ContentService.createTextOutput(JSON.stringify({
      success: false,
      error: 'Server error: Please try again or contact support.'
    })).setMimeType(ContentService.MimeType.JSON);
  }
}

function doGet(e) {
  return ContentService.createTextOutput('DisabilityConnect User Registration API - Active');
}

// Test function to verify sheet access
function testSheetAccess() {
  try {
    const sheet = SpreadsheetApp.openById('1EX_9SJZ1Au4NOMag91YtZC48Fs5kWBlXtyK3auolzA8').getActiveSheet();
    Logger.log('Sheet name: ' + sheet.getName());
    Logger.log('Last row: ' + sheet.getLastRow());
    Logger.log('Success! Sheet is accessible.');
  } catch (error) {
    Logger.log('Error: ' + error.toString());
  }
}
