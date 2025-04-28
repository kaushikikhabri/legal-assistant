function sendMessage() {
    const inputField = document.getElementById('user-input');
    const message = inputField.value.trim();
    if (message === '') return;

    addMessage('user', message);
    inputField.value = '';

    // Simulate bot response
    setTimeout(() => {
        generateBotResponse(message);
    }, 500);
}

function addMessage(sender, text) {
    const chatMessages = document.getElementById('chat-messages');
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', sender === 'user' ? 'user-message' : 'bot-message');
    messageDiv.innerText = text;
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight; // Scroll to bottom
}

function generateBotResponse(userMessage) {
    // Here you would call your backend (Flask+Prolog)
    // For now, just simulate a simple response
    const botReply = "You said: " + userMessage;
    addMessage('bot', botReply);
}
