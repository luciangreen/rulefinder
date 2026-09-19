:- module(connection_index,
    [ outgoing_rule/4,
      incoming_rule/4,
      outgoing_predicate_rule/5,
      incoming_predicate_rule/5,
      outgoing_connection/4,
      incoming_connection/4,
      candidate_intermediate/5
    ]).

:- use_module(ontology, []).

outgoing_rule(Start, Name, End, Source) :- ontology:outgoing_rule(Start, Name, End, Source).
incoming_rule(End, Name, Start, Source) :- ontology:incoming_rule(End, Name, Start, Source).
outgoing_predicate_rule(Start, Name, Predicate, End, Source) :- ontology:outgoing_predicate_rule(Start, Name, Predicate, End, Source).
incoming_predicate_rule(End, Name, Predicate, Start, Source) :- ontology:incoming_predicate_rule(End, Name, Predicate, Start, Source).
outgoing_connection(Start, Relation, End, Source) :- ontology:outgoing_connection(Start, Relation, End, Source).
incoming_connection(End, Relation, Start, Source) :- ontology:incoming_connection(End, Relation, Start, Source).

candidate_intermediate(Start, End, Intermediate, LeftRule, RightRule) :-
    outgoing_rule(Start, LeftRule, Intermediate, _),
    incoming_rule(End, RightRule, Intermediate, _).
