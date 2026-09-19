:- module(rule_compose,
    [ compose_path/2,
      compose_steps/2,
      compose_paths/2
    ]).

:- use_module(rule_normaliser, [path_to_compose/2, compose_length/2]).

compose_path(Path, Formula) :-
    path_to_compose(Path, Formula).

compose_steps(Formula, Steps) :-
    compose_length(Formula, Steps).

compose_paths(Paths, choices(Choices)) :-
    maplist(wrap_path, Paths, Choices).

wrap_path(Path, path(Path)).
