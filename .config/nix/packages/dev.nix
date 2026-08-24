pkgs: with pkgs; [
  ansible
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
