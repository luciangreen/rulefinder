:- use_module('../src/ontology').

ontology_example([
    connection(cat, isa, mammal),
    connection(mammal, isa, animal),
    compose_relation(isa, isa, isa)
]).
