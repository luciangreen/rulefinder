:- module(code_analyser,
    [ analyse_clause/3,
      clause_to_expansion/2
    ]).

analyse_clause((Head :- Body), node(Name, Children), data_flow(Input, Output, Steps)) :-
    !,
    Head =.. [Name, Input, Output],
    body_goals(Body, Goals),
    goals_to_steps(Goals, Steps),
    maplist(goal_node, Goals, Children).
analyse_clause(Fact, node(Name, []), data_flow(Input, Output, [])) :-
    Fact =.. [Name, Input, Output].

clause_to_expansion((Head :- Body), expands(Name, Children)) :-
    Head =.. [Name, _, _],
    body_goals(Body, Goals),
    maplist(goal_name, Goals, Children).

body_goals((Left, Right), Goals) :-
    !,
    body_goals(Left, LeftGoals),
    body_goals(Right, RightGoals),
    append(LeftGoals, RightGoals, Goals).
body_goals(Goal, [Goal]).

goals_to_steps([], []).
goals_to_steps([Goal|Rest], [step(Name, In, Out)|Steps]) :-
    Goal =.. [Name, In, Out|_],
    goals_to_steps(Rest, Steps).

goal_node(Goal, node(Name, [])) :-
    goal_name(Goal, Name).

goal_name(Goal, Name) :-
    Goal =.. [Name|_].
