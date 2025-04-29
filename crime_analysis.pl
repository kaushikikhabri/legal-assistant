% Existing crime types
ipc_keywords('theft', ['steal', 'stole', 'theft', 'rob', 'robbed', 'robbery', 'snatch', 'snatched']).
ipc_keywords('murder', ['murder', 'murdered', 'kill', 'killed', 'homicide']).
ipc_keywords('assault', ['hit', 'hit', 'assault', 'assaulted', 'attack', 'attacked', 'beat', 'beaten']).
ipc_keywords('sexual assault', ['rape', 'raped', 'molest', 'molested', 'sexual', 'assaulted sexually']).

% New crime types
ipc_keywords('burglary', ['burgle', 'burgled', 'break in', 'broke in', 'break into', 'breaking', 'break-in']).
ipc_keywords('robbery', ['rob', 'robbed', 'hold up', 'held up', 'mug', 'mugged', 'armed robbery', 'armed robbery', 'bag snatch']).
ipc_keywords('fraud', ['fraud', 'defraud', 'defrauded', 'cheat', 'cheated', 'swindle', 'swindled', 'con', 'conned']).
ipc_keywords('domestic violence', ['abuse', 'abused', 'domestic violence', 'beat', 'beaten', 'hurt', 'hurted', 'attack', 'attacked', 'batter', 'battered', 'spouse abuse']).

% Example of matching other crime types
ipc_keywords('kidnapping', ['kidnap', 'kidnapped', 'abduct', 'abducted', 'capture', 'captured']).
ipc_keywords('vandalism', ['vandalize', 'vandalized', 'destroy', 'destroyed', 'damage', 'damaged', 'deface', 'defaced']).
ipc_keywords('drug trafficking', ['drug trafficking', 'smuggle', 'smuggled', 'distribute', 'distributed', 'deal', 'dealt']).
ipc_keywords('bribery', ['bribe', 'bribed', 'corrupt', 'corrupted', 'offer a bribe', 'offered a bribe']).

% IPC section mapping
ipc_section(302, 'Murder').
ipc_section(378, 'Theft').
ipc_section(323, 'Assault').
ipc_section(376, 'Rape').
ipc_section(392, 'Robbery').
ipc_section(307, 'Attempt to Murder with a Firearm').
ipc_section(307, 'Attempt to Murder with a Knife').
ipc_section(326, 'Voluntarily Causing Grievous Hurt').
ipc_section(324, 'Voluntarily Causing Hurt with Dangerous Weapons or Means').
ipc_section(302, 'Murder with Fatality').
ipc_section(324, 'Hurt with Injuries').

% Penalties (expand for other sections)
penalty(section_302, 'Death penalty or life imprisonment.').
penalty(section_307, 'Imprisonment up to 10 years and fine.').
penalty(section_376, 'Imprisonment not less than 7 years, may extend to life imprisonment.').
penalty(section_378, 'Imprisonment up to 3 years, or fine, or both.').
penalty(section_392, 'Imprisonment between 3 to 10 years and fine.').
penalty(section_323, 'Imprisonment up to 1 year or fine or both.').
penalty(section_326, 'Imprisonment up to 10 years and fine.').
penalty(section_324, 'Imprisonment up to 3 years, or fine, or both.').

% Legal recommendations
recommendation(section_302, 'Immediately inform police and preserve the crime scene. Seek legal representation.').
recommendation(section_307, 'Report to police and ensure medical help for the victim. Legal follow-up needed.').
recommendation(section_376, 'Approach women’s help center and report to police. Immediate legal and psychological aid advised.').
recommendation(section_378, 'File an FIR for theft and submit evidence if available.').
recommendation(section_392, 'Report robbery to nearest police station with any available details.').
recommendation(section_323, 'Medical report required. File a police complaint.').
recommendation(section_324, 'Visit hospital and report incident to police. Document injuries.').
recommendation(section_326, 'Serious injuries need medical documentation and legal reporting.').

display_recommendation(Section) :-
    number(Section),
    number_string(Section, SectionStr),
    atom_concat(section_, SectionStr, SectionAtom),
    (   recommendation(SectionAtom, Action)
    ->  format('Recommended Action: ~w~n', [Action])
    ;   writeln('No specific recommended action available.')
    ).


