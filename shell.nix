#
#  Development Environment Sandbox
#

with import <nixpkgs> {};

let
  sandbox-exec = stdenv.mkDerivation {
    name = "sandbox-exec";
    src = /usr/bin/sandbox-exec;
    unpackPhase = "true";
    buildPhase = "true";
    installPhase = "mkdir -p $out/bin && ln -s $src $out/bin/sandbox-exec";
  };
in

stdenv.mkDerivation {
  name = "mainnet";
  src = if lib.inNixShell then null else ./.;

  shellHook = ''
    eval `opam env -y`
    # TODO: reuse parent shell variables
    export TERM="''${TERM:-linux}"
    export OPAMSOLVERTIMEOUT=120
  '';

  buildInputs = with ocaml-ng.ocamlPackages_4_05; [
    openssl
    opam
    ocaml
    dune
    ocamlformat
    utop
    odoc
    merlin
    ocp-indent
    (ocp-index.overrideAttrs (drv: {
      buildPhase = "dune build -p ocp-index,ocp-browser";
      buildInputs = drv.buildInputs ++ [ lambdaTerm ];
    }))
    gmp
    coreutils
    cacert
    gnupg
    fswatch
    m4
    pkg-config
    perl
    less
    which
    tree
    ripgrep
    gitMinimal
    mercurial
    ncurses
    colordiff
    expect
    rocksdb
    zeromq
  ] ++ stdenv.lib.optional stdenv.isDarwin sandbox-exec;
}
