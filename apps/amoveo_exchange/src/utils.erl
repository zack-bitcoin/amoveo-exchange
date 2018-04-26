-module(utils).
-compile(export_all).

read_file(LOC) -> 
    case file:read_file(LOC) of
	{error, _} -> "";
	{ok, X} -> binary_to_term(X)
    end.
save(X, LOC) -> file:write_file(LOC, term_to_binary(X)).
init(Default, LOC) ->
    X = read_file(LOC),
    Ka = if
	     X == "" -> 
		 Y = Default,
		 save(Y, LOC),
		 Y;
	     true -> X
	 end,
    {ok, Ka}.
    
