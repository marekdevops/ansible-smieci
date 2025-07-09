chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    if (request.action === "clickElement") {
      var searchButton = document.querySelector('button.btn-standard.call-to-action');
  
      if (searchButton) {
        searchButton.click();  // Kliknij przycisk "Search"
        console.log("Kliknięto przycisk Search.");
      } else {
        console.log("Nie znaleziono przycisku Search.");
      }
    }
  });
  