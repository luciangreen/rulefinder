:- module(rule_generalise,
    [ discover_patterns/1,
      promote_patterns/0
    ]).

:- use_module(library(lists)).
:- use_module(ontology).
:- use_module(rule_normaliser).

discover_patterns(Patterns) :-
    findall(Pattern-Support,
        ( expansion(Parent, [Left, Right], _),
          xy_zy_pattern(Parent, Left, Right, Pattern),
          findall(example(Parent, Left, Right), expansion(Parent, [Left, Right], _), Support)
        ),
        Raw),
    sort(Raw, Patterns).

promote_patterns :-
    discover_patterns(Patterns),
    forall(member(Pattern-Support, Patterns),
        ( length(Support, Count),
          Count >= 1,
          add_generalised_rule(Pattern)
        )).

xy_zy_pattern(Parent, Left, Right,
        expand(relation(x, y), [relation(x, z), relation(z, y)])) :-
    relation_term(Parent, relation(A, B)),
    relation_term(Left, relation(A, C)),
    relation_term(Right, relation(C, B)).
