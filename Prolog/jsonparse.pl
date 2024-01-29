%%%% Kristian Kovacev 885839
%%%% Marco Fagnani 879215

%%%% -*- Mode: Prolog -*-
%%%% jsonparse.pl

%%% jsonparse/2
%%% jsonparse(JSONString, Object).
%%% which is true if JSON String (a SWI Prolog string or a Prolog atom)
%%% can come broken down as a string, number, or in compound terms:
jsonparse(JSONString, Object) :-
    atom_chars(JSONString, Chars),
    phrase(is_json(Object), Chars).


is_json(Object) --> is_object(Object).
is_json(Array) --> is_array(Array).

%%% Object = jsonobj(Members)
is_object(jsonobj([])) -->
    is_open_curly_brace,
    is_whitespace,
    is_close_curly_brace,
    is_whitespace.

is_object(jsonobj(Members)) -->
    is_open_curly_brace,
    are_members(Members),
    is_close_curly_brace,
    is_whitespace.

%%% Object = jsonarray(Elements)
is_array(jsonarray([])) -->
    is_open_square_bracket,
    is_whitespace,
    is_close_square_bracket,
    is_whitespace.

is_array(jsonarray(Elements)) -->
    is_open_square_bracket,
    is_whitespace,
    are_elements(Elements),
    is_whitespace,
    is_close_square_bracket,
    is_whitespace.


%%% Members = [Pair] or
%%% Members = [Pair | Members]
are_members([Pair | Members]) -->
    is_pair(Pair),
    is_whitespace,
    is_comma,
    is_whitespace,
    are_members(Members).

are_members([Pair]) --> is_pair(Pair).

%%% Pair = (Key, Value)
%%% Key = <string SWI Prolog>
is_pair((Key, Value)) -->
    is_whitespace,
    is_string(Key),
    is_whitespace,
    is_colon,
    is_whitespace,
    is_value(Value),
    is_whitespace.

%%% Elements = [Element] or
%%% Elements = [Element | Elements]
are_elements([Element | Elements]) -->
    is_element(Element),
    is_whitespace,
    is_comma,
    !,
    is_whitespace,
    are_elements(Elements).

are_elements([Element]) --> is_element(Element).

%%% Element = Value
is_element(Value) -->
    is_whitespace,
    is_value(Value),
    is_whitespace.


%%% Value = <string SWI Prolog> | Number | Object |
%%% Array | Boolean | Null
is_value(String) --> is_string(String).
is_value(Number) --> is_num(Number).
is_value(Object) --> is_object(Object).
is_value(Array) --> is_array(Array).
is_value(Boolean) --> is_boolean(Boolean).
is_value(Null) --> is_null(Null).


% Number can be integer fraction exponent
is_num(Number) -->
    is_integer(Int),
    is_fraction(Frac),
    is_exponent(Exp),
    {append(Int, Frac, L)},
    {append(L, Exp, Final)},
    {number_chars(Number, Final)}.


is_integer([Sign | Digits]) -->
    is_sign(Sign),
    is_digits(Digits).

is_digits([Digit]) --> is_digit(Digit).

is_digits([Digit | Digits]) -->
    is_digit(Digit),
    is_digits(Digits).

is_digit(Digit) --> [Digit], {code_type(Digit, digit)}.

%%% The fraction in the number is optional
is_fraction([]) --> [].
is_fraction([Dot | Digits]) -->
    is_dot(Dot),
    !,
    is_digits(Digits).


%%% The exponent in the number is optional
is_exponent([]) --> [].
is_exponent(['E' | Integer]) -->
    ['E'],
    !,
    is_integer(Integer).

is_exponent(['e' | Integer]) -->
    ['e'],
    !,
    is_integer(Integer).

%% String = '"' characters '"'
is_string("") -->
    is_double_quote,
    is_double_quote.

is_string(String) -->
    is_double_quote,
    is_chars(Chars),
    is_double_quote,
    {string_chars(String, Chars)}.

is_chars([Char]) --> is_char(Char).
is_chars([Char | Chars]) --> is_char(Char), is_chars(Chars).

is_char(Char) --> is_escape(Char).

is_char(Char) -->
    [Char],
    {atom(Char)}.
    %{is_valid_char(Char)}.


is_boolean(Boolean) --> is_true(Boolean).
is_boolean(Boolean) --> is_false(Boolean).

is_true('true') --> ['t', 'r', 'u', 'e'].
is_false('false') --> ['f', 'a', 'l', 's', 'e'].

is_null('null') --> ['n', 'u', 'l', 'l'].


% Special characters

% Whitespace = '\t' | '\n' | '\f' | '\r' | ' ' 
is_whitespace --> [].
is_whitespace --> [Ws], {char_type(Ws, space)}.


is_open_curly_brace --> ['{'].
is_close_curly_brace --> ['}'].

is_open_square_bracket --> ['['].
is_close_square_bracket --> [']'].

is_colon --> [':'].
	      
is_comma --> [','].

is_double_quote --> ['"'].

is_dot(.) --> ['.'].

is_sign(' ') --> [].
is_sign(+) --> ['+'].
is_sign(-) --> ['-'].

