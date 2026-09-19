:- begin_tests(search).

:- use_module('../src/ontology').
:- use_module('../src/rule_search').
:- use_module('../src/rule_compose').

setup_search :-
    load_dictionary([
        rule(ac, a, c),
        rule(cb, c, b),
        rule(ad, a, d),
        rule(db, d, b),
        rule(de, d, e),
        rule(eb, e, b),
        rule(ca, c, a),
        connection(cat, isa, mammal),
        connection(mammal, isa, animal),
        compose_relation(isa, isa, isa),
        meta_rule(transitive(part_of), [relation(_, part_of, _), relation(_, part_of, _)], relation(_, part_of, _)),
        connection(wheel, part_of, car),
        connection(car, part_of, vehicle)
    ]).

test(shortest_rule_prefers_fewer_steps, [setup(setup_search)]) :-
    shortest_rule(a, b, Formula, Steps),
    Formula = compose(ac, cb),
    Steps = 2.

test(all_paths_are_retained, [setup(setup_search)]) :-
    find_all_rule_paths(a, b, Paths),
    once(member([ac, cb], Paths)),
    once(member([ad, db], Paths)),
    once(member([ad, de, eb], Paths)).

test(typed_relation_composition, [setup(setup_search)]) :-
    find_connection(cat, isa, animal, proof(connection(cat, isa, animal), _)).

test(meta_rule_transitivity, [setup(setup_search)]) :-
    find_connection(wheel, part_of, vehicle, proof(connection(wheel, part_of, vehicle), _)).

:- end_tests(search).
