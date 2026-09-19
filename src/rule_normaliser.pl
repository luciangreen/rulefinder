:- module(rule_normaliser,
    [ normalise_symbol/2,
      normalise_phrase/2,
      relation_term/2,
      relation_name/3,
      flatten_compose/2,
      path_to_compose/2,
      compose_length/2,
      tree_to_paths/2
    ]).

normalise_symbol(Value, Normalised) :-
    (   string(Value)
    ->  atom_string(Atom, Value)
    ;   Atom = Value
    ),
    downcase_atom(Atom, Lower),
    atom_chars(Lower, Chars),
    exclude(is_noise_char, Chars, CleanChars),
    atom_chars(CleanAtom, CleanChars),
    atomic_list_concat(Parts, ' ', CleanAtom),
    exclude(=(''), Parts, NonEmptyParts),
    atomic_list_concat(NonEmptyParts, '_', JoinedAtom),
    (   JoinedAtom = ''
    ->  Normalised = empty
    ;   Normalised = JoinedAtom
    ).

normalise_phrase(Value, Normalised) :-
    normalise_symbol(Value, Raw),
    (   Raw = the_rest
    ->  Normalised = rest
    ;   strip_article(Raw, Normalised)
    ).

strip_article(Value, Stripped) :-
    atomic_list_concat(Parts, '_', Value),
    (   Parts = [the|Rest], Rest \= []
    ->  atomic_list_concat(Rest, '_', Stripped)
    ;   Parts = [a|Rest], Rest \= []
    ->  atomic_list_concat(Rest, '_', Stripped)
    ;   Parts = [an|Rest], Rest \= []
    ->  atomic_list_concat(Rest, '_', Stripped)
    ;   Stripped = Value
    ).

is_noise_char(Char) :-
    memberchk(Char, ['.', ',', ';', ':', '!', '?', '\'', '"', '(', ')']).

relation_name(A, B, Name) :-
    normalise_symbol(A, NA),
    normalise_symbol(B, NB),
    atom_concat(NA, NB, Name).

relation_term(relation(A, B), relation(A, B)) :- !.
relation_term(Name, relation(A, B)) :-
    atom(Name),
    atom_chars(Name, [CA, CB]),
    atom_chars(A, [CA]),
    atom_chars(B, [CB]),
    !.
relation_term(Name, relation(A, B)) :-
    string(Name),
    atom_string(Atom, Name),
    relation_term(Atom, relation(A, B)).

flatten_compose(compose(Left, Right), Flat) :-
    !,
    flatten_compose(Left, LeftFlat),
    flatten_compose(Right, RightFlat),
    append(LeftFlat, RightFlat, Flat).
flatten_compose(Formula, [Formula]).

path_to_compose([Single], Single) :- !.
path_to_compose([First|Rest], compose(First, Tail)) :-
    path_to_compose(Rest, Tail).

compose_length(Formula, Length) :-
    flatten_compose(Formula, Parts),
    length(Parts, Length).

tree_to_paths(node(Rule, []), [[Rule]]) :- !.
tree_to_paths(node(_, Children), Paths) :-
    maplist(tree_to_paths, Children, Nested),
    append(Nested, Paths).
