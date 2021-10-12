{ stdenv, pandoc, haskellPackages, texlive, gnome3, pandoc-plantuml-filter,
plantuml, ghostscript, inotify-tools }:

stdenv.mkDerivation rec {
  name = "philosophers-stone-slides";
  nativeBuildInputs = [
    # this one downloads quickly because it's the statically compiled version
    pandoc
    # this one is slower to download because nixpkgs has no statically compiled
    # version in the nixos cache (maybe upstream it?)
    haskellPackages.pandoc-crossref
    # there are also bigger texlive distribution collections available if more
    # tex packages are needed
    texlive.combined.scheme-full
    gnome3.librsvg # provides rsvg-convert

    pandoc-plantuml-filter
    plantuml

    ghostscript # for gs
  ];

  src = ./.;

  # enable for better resolution, see also the "skinparam dpi 500" directives
  # in the diagrams. There are pandoc-plantuml-filter pull requests on github
  # that enable for native latex image generation, but i did not get that to
  # play well with figure annotations/captions/centering etc.
  PLANTUML_BIN = "plantuml -Xmx2048m -DPLANTUML_LIMIT_SIZE=16384";

  # just run `watch build mydoc.md` to automatically rebuild pdf on editor save
  shellHook = ''
    watch() {
      while ${inotify-tools}/bin/inotifywait --exclude .swp -e modify -r .;
        do $@;
      done;
    }
    build() {
      pandoc \
        -F pandoc-crossref \
        -F pandoc-plantuml \
        -t beamer \
        -s \
        --include-in-header=./style.tex \
        "$1" \
        -o "''${1%.md}.pdf";
    }
    reduce_size() {
      inFile=$1
      outFile=$2
      gs -sDEVICE=pdfwrite \
         -dCompatibilityLevel=1.4 \
         -dPDFSETTINGS=/printer \
         -dNOPAUSE -dQUIET -dBATCH \
         "-sOutputFile=$outFile" \
         "$inFile"
    }
  '';

  buildPhase = ''
    ${shellHook}
    build slides.md
  '';

  installPhase = ''
    mkdir $out
    cp *.pdf $out/
    ${shellHook}
  '';
}
