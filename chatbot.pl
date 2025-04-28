% --------------------------------------------
% Chatbot for Constitution (Clean Text Version)
% --------------------------------------------

% Load the constitution facts
:- consult('constitution.pl').

% Lowercase text
lowercase(Text, Lower) :-
    string_lower(Text, Lower).

% --- Clean Text: Fix common wrong characters ---
clean_text(Text, Cleaned) :-
    replace_all(Text, "â€”", "-", T1),
    replace_all(T1, "â€“", "-", T2),
    replace_all(T2, "Â", "", T3),
    replace_all(T3, "Ã", "A", T4),
    replace_all(T4, "â€™", "'", T5),
    replace_all(T5, "‘", "'", T6),
    replace_all(T6, "’", "'", T7),
    replace_all(T7, "“", '"', T8),
    replace_all(T8, "”", '"', Cleaned).

% Replace all occurrences of Search with Replace
replace_all(Text, Search, Replace, Result) :-
    split_string(Text, Search, "", Parts),
    atomic_list_concat(Parts, Replace, Result).

% --- Find article by direct number match ---
find_article_in_text(Text, ArticleNo) :-
    article(ArticleNo, _, _),
    atom_string(ArticleAtom, ArticleNo),
    sub_string(Text, _, _, _, ArticleAtom).

% --- Find article by matching keywords inside title/description ---
find_article_by_keywords([], _) :- fail.
find_article_by_keywords([Word|Words], ArticleNo) :-
    article(ArticleNo, Title, Description),
    lowercase(Title, LTitle),
    lowercase(Description, LDesc),
    (sub_string(LTitle, _, _, _, Word) ; sub_string(LDesc, _, _, _, Word))
    ;
    find_article_by_keywords(Words, ArticleNo).

% --- Answer based on question ---
answer(Question) :-
    lowercase(Question, LQuestion),
    clean_text(LQuestion, CleanQuestion),
    split_string(CleanQuestion, " ", " ", Words),
    (   find_article_in_text(CleanQuestion, ArticleNo)
    ->  article(ArticleNo, Title, Description),
        clean_text(Description, CleanDesc),
        format('~n[Article ~w: ~w]~n~w~n', [ArticleNo, Title, CleanDesc])
    ;   find_article_by_keywords(Words, ArticleNo)
    ->  article(ArticleNo, Title, Description),
        clean_text(Description, CleanDesc),
        format('~n[Article ~w: ~w]~n~w~n', [ArticleNo, Title, CleanDesc])
    ;   write('Sorry, I could not find the answer to your question.'), nl
    ).

% --- Chatbot Loop ---
chatbot :-
    write('Ask me about the Constitution (type "exit." to quit):'), nl,
    repeat,
    write('> '),
    read_line_to_string(user_input, Question),
    (Question == "exit" -> write('Goodbye!'), nl, ! ;
     answer(Question),
     fail).
