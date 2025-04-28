:- consult('constitution.pl').

get_article(ArticleNo) :-
    article(ArticleNo, Title, Description),
    format('Title: ~w~nDescription: ~w~n', [Title, Description]).

start :-
    write('Enter the article number: '),
    read(UserInput),
    get_article(UserInput).
