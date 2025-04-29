// function sendMessage() {
//     const inputField = document.getElementById('user-input');
//     const message = inputField.value.trim();
//     if (message === '') return;

//     addMessage('user', message);
//     inputField.value = '';

//     // Simulate bot response
//     setTimeout(() => {
//         generateBotResponse(message);
//     }, 500);
// }

// function addMessage(sender, text) {
//     const chatMessages = document.getElementById('chat-messages');
//     const messageDiv = document.createElement('div');
//     messageDiv.classList.add('message', sender === 'user' ? 'user-message' : 'bot-message');
//     messageDiv.innerText = text;
//     chatMessages.appendChild(messageDiv);
//     chatMessages.scrollTop = chatMessages.scrollHeight; // Scroll to bottom
// }

// function generateBotResponse(userMessage) {
//     // Here you would call your backend (Flask+Prolog)
//     // For now, just simulate a simple response
//     const botReply = "You said: " + userMessage;
//     addMessage('bot', botReply);
// }
function sendMessage() {
  const userInput = document.getElementById("user-input");
  const articleId = userInput.value.trim();
  if (articleId === "") return;

  // Send message to the chat
  addMessage("user", `Get Article ${articleId}`);

  // Call Flask backend
  fetch("http://localhost:5000/query_article", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ article_id: articleId }),
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.result) {
        addMessage("bot", data.result);
      } else {
        addMessage("bot", "Sorry, I could not fetch the article.");
      }
    })
    .catch((error) => {
      console.error("Error:", error);
      addMessage("bot", "Error while fetching article.");
    });

  // Clear the input field after sending the message
  userInput.value = "";
}

// Function to add a message to the chat
function addMessage(sender, text) {
  const chatMessages = document.getElementById("chat-messages");
  const messageDiv = document.createElement("div");
  messageDiv.classList.add(
    "message",
    sender === "user" ? "user-message" : "bot-message"
  );
  messageDiv.innerText = text;
  chatMessages.appendChild(messageDiv);
  chatMessages.scrollTop = chatMessages.scrollHeight; // Scroll to the latest message
}

// Add event listener for "Enter" key press to trigger sendMessage function
document
  .getElementById("user-input")
  .addEventListener("keypress", function (event) {
    if (event.key === "Enter") {
      sendMessage();
    }
  });
