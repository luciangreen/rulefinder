:- module(ontology,
    [ reset_ontology/0,
      load_dictionary/1,
      load_terms/1,
      load_file_terms/1,
      save_generalised_rules/1,
      add_rule/4,
      add_predicate_rule/5,
      add_expansion/3,
      add_primitive/1,
      add_connection/4,
      add_compose_relation/3,
      add_meta_rule/3,
      add_generalised_rule/1,
      rule/4,
      predicate_rule/5,
      expansion/3,
      primitive/1,
      connection/4,
      compose_relation/3,
      meta_rule/3,
      generalised_rule/1,
      outgoing_rule/4,
      incoming_rule/4,
      outgoing_predicate_rule/5,
      incoming_predicate_rule/5,
      outgoing_connection/4,
      incoming_connection/4
    ]).

:- dynamic rule_fact/4.
:- dynamic rule_fact_by_output/4.
:- dynamic predicate_rule_fact/5.
:- dynamic predicate_rule_fact_by_output/5.
:- dynamic expansion_fact/3.
:- dynamic primitive_fact/1.
:- dynamic connection_fact/4.
:- dynamic connection_fact_by_target/4.
:- dynamic compose_relation_fact/3.
:- dynamic meta_rule_fact/3.
:- dynamic generalised_rule_fact/1.

reset_ontology :-
    retractall(rule_fact(_, _, _, _)),
    retractall(rule_fact_by_output(_, _, _, _)),
    retractall(predicate_rule_fact(_, _, _, _, _)),
    retractall(predicate_rule_fact_by_output(_, _, _, _, _)),
    retractall(expansion_fact(_, _, _)),
    retractall(primitive_fact(_)),
    retractall(connection_fact(_, _, _, _)),
    retractall(connection_fact_by_target(_, _, _, _)),
    retractall(compose_relation_fact(_, _, _)),
    retractall(meta_rule_fact(_, _, _)),
    retractall(generalised_rule_fact(_)).

load_dictionary(Terms) :-
    reset_ontology,
    load_terms(Terms).

load_terms([]).
load_terms([Term|Rest]) :-
    load_term(Term),
    load_terms(Rest).

load_file_terms(File) :-
    setup_call_cleanup(
        open(File, read, Stream),
        read_terms(Stream),
        close(Stream)
    ).

read_terms(Stream) :-
    read_term(Stream, Term, []),
    (   Term == end_of_file
    ->  true
    ;   load_term(Term),
        read_terms(Stream)
    ).

save_generalised_rules(File) :-
    setup_call_cleanup(
        open(File, write, Stream),
        forall(generalised_rule(Pattern), portray_clause(Stream, generalised_rule(Pattern))),
        close(Stream)
    ).

load_term(rule(Name, In, Out)) :-
    !,
    add_rule(Name, In, Out, dictionary).
load_term(rule(Name, In, Out, _Properties)) :-
    !,
    add_rule(Name, In, Out, dictionary).
load_term(predicate_rule(Name, Predicate, In, Out)) :-
    !,
    add_predicate_rule(Name, Predicate, In, Out, code).
load_term(expands(Name, Children)) :-
    !,
    add_expansion(Name, Children, sentence).
load_term(expand(Parent, Children)) :-
    !,
    add_expansion(Parent, Children, sentence).
load_term(primitive(Name)) :-
    !,
    add_primitive(Name).
load_term(connection(Source, Relation, Target)) :-
    !,
    add_connection(Source, Relation, Target, dictionary).
load_term(compose_relation(Rel1, Rel2, Result)) :-
    !,
    add_compose_relation(Rel1, Rel2, Result).
load_term(meta_rule(Name, Premises, Conclusion)) :-
    !,
    add_meta_rule(Name, Premises, Conclusion).
load_term(generalised_rule(Pattern)) :-
    !,
    add_generalised_rule(Pattern).
load_term(interpretations(Interpretations)) :-
    !,
    maplist(load_term, Interpretations).
load_term(interpretation(Terms)) :-
    !,
    maplist(load_term, Terms).
load_term(query(_)) :-
    !.
load_term(Term) :-
    throw(error(domain_error(dictionary_term, Term), _)).

add_rule(Name, In, Out, Source) :-
    assertz(rule_fact(In, Out, Name, Source)),
    assertz(rule_fact_by_output(Out, In, Name, Source)).

add_predicate_rule(Name, Predicate, In, Out, Source) :-
    assertz(predicate_rule_fact(In, Out, Name, Predicate, Source)),
    assertz(predicate_rule_fact_by_output(Out, In, Name, Predicate, Source)).

add_expansion(Name, Children, Source) :-
    assertz(expansion_fact(Name, Children, Source)).

add_primitive(Name) :-
    assertz(primitive_fact(Name)).

add_connection(SourceNode, Relation, TargetNode, Source) :-
    assertz(connection_fact(SourceNode, Relation, TargetNode, Source)),
    assertz(connection_fact_by_target(TargetNode, Relation, SourceNode, Source)).

add_compose_relation(Rel1, Rel2, Result) :-
    assertz(compose_relation_fact(Rel1, Rel2, Result)).

add_meta_rule(Name, Premises, Conclusion) :-
    assertz(meta_rule_fact(Name, Premises, Conclusion)).

add_generalised_rule(Pattern) :-
    assertz(generalised_rule_fact(Pattern)).

rule(Name, In, Out, Source) :-
    rule_fact(In, Out, Name, Source).

predicate_rule(Name, Predicate, In, Out, Source) :-
    predicate_rule_fact(In, Out, Name, Predicate, Source).

expansion(Name, Children, Source) :-
    expansion_fact(Name, Children, Source).

primitive(Name) :-
    primitive_fact(Name).

connection(SourceNode, Relation, TargetNode, Source) :-
    connection_fact(SourceNode, Relation, TargetNode, Source).

compose_relation(Rel1, Rel2, Result) :-
    compose_relation_fact(Rel1, Rel2, Result).

meta_rule(Name, Premises, Conclusion) :-
    meta_rule_fact(Name, Premises, Conclusion).

generalised_rule(Pattern) :-
    generalised_rule_fact(Pattern).

outgoing_rule(In, Name, Out, Source) :-
    rule_fact(In, Out, Name, Source).

incoming_rule(Out, Name, In, Source) :-
    rule_fact_by_output(Out, In, Name, Source).

outgoing_predicate_rule(In, Name, Predicate, Out, Source) :-
    predicate_rule_fact(In, Out, Name, Predicate, Source).

incoming_predicate_rule(Out, Name, Predicate, In, Source) :-
    predicate_rule_fact_by_output(Out, In, Name, Predicate, Source).

outgoing_connection(SourceNode, Relation, TargetNode, Source) :-
    connection_fact(SourceNode, Relation, TargetNode, Source).

incoming_connection(TargetNode, Relation, SourceNode, Source) :-
    connection_fact_by_target(TargetNode, Relation, SourceNode, Source).