% Capitalize helper
capitalize(Atom, CapitalizedAtom) :-
    atom_chars(Atom, [FirstChar | RestChars]),
    upcase_atom(FirstChar, CapitalizedFirstChar),
    atom_chars(CapitalizedAtom, [CapitalizedFirstChar | RestChars]).

% Match crime description with possible IPC sections (using all types)
match_ipc(CrimeDescription, Matches) :-
    split_string(CrimeDescription, " ", ".,!? ", RawWords),
    maplist(string_lower, RawWords, Words),
    findall(
        Section,
        (   ipc_section(Section, CrimeType),
            ipc_keywords(_, Keywords),
            has_keyword(Words, Keywords)
        ),
        Sections
    ),
    list_to_set(Sections, Matches).

has_keyword(Words, Keywords) :-
    member(Word, Words),
    member(Keyword, Keywords),
    sub_string(Word, _, _, _, Keyword), !.

% Display IPC Section + Penalty
display_ipc_result(CrimeDescription) :-
    match_ipc(CrimeDescription, Matches),
    (   Matches = [] ->
        writeln('No IPC section matched. Please consult a legal expert.')
    ;   writeln('Matched IPC Sections and Penalties:'),
        forall(
            member(Section, Matches),
            (   format('~w: ', [Section]),
                display_penalty(Section)
            )
        )
    ).

display_penalty(Section) :-
    number(Section),
    number_string(Section, SectionStr),
    atom_concat(section_, SectionStr, SectionAtom),
    (   penalty(SectionAtom, Penalty)
    ->  format('Penalty: ~w~n', [Penalty])
    ;   writeln('Penalty information not available.')
    ).

% Updated to classify using all ipc_keywords regardless of input CrimeTypes
classify_crime(CrimeDescription, WeaponUsed, WeaponType, VictimStatus) :-
    classify_crime_details(CrimeDescription, WeaponUsed, WeaponType, VictimStatus).

classify_crime_details(CrimeDescription, WeaponUsed, WeaponType, VictimStatus) :-
    findall((Section, CrimeType, ConfidenceScore),
        (   ipc_keywords(CrimeType, Keywords),
            match_keywords(CrimeDescription, Keywords, ConfidenceScore),
            ConfidenceScore > 0,
            capitalize(CrimeType, Capitalized),
            ipc_section(Section, Capitalized)
        ),
        Matches),
    (   Matches = []
    ->  writeln('No IPC sections matched. Please consult a legal expert.')
    ;   display_matches(Matches)
    ),
    classify_weapon_related_crime(WeaponUsed, WeaponType),
    classify_victim_status(VictimStatus).

display_matches([]).

display_matches([(Section, CrimeType, ConfidenceScore) | Rest]) :-
    format('Matched IPC Section: ~w for crime ~w with confidence: ~2f~n', [Section, CrimeType, ConfidenceScore]),
    display_penalty(Section),
    display_recommendation(Section),
    nl,  % <-- Adds a blank line between each match block
    display_matches(Rest).

match_keywords(_, [], 0).
match_keywords(CrimeDescription, Keywords, ConfidenceScore) :-
    findall(Keyword,
        (   member(Keyword, Keywords),
            sub_string(CrimeDescription, _, _, _, Keyword)
        ),
        Matched),
    length(Keywords, Total),
    length(Matched, Count),
    (   Total > 0 -> ConfidenceScore is (Count / Total) * 100 ; ConfidenceScore = 0).

% Weapon-based classification
classify_weapon_related_crime('Yes', WeaponType) :-
    (   WeaponType = 'gun' ->
        ipc_section(307, 'Attempt to Murder with a Firearm')
    ;   WeaponType = 'knife' ->
        ipc_section(307, 'Attempt to Murder with a Knife')
    ;   WeaponType = 'blunt' ->
        ipc_section(326, 'Voluntarily Causing Grievous Hurt')
    ;   ipc_section(324, 'Voluntarily Causing Hurt with Dangerous Weapons or Means')
    ),
    writeln('Weapon involved crime classified.').

classify_weapon_related_crime('No', _) :-
    writeln('No weapon involved in the crime.').

% Victim status classification
classify_victim_status('dead') :-
    ipc_section(302, 'Murder with Fatality'),
    writeln('Victim status classified: Murder.').

classify_victim_status('injured') :-
    ipc_section(324, 'Hurt with Injuries'),
    writeln('Victim status classified: Hurt.').

classify_victim_status(_) :-
    writeln('Victim status: No severe injury or death reported.').
