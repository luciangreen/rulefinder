:- use_module('../src/ontology').

code_dictionary([
    predicate_rule(parse, parse_tokens(tokens, syntax_tree), tokens, syntax_tree),
    predicate_rule(compile, compile_tree(syntax_tree, machine_code), syntax_tree, machine_code)
]).
