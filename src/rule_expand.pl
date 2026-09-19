:- module(rule_expand,
    [ expand_rule/2,
      expand_rule/3
    ]).

:- use_module(ontology).
:- use_module(rule_search, [find_rule_path/3]).

expand_rule(Rule, Tree) :-
    expand_rule(Rule, Tree, [max_depth(32)]).

expand_rule(Rule, Tree, Options) :-
    option_value(max_depth, Options, 32, MaxDepth),
    expand_rule_(Rule, Tree, [], 0, MaxDepth).

expand_rule_(Rule, node(recursive_ref(Rule), []), Visited, _Depth, _MaxDepth) :-
    memberchk(Rule, Visited),
    !.
expand_rule_(Rule, node(Rule, []), _Visited, _Depth, _MaxDepth) :-
    primitive(Rule),
    !.
expand_rule_(Rule, node(Rule, []), _Visited, Depth, MaxDepth) :-
    Depth >= MaxDepth,
    !.
expand_rule_(Rule, node(Rule, Children), Visited, Depth, MaxDepth) :-
    expansion(Rule, ChildRules, _),
    !,
    NextDepth is Depth + 1,
    expand_children(ChildRules, [Rule|Visited], NextDepth, MaxDepth, Children).
expand_rule_(Rule, node(Rule, Children), Visited, Depth, MaxDepth) :-
    rule(Rule, Start, End, _),
    find_rule_path(Start, End, Path),
    Path \= [Rule],
    !,
    NextDepth is Depth + 1,
    expand_children(Path, [Rule|Visited], NextDepth, MaxDepth, Children).
expand_rule_(Rule, node(Rule, []), _Visited, _Depth, _MaxDepth).

expand_children([], _Visited, _Depth, _MaxDepth, []).
expand_children([Rule|Rest], Visited, Depth, MaxDepth, [Tree|Trees]) :-
    expand_rule_(Rule, Tree, Visited, Depth, MaxDepth),
    expand_children(Rest, Visited, Depth, MaxDepth, Trees).

option_value(Key, Options, Default, Value) :-
    (   Option =.. [Key, Value],
        memberchk(Option, Options)
    ->  true
    ;   Value = Default
    ).
