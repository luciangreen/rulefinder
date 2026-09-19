:- module(main,
    [ synthesise_rule/5,
      load_sentences/1,
      parse_and_load/2
    ]).

:- use_module(sentence_parser).
:- use_module(ontology).
:- use_module(rule_search).
:- use_module(proof).

synthesise_rule(Input, Output, Dictionary, Formula, Proof) :-
    reset_ontology,
    load_terms(Dictionary),
    shortest_rule(Input, Output, Formula, _),
    prove_rule(Input, Output, Proof).

load_sentences(Sentences) :-
    parse_sentences(Sentences, Terms),
    load_terms(Terms).

parse_and_load(Sentences, Terms) :-
    parse_sentences(Sentences, Terms),
    load_terms(Terms).
