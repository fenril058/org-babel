# Quick-and-dirty re-implementation of org-babel-tangle in Nix.
{
  languages ? [
    "emacs-lisp"
    "elisp"
  ],
  transformLines ? null,
  processLines ? null,
  tangleArg ? "yes",
}:
string:
with builtins;
let
  warn =
    msg: value:
    if builtins ? warn then
      builtins.warn msg value
    else
      trace msg value;

  effectiveTransformLines =
    if transformLines != null then
      transformLines
    else if processLines != null then
      warn "`processLines` is deprecated; use `transformLines` instead."
        processLines
    else
      lines: lines;

  lines = filter isString (split "\n" string);

  dropUntil = import ./dropUntil.nix;

  blockStartRegexp =
    "[[:space:]]*\#\\+[Bb][Ee][Gg][Ii][Nn]_[Ss][Rr][Cc][[:space:]]+"
    + "("
    + (concatStringsSep "|" languages)
    + ")"
    + "(([[:space:]].*)?)";

  parseParamsString = import ./parseParamsString.nix;

  parseParamsString' = s: if s == null then { } else parseParamsString s;

  checkBlockParams = attrs: (attrs.":tangle" or "yes") == tangleArg;

  isBlockStart =
    line:
    (match blockStartRegexp line != null)
    && checkBlockParams (parseParamsString' (elemAt (match blockStartRegexp line) 2));

  splitListWith = import ./splitWith.nix;

  blockEndRegexp = "[[:space:]]*\#\\+[Ee][Nn][Dd]_[Ss][Rr][Cc].*";

  isBlockEnd = line: match blockEndRegexp line != null;

  unescapeLine =
    line:
    let
      m = match "([[:blank:]]*),((\\*|#\\+).*)" line;
    in
    if m == null then line else elemAt m 0 + elemAt m 1;

  go =
    acc: xs:
    let
      st1 = dropUntil isBlockStart xs;
      st2 = splitListWith isBlockEnd st1;
    in
    if length xs == 0 then
      acc
    else if length st1 == 0 then
      acc
    else
      (go (acc ++ [ (map unescapeLine st2.before) ]) st2.after);

in
concatStringsSep "\n" (concatLists (go [ ] (effectiveTransformLines lines)))
