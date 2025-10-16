# redirector-flake

A Nix flake for [redirector](https://github.com/Adolar0042/redirector).

## Prerequisites

Ensure you have Nix installed with flakes enabled.

## Quick Start

To quickly try out the application, run it directly from the flake:

```sh
nix run github:vipulog/redirector-flake#redirector
```

## Usage

### Home Manager Module

1. Add the flake to your `flake.nix` inputs:

   ```nix
   {
     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
       home-manager.url = "github:nix-community/home-manager";
       home-manager.inputs.nixpkgs.follows = "nixpkgs";

       redirector-flake.url = "github:vipulog/redirector-flake";
       redirector-flake.inputs.nixpkgs.follows = "nixpkgs";
       redirector-flake.inputs.home-manager.follows = "home-manager";
     };
   }
   ```

1. Import the module and configure the service in your `home.nix`:

   ```nix
   {
     imports = [ inputs.redirector-flake.homeModules.default ];

     services.redirector = {
       enable = true;

       settings = {
         port = 3000;
         bangs_url = "https://duckduckgo.com/bang.js";
         default_search = "https://www.qwant.com/?q={}";
         bangs = [
           {
             trigger = "gh";
             url_template = "https://github.com/search?q={{{s}}}";
             short_name = "GitHub";
             category = "Tech";
           }
           {
             trigger = "yt";
             url_template = "https://www.youtube.com/results?search_query={{{s}}}";
             short_name = "YouTube";
             category = "Video";
           }
         ];
       };
     };
   }
   ```

1. Rebuild your Home Manager configuration.

   The Home Manager module automatically configures the binary cache for you. However, this setting only applies *after* the first successful build. To avoid building from source on the first run, you can temporarily add the cache settings to your command:

   ```sh
   home-manager switch --flake . --option extra-substituters "https://redirector.cachix.org" --option extra-trusted-public-keys "redirector.cachix.org-1:dvngBv4RkdsLLFfbFuxSWJ+Q+y1b126oU3dLizPaQxM="
   ```

   Subsequent runs of `home-manager switch` will not require these options.
