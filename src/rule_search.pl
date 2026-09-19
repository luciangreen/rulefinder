:- module(rule_search,
    [ find_rule/3,
      find_rule_path/3,
      find_all_rule_paths/3,
      find_rule_tree/3,
      shortest_rule/4,
      find_connection/4,
      find_connection_path/4
    ]).

:- use_module(library(lists)).
:- use_module(library(pairs)).
:- use_module(ontology).
:- use_module(rule_compose).

find_rule(Start, End, Formula) :-
    shortest_rule(Start, End, Formula, _).

find_rule_path(Start, End, Path) :-
    shortest_path(Start, End, Path, _Kind).

find_all_rule_paths(Start, End, Paths) :-
    findall(Path, path_candidate(Start, End, Path, _), RawPaths),
    sort_paths(RawPaths, Paths).

shortest_rule(Start, End, Formula, Steps) :-
    shortest_path(Start, End, Path, _),
    compose_path(Path, Formula),
    length(Path, Steps).

find_rule_tree(Start, End, Tree) :-
    (   ontology:rule(Name, Start, End, _),
        nontrivial_path_excluding_rule(Start, End, Name, Path),
        Path \= []
    ->  maplist(rule_expand:expand_rule, Path, Children),
        Tree = node(Name, Children)
    ;   ontology:rule(Name, Start, End, _)
    ->  rule_expand:expand_rule(Name, Tree)
    ;   shortest_path(Start, End, Path, _),
        maplist(rule_expand:expand_rule, Path, Children),
        Tree = node(derived(Start, End), Children)
    ).

find_connection(Start, Relation, End, Proof) :-
    typed_connection_proof(Start, Relation, End, [Start], Proof).

find_connection_path(Start, Relation, End, Path) :-
    typed_connection_path(Start, Relation, End, [Start], Path).

shortest_path(Start, End, Path, Kind) :-
    findall(Len-Kind0-Path0, path_with_kind(Start, End, Path0, Kind0, Len), Pairs),
    sort(Pairs, [Len-Kind-Path|_]).

path_with_kind(Start, End, Path, dictionary, Len) :-
    path_candidate(Start, End, Path, dictionary),
    length(Path, Len).
path_with_kind(Start, End, Path, code, Len) :-
    path_candidate(Start, End, Path, code),
    length(Path, Len).

path_candidate(Start, End, Path, Kind) :-
    route(Start, End, [Start], Path, Kind).

route(Start, End, _Visited, [Rule], dictionary) :-
    ontology:outgoing_rule(Start, Rule, End, _).
route(Start, End, _Visited, [Rule], code) :-
    ontology:outgoing_predicate_rule(Start, Rule, _Predicate, End, _).
route(Start, End, Visited, [Rule|Rest], Kind) :-
    next_step(Start, Rule, Mid, Kind),
    Mid \= End,
    \+ memberchk(Mid, Visited),
    route(Mid, End, [Mid|Visited], Rest, Kind).

next_step(Start, Rule, End, dictionary) :-
    ontology:outgoing_rule(Start, Rule, End, _).
next_step(Start, Rule, End, code) :-
    ontology:outgoing_predicate_rule(Start, Rule, _Predicate, End, _).

sort_paths(RawPaths, Paths) :-
    map_list_to_pairs(length, RawPaths, Pairs),
    keysort(Pairs, Sorted),
    pairs_values(Sorted, Paths).

nontrivial_path_excluding_rule(Start, End, Rule, Path) :-
    findall(Candidate, (path_candidate(Start, End, Candidate, _), Candidate \= [Rule]), Candidates),
    sort_paths(Candidates, [Path|_]).

typed_connection_path(Start, Relation, End, _Visited, [connection(Start, Relation, End)]) :-
    ontology:connection(Start, Relation, End, _).
typed_connection_path(Start, Relation, End, Visited, [connection(Start, LeftRelation, Mid)|Rest]) :-
    ontology:connection(Start, LeftRelation, Mid, _),
    \+ memberchk(Mid, Visited),
    typed_connection_path(Mid, RightRelation, End, [Mid|Visited], Rest),
    composable_relation(LeftRelation, RightRelation, Relation).

typed_connection_proof(Start, Relation, End, _Visited,
        proof(connection(Start, Relation, End), dictionary(connection(Start, Relation, End)))) :-
    ontology:connection(Start, Relation, End, _),
    !.
typed_connection_proof(Start, Relation, End, Visited,
        proof(connection(Start, Relation, End), compose(LeftProof, RightProof))) :-
    ontology:connection(Start, LeftRelation, Mid, _),
    \+ memberchk(Mid, Visited),
    typed_connection_proof(Mid, RightRelation, End, [Mid|Visited], RightProof),
    composable_relation(LeftRelation, RightRelation, Relation),
    LeftProof = proof(connection(Start, LeftRelation, Mid), dictionary(connection(Start, LeftRelation, Mid))).

composable_relation(Relation, Relation, Relation) :-
    meta_transitive(Relation),
    !.
composable_relation(Left, Right, Result) :-
    ontology:compose_relation(Left, Right, Result).

meta_transitive(Relation) :-
    ontology:meta_rule(transitive(Relation),
        [relation(_, Relation, _), relation(_, Relation, _)],
        relation(_, Relation, _)).
