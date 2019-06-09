## Environment

It's highly recommended to [install Nix](https://nixos.org/nix/download.html).

- E.g.
```shell
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
```

### Quick Start

- TL;DR:
```shell
make setup && make test
make build && scripts/run random_render --help
```

- More:
```shell
make help
```

## FAQ

### Using unstable channel

Nix development Environment relies on unstable channel.
Which is default on fresh nix install.

So in case you're on stable nix, or use NixOS, do the following:

1. Add unstable channel:

```shell
nix-channel --add https://nixos.org/channels/nixos-unstable unstable
```

2. Update unstable channel:

```
nix-channel --update
```

3. Pass the `NIX_ARGS` variable to make:  
(note that path to `channels/unstable` may differ on your system)

```shell
make NIX_ARGS="-I nixpkgs=$HOME/.nix-defexpr/channels/unstable" sync

# Other way

export NIX_ARGS="-I nixpkgs=$HOME/.nix-defexpr/channels/unstable"
make sync
```

### Run REPL on or build sub-directory only

```shell
scripts/repl ./test
```

```shell
scripts/build ./test
```

## Troubleshooting

- Missing dependencies
In case you encounter a message like this (i.e. in case of library missing):

```
Error: Library "alcotest" not found.
```

Launch the following command: `make sync`. In case it didn't help, try
update lock file: `make lock` and try again. If this didn't help, try
`make update` to install dependencies without lock file, or even `make upgrade`
to upgrade their versions.

- User groups permission

In case during project building on GNU/Linux you encounter such message:

```
error: cloning builder process: Operation not permitted
```

Then user groups for non-privileged users should be enabled:

```shell
sysctl kernel.unprivileged_userns_clone=1
```
