-module(reloading).

-export([reload/0]).
-define(PROJECT_NAME, "udp_server").

reload() ->
  EBinDir = "./_build/default/lib/" ++ ?PROJECT_NAME ++ "/ebin/",
  % SrcFileList = filelib:fold_files("./src/", ".*.erl", true, fun(F, AccIn) -> [F | AccIn] end, []),
  SrcFileList = filelib:wildcard("src/**/*.erl"),

  lists:foreach(fun(SrcFile) ->
      FileName = filename:rootname(filename:basename(SrcFile)),
      ModAtom = list_to_atom(FileName),

      case ModAtom of
        ?MODULE ->
          ignore;
        _ ->
          case compile:file(SrcFile, {outdir, EBinDir}) of
            {ok, ModName} ->
              c:l(ModName);
              % code:delete(ModName),
              % code:purge(ModName),
              % code:load_file(ModName);
            _ ->
              io:format("模块 ~p 编译失败，请检查~n", [SrcFile])
          end
      end
  end,
  SrcFileList).