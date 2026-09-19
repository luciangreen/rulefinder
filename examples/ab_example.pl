:- use_module('../src/ontology').

example_dictionary([
    rule(ab, a, b),
    rule(ac, a, c),
    rule(cb, c, b),
    expand(ab, [ac, cb]),
    primitive(ac),
    primitive(cb)
]).
