Autori:
Kristian Kovacev 885839
Marco Fagnani 879215

I principali predicati utilizzati sono:
- jsonparse/2 : la stringa JSONString viene convertita in una lista di 				caratteri per semplificare il parsing. Il predicato is_json si occuperà di distinguere se la si tratta di un is_object/2 oppure di un is_array/2.

- jsonaccess/3 : accede al jsonobj o jsonarray ed estrae l'elemento.
Esempio: 
?- jsonparse('{"a":{"b":{"c":[["d", {"e":["f"]}]]}}}', O), 
jsonaccess(O, ["a", "b", "c", 0, 1, "e", 0], R).
R = "f"

- jsonread/2 : questo predicato legge dal file e lo converte in stringa, la stringa viene passata a jsonparse/2 per controllare se il json è scritto nel modo corretto.

- jsondump/2 : questo predicato scrive sul file. Per riscostruire il json a partire da un jsonobj o un jsonarray viene utilizzato il predicato jsonbuild/2.
