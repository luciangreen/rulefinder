:- initialization(main).

main :-
    source_file(main, SourceFile),
    file_directory_name(SourceFile, Dir),
    maplist(load_test_file(Dir),
        ['parser_tests.pl',
         'ontology_tests.pl',
         'search_tests.pl',
         'expansion_tests.pl',
         'code_tests.pl',
         'proof_tests.pl']),
    run_tests,
    halt.

load_test_file(Dir, File) :-
    directory_file_path(Dir, File, Path),
    consult(Path).
