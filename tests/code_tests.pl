:- begin_tests(code).

:- use_module('../src/ontology').
:- use_module('../src/code_analyser').
:- use_module('../src/rule_search').

setup_code :-
    load_dictionary([
        predicate_rule(parser, parse_tokens(tokens, syntax_tree), tokens, syntax_tree),
        predicate_rule(compiler, compile_tree(syntax_tree, machine_code), syntax_tree, machine_code)
    ]).

test(code_sentence_derivation, [setup(setup_code)]) :-
    find_rule(tokens, machine_code, compose(parser, compiler)).

test(predicate_chain_analysis) :-
    analyse_clause((translate(A, B) :- parse(A, C), optimise(C, D), generate(D, B)),
        node(translate, [node(parse, []), node(optimise, []), node(generate, [])]),
        data_flow(A, B, [step(parse, A, C), step(optimise, C, D), step(generate, D, B)])).

:- end_tests(code).
