:- begin_tests(ontology).

:- use_module('../src/ontology').
:- use_module('../src/rule_generalise').

setup_ontology :-
    load_dictionary([
        rule(ab, a, b),
        rule(ac, a, c),
        rule(cb, c, b),
        expand(ab, [ac, cb]),
        expand(de, [df, fe])
    ]).

test(indexed_rule_lookup, [setup(setup_ontology)]) :-
    outgoing_rule(a, ac, c, dictionary),
    incoming_rule(b, cb, c, dictionary).

test(pattern_discovery, [setup(setup_ontology)]) :-
    discover_patterns(Patterns),
    once(member(expand(relation(x, y), [relation(x, z), relation(z, y)])-_, Patterns)).

:- end_tests(ontology).
