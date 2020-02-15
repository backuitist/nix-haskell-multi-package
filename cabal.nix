# taken from: https://gist.github.com/codebje/000df013a2a4b7c10d6014d8bf7bccf3
with builtins; rec {
  cabalProjects = listToAttrs (if pathExists ./cabal.project
                  then projectParse
                  else [ { name = baseNameOf ./.; value = ./.; } ] );
  projectParse = let
    contents = readFile ./cabal.project;
    trimmed = replaceStrings ["packages:" " "] ["" ""] contents;
    packages = filter (x: isString x && x != "") (split "\n" trimmed);
    paths = map (p: { name = p; value = ./. + "/${p}"; } ) packages;
  in paths;
}.cabalProjects