% Escape
is_escape('"') --> ['\"'].
is_escape(' ') --> ['\\'].
is_escape(' ') --> ['\n'].
is_escape(' ') --> ['\t'].
is_escape(' ') --> ['\b'].
is_escape(' ') --> ['\f'].
is_escape(' ') --> ['\r'].
%is_escape --> ['/'].


%%% jsonaccess/3
%%% jsonaccess(Jsonobj, Fields, Result)

%%% which is true when Result is retrievable following the chain of fields
%%% present in Fields (a list) from Jsonobj.
%%% A field represented by N (with N a number greater than o
%%% equal to 0) corresponds to an index of a JSON array.

%%% jsonaccess of a jsonobj
jsonaccess(Value, [], Value).

%%% jsonaccess when i have only one field and the index
jsonaccess(jsonobj([(Field, Value) | _]), [Field | I], Result) :-
    jsonaccess(Value, I, Result).

%%% jsonaccess when i have only one field
jsonaccess(jsonobj([(Field, Value) | _]), [Field], Result) :-
    jsonaccess(Value, [], Result).

jsonaccess(jsonobj([_ | Members]), [Field], Result) :-
    jsonaccess(jsonobj(Members), Field, Result).

%%% jsonaccess when I have multiple fields
jsonaccess(jsonobj([(Field, Value) | _]), [Field | Fields], Result) :-
    jsonaccess(Value, Fields, Result).

jsonaccess(jsonobj([_ | Members]), [Fields], Result) :-
    jsonaccess(jsonobj(Members), Fields, Result).


%%% case where Field is a string
jsonaccess(jsonobj(Member), FieldString, Result) :-
    jsonaccess(jsonobj(Member), [FieldString], Result).


%%% jsonaccess of a jsonarray
jsonaccess(jsonarray(Elements), [I], Result) :-
    !,
    index_array(Elements, 0, I, Result).

jsonaccess(jsonarray(Elements), [I | Is], Result) :-
    jsonaccess(jsonarray(Elements), [I], ArrayResult),
    jsonaccess(ArrayResult, Is, Result).


%%% if the counter and index are the same i found the element
index_array([Element | _], Count, Count, Element) :- !.

index_array([_ | Elements], Count, I, Result) :-
    Count < I, 
    J is Count + 1,
    index_array(Elements, J, I, Result).

%%% Input/Output

%%% jsonread/2
%%% jsonread(FileName, Json).
%%% The jsonread/2 predicate opens the file FileName
%%% and succeeds if it can construct an object JSON.
%%% If FileName does not exist the predicate fails.
jsonread(FileName, JSON) :-
    catch(open(FileName, read, In), _, false),
    read_file_to_codes(FileName, Codes, []),
    close(In),
    atom_string(JSONString, Codes),
    jsonparse(JSONString, JSON).

%%% jsondump/2
%%% jsondump(JSON, FileName).
%%% The jsondump/2 predicate writes JSON object to file FileName in JSON syntax.
%%% If FileName does not exist, it is created and if it exists it is overwritten.
jsondump(JSON, FileName) :-
    jsonbuild(JSON, JSONString),
    open(FileName, write, In),
    write(In, JSONString),
    close(In).

jsonbuild(jsonobj([]), '{}').
jsonbuild(jsonarray([]), '[]').

%%% build the json object
jsonbuild(jsonobj(Member), JSONString) :-
    jsonbuild(Member, StringMember),
    atomic_list_concat(['{', StringMember, '}'], JSONString).

%%% build the members
jsonbuild(jsonobj([Member | Members]), StringObject) :-
    jsonbuild(Member, StringMember),
    jsonbuild(Members, StringMembers),
    atom_concat(StringMember, ',', StringPairComma),
    atom_concat(StringPairComma, StringMembers, StringObject).

%%% build the pair
jsonbuild((Key, Value), StringPair) :-
    atomic_list_concat(['"', Key, '"'], StringKey),
    atom_concat(StringKey, ' :', StringKeyColon),
    jsonbuild_value(Value, StringValue),
    atom_concat(StringKeyColon, StringValue, StringPair).

%%% build the json array
jsonbuild(jsonarray(Elements), JSONString) :-
    jsonbuild(Elements, StringElements),
    atomic_list_concat(['[', StringElements, ']'], JSONString).

jsonbuild([Element], StringElement) :-
    jsonbuild(Element, StringElement).

%%% build the elements
jsonbuild([Element | Elements], JSONString) :-
    jsonbuild(Element, StringElement),
    atom_concat(StringElement, ', ', StringElementComma),
    jsonbuild(Elements, StringElements),
    atom_concat(StringElementComma, StringElements, JSONString).

jsonbuild(Element, StringElement) :-
    jsonbuild_value(Element, StringElement).


%%% a value can be a string, number, boolean, object, array, null
jsonbuild_value(Value, Value) :-
    atom(Value),
    jsonbuild_bool_null(Value).

% string
jsonbuild_value(Value, StringValue) :-
    string(Value),
    atomic_list_concat(['"', Value, '"'], StringValue).

% number
jsonbuild_value(NumValue, NumValue) :-
    number(NumValue).

% jsonobj or jsonarray
jsonbuild_value(Value, StringValue) :-
    jsonbuild(Value, StringValue).

jsonbuild_bool_null(true).
jsonbuild_bool_null(false).
jsonbuild_bool_null(null).

%%%% end of file --jsonparse.pl
