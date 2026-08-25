pkgs: with pkgs; [
  ansible
  ansible-lint
  bat
  codex
  eza
  gh
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
