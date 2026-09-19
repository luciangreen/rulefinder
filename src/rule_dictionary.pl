:- module(rule_dictionary,
    [ load_rule_dictionary/1,
      add_rule_entry/3,
      add_predicate_entry/4
    ]).

:- use_module(ontology).

load_rule_dictionary(Dictionary) :-
    load_terms(Dictionary).

add_rule_entry(Name, Input, Output) :-
    add_rule(Name, Input, Output, dictionary).

add_predicate_entry(Name, Predicate, Input, Output) :-
    add_predicate_rule(Name, Predicate, Input, Output, code).
