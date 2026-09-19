:- begin_tests(proof).

:- use_module('../src/main').
:- use_module('../src/ontology').
:- use_module('../src/proof').

setup_proof :-
    load_dictionary([
        rule(ac, a, c),
        rule(cb, c, b)
    ]).

test(machine_readable_proof, [setup(setup_proof)]) :-
    prove_rule(a, b, Proof),
    Proof = proof(relation(a, b), compose(
        proof(relation(a, c), dictionary(ac)),
        proof(relation(c, b), dictionary(cb))
    )).

test(synthesise_rule_builds_formula_and_proof) :-
    synthesise_rule(text, code,
        [ rule(tokenise, text, tokens),
          rule(parse, tokens, tree),
          rule(analyse, tree, meaning),
          rule(generate, meaning, code)
        ],
        compose(tokenise, compose(parse, compose(analyse, generate))),
        proof(relation(text, code), _)).

test(explanation_mentions_requested_relation, [setup(setup_proof)]) :-
    explain_rule(relation(a, b), Explanation),
    sub_atom(Explanation, _, _, _, 'Requested a -> b').

:- end_tests(proof).
