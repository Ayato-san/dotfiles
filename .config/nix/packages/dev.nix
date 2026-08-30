pkgs: with pkgs; [
  ansible
  ansible-lint
  codex
  gh
  imagemagick
  kubectl
  kubernetes-helm
  proton-pass-cli
  tealdeer
  terraform
  yarn-berry
]
++ lib.optionals stdenv.hostPlatform.isLinux [
  gcc
]
