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
    const articleId = document.getElementById('user-input').value.trim();
    if (articleId === '') return;

    addMessage('user', `Get Article ${articleId}`);

    // Call Flask backend
    fetch('http://localhost:5000/query_article', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ article_id: articleId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.result) {
            addMessage('bot', data.result);
        } else {
            addMessage('bot', 'Sorry, I could not fetch the article.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        addMessage('bot', 'Error while fetching article.');
    });
}

function addMessage(sender, text) {
    const chatMessages = document.getElementById('chat-messages');
    const messageDiv = document.createElement('div');
    messageDiv.classList.add('message', sender === 'user' ? 'user-message' : 'bot-message');
    messageDiv.innerText = text;
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}
