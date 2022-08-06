TheDarkMod - Nix Flake
======================

This repository contains a so far rather incomplete attempt at
packaging https://www.thedarkmod.com/ into a Nix package.

The game itself can be build with:

    nix build github:grumnix/thedarkmod#thedarkmod

The editor can be build with:

    nix build github:grumnix/thedarkmod#darkradiant

However both of those are not very useful on their own, as the game
data is missing and only seems to be available via the
`tdm_installer`, which itself is not suitable for packaging, as it
wants to download and save the data by itself.
