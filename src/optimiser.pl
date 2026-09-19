:- module(optimiser,
    [ prefer_simpler_paths/2
    ]).

:- use_module(library(pairs)).

prefer_simpler_paths(Paths, Sorted) :-
    map_list_to_pairs(length, Paths, Pairs),
    keysort(Pairs, Ordered),
    pairs_values(Ordered, Sorted).
