:- begin_tests(expansion).

:- use_module('../src/ontology').
:- use_module('../src/rule_expand').
:- use_module('../src/rule_search').

setup_expansion :-
    load_dictionary([
        rule(ab, a, b),
        rule(ac, a, c),
        rule(ad, a, d),
        rule(dc, d, c),
        rule(cb, c, b),
        rule(ce, c, e),
        rule(eb, e, b),
        expand(ab, [ac, cb]),
        expand(ac, [ad, dc]),
        expand(cb, [ce, eb]),
        primitive(ad),
        primitive(dc),
        primitive(ce),
        primitive(eb)
    ]).

setup_cycle :-
    load_dictionary([
        rule(ab, a, b),
        rule(ba, b, a),
        expand(ab, [ba]),
        expand(ba, [ab])
    ]).

test(recursive_expansion, [setup(setup_expansion)]) :-
    expand_rule(ab, Tree),
    Tree = node(ab, [
        node(ac, [node(ad, []), node(dc, [])]),
        node(cb, [node(ce, []), node(eb, [])])
    ]).

test(find_rule_tree_uses_parent_rule, [setup(setup_expansion)]) :-
    find_rule_tree(a, b, node(ab, _)).

test(cycle_detection, [setup(setup_cycle)]) :-
    expand_rule(ab, node(ab, [node(ba, [node(recursive_ref(ab), [])])])).

:- end_tests(expansion).
