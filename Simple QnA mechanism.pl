% Simple QnA mechanism

legal_question_answer(Question) :-
    legal_fact(Question, Answer),
    write(Answer), nl.

legal_question_answer(_) :-
    write('Sorry, I don\'t have an answer to that question. Please try asking something else.'), nl.

% Main interaction loop
start :-
    write('Welcome to the Legal Assistant! How can I help you today?'), nl,
    repeat,
    write('You: '), read(Question),
    legal_question_answer(Question),
    (Question == 'exit' -> ! ; fail).
