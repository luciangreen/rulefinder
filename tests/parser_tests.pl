:- begin_tests(parser).

:- use_module('../src/sentence_parser').

test(expands_sentence) :-
    parse_sentence('AB expands to AC CB.',
        expand(relation(a, b), [relation(a, c), relation(c, b)])).

test(primitive_sentence) :-
    parse_sentence('AD is primitive.', primitive(ad)).

test(connects_through_sentence) :-
    parse_sentence('A connects to B through C.',
        expand(relation(a, b), [relation(a, c), relation(c, b)])).

test(reads_produces_sentence) :-
    parse_sentence('The parser reads tokens and produces a syntax tree.',
        rule(parser, tokens, syntax_tree)).

test(find_sentence) :-
    parse_sentence('Find how A implies B.', query(relation(a, b))).

test(uses_produces_sentence) :-
    parse_sentence('A uses C and C produces B.',
        interpretations([
            interpretation([
                connection(a, uses, c),
                connection(c, produces, b)
            ])
        ])).

:- end_tests(parser).
