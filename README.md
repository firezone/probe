<p align="center">
  <a href="https://probe.sh">
    <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./priv/static/images/probe-logo-dark.svg">
    <img alt="Probe logo" src="./priv/static/images/probe-logo-light.svg">
    </picture>
  </a>
</p>

# Probe

This repo contains the application source for https://probe.sh, a web service for testing WireGuard® connectivity built by the team behind [Firezone](https://www.github.com/firezone/firezone).

## How it works

1. When the Probe application boots, it starts an Elixir `gen_udp` server for each WireGuard listen port defined in `config.exs` to listen for incoming UDP payloads on that port.
1. When a user visits the app, Probe starts a Phoenix LiveView process and generates a unique cryptographic token to use for the test.
1. When the user runs the script shown, it first sends a request to start the test, followed by a series of UDP payloads, and finally either a `complete` or `cancel` request to end the test.
1. The `gen_udp` receives these payloads, and if they match one of the four [WireGuard](https://www.wireguard.com) message types, it broadcasts test updates to the LiveView process for that test.
1. The user is immediately shown the results of the test.

## Contents of this repository

- [`apps/probe`](apps/probe): Phoenix application for the Probe service
- [`priv/static/scripts`](priv/static/scripts): OS-specific scripts for running the Probe tests, designed to be launched from the web app UI.
- [`config`](config): Configuration settings for various environments. You can add and remove more ports for testing in the `config.exs` file.
- [`docker-compose.yml`](docker-compose.yml): Docker Compose file to start required services for local development.
- [`fly.toml`](fly.toml): Fly.io configuration file for deploying the Probe app.
- [`Dockerfile`](Dockerfile): Dockerfile for building the Probe app image to run on Fly.io.

## Contributing to Probe

We welcome any and all contributions to Probe.
Before you invest a lot of time into a pull request, however, we recommend [opening an issue](https://www.github.com/firezone/probe/issues/new) to discuss the proposed changes.
For small fixes, feel free to open a pull request directly.

### Local development

You'll need the following pre-requisites to run Probe locally:

1. [Docker](https://docs.docker.com/get-docker/) + Docker Compose for your platform. Docker Desktop should work just fine.
1. We use [asdf](https://asdf-vm.com) to manage runtime versions for this repository. You can install asdf with `brew install asdf` on macOS.
1. Install required asdf plugins with `asdf plugin add erlang elixir nodejs`.
1. Install the required versions of Erlang, Elixir, and Node.js with `asdf install` in the root of this repository.
1. Install frontend dependencies with `pnpm i --prefix assets`.
1. Setup remaining dependencies with `mix setup`.

You're now ready to start a local development environment:

1. `docker compose up -d` to start the required services (PostgreSQL)
1. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser to see the Probe service running locally.

To add or remove ports to use for testing, see `config/config.exs`.
Note that you'll need to start the probe service with a privileged user (or with `CAP_NET_BIND_SERVICE` capabilities on Linux) to bind to ports below 1024.

### Deployment

The Firezone team deploys Probe to [Fly.io](https://fly.io) using the [Fly.io CLI](https://fly.io/docs/getting-started/installing-fly/).

You're welcome to deploy Probe to your own infrastructure for non-commercial purposes.

## Security policy

See [SECURITY.md](SECURITY.md)

## FAQ

See https://probe.sh/faq

WireGuard ia 
