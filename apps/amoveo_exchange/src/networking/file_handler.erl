-module(file_handler).
-export([init/3, handle/2, terminate/3]).
%example of talking to this handler:
%httpc:request(post, {"http://127.0.0.1:3011/", [], "application/octet-stream", "echo"}, [], []).
%curl -i -d '[-6,"test"]' http://localhost:3011
handle(Req, _) ->
    {F, _} = cowboy_req:path(Req),
    %io:fwrite("file handler handle\n"),
    %io:fwrite(F),
    %io:fwrite("\n"),
    PrivDir = <<"../../../../js">>,
    true = case F of
               <<"/favicon.ico">> -> true;
               <<"/server.js">> -> true;
               <<"/format.js">> -> true;
               <<"/status.js">> -> true;
               <<"/trade.js">> -> true;
               <<"/rpc.js">> -> true;
               <<"/lookup_account.js">> -> true;
               <<"/lookup_trade.js">> -> true;
               <<"/make_trade.js">> -> true;
               <<"/withdrawal.js">> -> true;
               <<"/server_pub.js">> -> true;
               <<"/instructions.html">> -> true;
               <<"/main.html">> -> true;
               X -> 
                   io:fwrite("file handler block access to: "),
                   io:fwrite(X),
                   io:fwrite("\n"),
                   false
           end,
    File = << PrivDir/binary, F/binary>>,
    {ok, _Data, _} = cowboy_req:body(Req),
    Headers = [{<<"content-type">>, <<"text/html">>},
    {<<"Access-Control-Allow-Origin">>, <<"*">>}],
    Text = read_file(File),
    {ok, Req2} = cowboy_req:reply(200, Headers, Text, Req),
    {ok, Req2, File}.
read_file(F) ->
    {ok, File } = file:open(F, [read, binary, raw]),
    {ok, O} =file:pread(File, 0, filelib:file_size(F)),
    file:close(File),
    O.
init(_Type, Req, _Opts) -> {ok, Req, []}.
terminate(_Reason, _Req, _State) -> ok.
