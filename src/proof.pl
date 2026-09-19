:- module(proof,
    [ prove_rule/3,
      explain_rule/2
    ]).

:- use_module(ontology).
:- use_module(rule_search, [find_rule_path/3]).

prove_rule(Start, End, Proof) :-
    find_rule_path(Start, End, Path),
    proof_for_path(Start, End, Path, Proof).

proof_for_path(Start, End, [Rule], proof(relation(Start, End), ProofTerm)) :-
    !,
    (   ontology:rule(Rule, Start, End, dictionary)
    ->  ProofTerm = dictionary(Rule)
    ;   ontology:rule(Rule, Start, End, sentence)
    ->  ProofTerm = source(sentence, Rule)
    ;   ontology:rule(Rule, Start, End, Source)
    ->  ProofTerm = source(Source, Rule)
    ;   ontology:predicate_rule(Rule, Predicate, Start, End, Source)
    ->  ProofTerm = source(Source, predicate_rule(Rule, Predicate))
    ).
proof_for_path(Start, End, [Rule|Rest], proof(relation(Start, End), compose(LeftProof, RightProof))) :-
    next_endpoint(Start, Rule, Mid),
    proof_for_path(Start, Mid, [Rule], LeftProof),
    proof_for_path(Mid, End, Rest, RightProof).

next_endpoint(Start, Rule, End) :-
    ontology:rule(Rule, Start, End, _),
    !.
next_endpoint(Start, Rule, End) :-
    ontology:predicate_rule(Rule, _Predicate, Start, End, _).

explain_rule(relation(Start, End), Explanation) :-
    prove_rule(Start, End, Proof),
    with_output_to(atom(Explanation), write_explanation(Proof)).
explain_rule(Rule, Explanation) :-
    with_output_to(atom(Explanation), format('Rule ~w is available.~n', [Rule])).

write_explanation(proof(relation(Start, End), dictionary(Rule))) :-
    format('Requested ~w -> ~w using dictionary rule ~w.', [Start, End, Rule]).
write_explanation(proof(relation(Start, End), source(Source, Rule))) :-
    format('Requested ~w -> ~w using ~w rule ~w.', [Start, End, Source, Rule]).
write_explanation(proof(relation(Start, End), compose(LeftProof, RightProof))) :-
    format('Requested ~w -> ~w because ', [Start, End]),
    write_subproof(LeftProof),
    format(' and ', []),
    write_subproof(RightProof),
    format('.', []).

write_subproof(proof(relation(Start, End), dictionary(Rule))) :-
    format('~w -> ~w via ~w', [Start, End, Rule]).
write_subproof(proof(relation(Start, End), source(Source, Rule))) :-
    format('~w -> ~w via ~w (~w)', [Start, End, Rule, Source]).
write_subproof(proof(relation(Start, End), compose(Left, Right))) :-
    format('(', []),
    write_explanation(proof(relation(Start, End), compose(Left, Right))),
    format(')', []).
