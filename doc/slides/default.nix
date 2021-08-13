let
  nixpkgs = builtins.fetchTarball {
    # update this by setting the hash in this URL to a newer commit
    url = "https://github.com/nixos/nixpkgs/archive/5c663b24b68b209d2d8fa2e95b5eb0ba42fca75e.tar.gz";
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "0zs9ar3i4z0mnkdqajfwk6qxqyclizk8l322xdpf6zniqsy92fdx";
  };
  pkgs = import nixpkgs { };

  eisvogel = builtins.fetchTarball {
    url = "https://github.com/Wandmalfarbe/pandoc-latex-template/archive/4909f13d58bb4c66243def1f6e01becd1820c767.tar.gz";
    sha256 = "01vaqdf8a9bwpzzx65bsqk11h1fcqli2w9rnj4l03h0iwl14dh3x";
  };
in
pkgs.stdenv.mkDerivation rec {
  name = "philosophers-stone-slides";
  nativeBuildInputs = with pkgs; [
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
      while ${pkgs.inotify-tools}/bin/inotifywait --exclude .swp -e modify -r .;
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
