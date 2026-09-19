:- module(sentence_parser,
    [ parse_sentence/2,
      parse_sentences/2
    ]).

:- use_module(rule_normaliser).

parse_sentences([], []).
parse_sentences([Sentence|Rest], [Term|Terms]) :-
    parse_sentence(Sentence, Term),
    parse_sentences(Rest, Terms).

parse_sentence(Sentence, Term) :-
    sentence_text(Sentence, Text),
    parse_expand(Text, Term), !.
parse_sentence(Sentence, Term) :-
    sentence_text(Sentence, Text),
    parse_primitive(Text, Term), !.
parse_sentence(Sentence, Term) :-
    sentence_text(Sentence, Text),
    parse_through(Text, Term), !.
parse_sentence(Sentence, Term) :-
    sentence_text(Sentence, Text),
    parse_find(Text, Term), !.
parse_sentence(Sentence, Term) :-
    sentence_text(Sentence, Text),
    parse_reads_produces(Text, Term), !.
parse_sentence(Sentence, interpretations([Term])) :-
    sentence_text(Sentence, Text),
    parse_uses_produces(Text, Term), !.

sentence_text(Sentence, Text) :-
    (   string(Sentence)
    ->  Text = Sentence
    ;   atom_string(Sentence, Text)
    ).

clean_sentence(Text, Clean) :-
    normalize_space(string(Spaced), Text),
    string_lower(Spaced, Lower),
    split_string(Lower, ".!?", " ", Parts),
    nth0(0, Parts, First),
    normalize_space(string(Clean), First).

parse_expand(Text, expand(Parent, [Left, Right])) :-
    clean_sentence(Text, Clean),
    split_string(Clean, " ", "", [ParentText, "expands", "to", LeftText, RightText]),
    parse_relation_token(ParentText, Parent),
    parse_relation_token(LeftText, Left),
    parse_relation_token(RightText, Right).

parse_primitive(Text, primitive(Name)) :-
    clean_sentence(Text, Clean),
    split_string(Clean, " ", "", [NameText, "is", "primitive"]),
    parse_rule_name(NameText, Name).

parse_through(Text, expand(relation(A, B), [relation(A, C), relation(C, B)])) :-
    clean_sentence(Text, Clean),
    split_string(Clean, " ", "", [A0, "connects", "to", B0, "through", C0]),
    normalise_symbol(A0, A),
    normalise_symbol(B0, B),
    normalise_symbol(C0, C).

parse_find(Text, query(relation(A, B))) :-
    clean_sentence(Text, Clean),
    split_string(Clean, " ", "", ["find", "how", A0, "implies", B0]),
    normalise_symbol(A0, A),
    normalise_symbol(B0, B).

parse_reads_produces(Text, rule(Name, Input, Output)) :-
    clean_sentence(Text, Clean),
    split_once(Clean, " reads ", SubjectPart, Rest),
    split_once(Rest, " and produces ", InputPart, OutputPart),
    normalise_phrase(SubjectPart, Name),
    normalise_phrase(InputPart, Input),
    normalise_phrase(OutputPart, Output).

parse_uses_produces(Text,
        interpretation([
            connection(A, uses, C),
            connection(C, produces, B)
        ])) :-
    clean_sentence(Text, Clean),
    split_once(Clean, " uses ", Left, Rest),
    split_once(Rest, " and ", C0, Tail),
    split_once(Tail, " produces ", C1, B0),
    normalise_symbol(Left, A),
    normalise_symbol(C0, C),
    normalise_symbol(C1, C),
    normalise_symbol(B0, B).

parse_relation_token(Text, Relation) :-
    parse_rule_name(Text, Name),
    (   relation_term(Name, Relation)
    ->  true
    ;   Relation = Name
    ).

parse_rule_name(Text, Name) :-
    normalise_symbol(Text, Name).

split_once(Text, Separator, Left, Right) :-
    sub_string(Text, Before, SepLen, After, Separator),
    sub_string(Text, 0, Before, _, Left),
    Start is Before + SepLen,
    sub_string(Text, Start, After, 0, Right).
