# rulefinder

Rule Connection and Sentence Hierarchy Finder.

## What this project does

`rulefinder` loads rules, expansions, and typed connections, then finds and explains how one concept can be derived from another.

It supports:
- plain rules (`rule/3`)
- predicate-backed rules (`predicate_rule/4`)
- expansion trees (`expand/2`)
- typed graph relations (`connection/3`)
- sentence parsing into dictionary terms
- proof/explanation generation

## Complete command showcase

All commands below are copy/paste ready and include the expected behavior.

### 1) Run the full test suite

```bash
cd /home/runner/work/rulefinder/rulefinder
swipl -q -f tests/run_tests.pl
```

**What it does:** runs parser, ontology, search, expansion, code, and proof tests.

### 2) Start an interactive Prolog session

```bash
cd /home/runner/work/rulefinder/rulefinder
swipl -q
```

Then load the core modules:

```prolog
?- [src/main, src/ontology, src/rule_search, src/rule_expand, src/proof, src/sentence_parser, src/code_analyser].
```

**What it does:** loads all major predicates used in the examples below.

---

## Command reference with explanations

### A) Sentence-to-term parsing commands

```prolog
?- parse_sentence('AB expands to AC CB.', Term).
Term = expand(relation(a, b), [relation(a, c), relation(c, b)]).
```

**Meaning:** turns an expansion sentence into a structured expansion term.

```prolog
?- parse_sentence('AD is primitive.', Term).
Term = primitive(ad).
```

**Meaning:** marks a rule as primitive (leaf-level in expansion trees).

```prolog
?- parse_sentence('A connects to B through C.', Term).
Term = expand(relation(a, b), [relation(a, c), relation(c, b)]).
```

**Meaning:** alternate natural-language form for expansion.

```prolog
?- parse_sentence('The parser reads tokens and produces a syntax tree.', Term).
Term = rule(parser, tokens, syntax_tree).
```

**Meaning:** extracts a rule from a “reads … produces …” sentence.

### B) Load and index dictionary terms

```prolog
?- reset_ontology,
   load_dictionary([
       rule(ac, a, c),
       rule(cb, c, b),
       rule(ad, a, d),
       rule(db, d, b),
       expand(ab, [ac, cb]),
       primitive(ac),
       primitive(cb),
       connection(cat, isa, mammal),
       connection(mammal, isa, animal),
       compose_relation(isa, isa, isa)
   ]).
true.
```

**Meaning:** resets memory and loads rules, expansions, primitives, and typed relations in one step.

```prolog
?- outgoing_rule(a, Name, End, Source).
Name = ac,
End = c,
Source = dictionary ;
Name = ad,
End = d,
Source = dictionary.
```

**Meaning:** queries the indexed outgoing rules from a start symbol.

### C) Rule search commands

```prolog
?- shortest_rule(a, b, Formula, Steps).
Formula = compose(ac, cb),
Steps = 2.
```

**Meaning:** finds the shortest derivation and reports its step count.

```prolog
?- find_rule(a, b, Formula).
Formula = compose(ac, cb).
```

**Meaning:** convenience query that returns the shortest composed formula.

```prolog
?- find_all_rule_paths(a, b, Paths).
Paths = [[ac, cb], [ad, db]].
```

**Meaning:** returns all discovered paths (sorted/sanitized by the library).

```prolog
?- find_rule_tree(a, b, Tree).
Tree = node(derived(a, b), [node(ac, []), node(cb, [])]).
```

**Meaning:** builds an explanation tree for the requested relation.

### D) Expansion commands

```prolog
?- expand_rule(ab, Tree).
Tree = node(ab, [node(ac, []), node(cb, [])]).
```

**Meaning:** expands a rule to its decomposition tree.

```prolog
?- expand_rule(ab, Tree, [max_depth(1)]).
Tree = node(ab, [node(ac, []), node(cb, [])]).
```

**Meaning:** same expansion with configurable recursion depth limits.

### E) Proof and explanation commands

```prolog
?- prove_rule(a, b, Proof).
Proof = proof(relation(a, b), compose(
           proof(relation(a, c), dictionary(ac)),
           proof(relation(c, b), dictionary(cb))
       )).
```

**Meaning:** returns a machine-readable proof object for the derived relation.

```prolog
?- explain_rule(relation(a, b), Explanation).
Explanation = 'Requested a -> b ...'.
```

**Meaning:** returns a human-readable explanation text.

### F) End-to-end synthesis command

```prolog
?- synthesise_rule(text, code,
       [ rule(tokenise, text, tokens),
         rule(parse, tokens, tree),
         rule(analyse, tree, meaning),
         rule(generate, meaning, code)
       ],
       Formula,
       Proof).
Formula = compose(tokenise, compose(parse, compose(analyse, generate))),
Proof = proof(relation(text, code), _).
```

**Meaning:** complete pipeline from dictionary input to composed rule + proof.

### G) Clause/code analysis command

```prolog
?- analyse_clause(
       (translate(A, B) :- parse(A, C), optimise(C, D), generate(D, B)),
       Tree,
       Flow
   ).
Tree = node(translate, [node(parse, []), node(optimise, []), node(generate, [])]),
Flow = data_flow(A, B, [step(parse, A, C), step(optimise, C, D), step(generate, D, B)]).
```

**Meaning:** converts a clause into structure + data-flow steps for reasoning.
