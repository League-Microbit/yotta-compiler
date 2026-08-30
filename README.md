# yotta-compiler — Docker image for local micro:bit compilation

A Docker container that replaces the deprecated
[`pext/yotta`](https://hub.docker.com/r/pext/yotta) image for
building micro:bit projects with native C++ code locally.

When you set `PXT_FORCE_LOCAL=1`, MakeCode's PXT build system runs
this image for the yotta/codal compilation step — no cloud compile
service needed.

**Published to GitHub Container Registry:**
`ghcr.io/league-microbit/yotta-compiler:latest`

## What's inside

- Ubuntu 20.04 LTS
- ARM GCC cross-compiler (`gcc-arm-none-eabi`)
- yotta build system
- cmake, ninja, srecord, build-essential
- A dedicated `build` user (PXT runs yotta as this user)

## Using this compiler

### Option 1 — Pre-pull and tag (recommended for local builds)

PXT's codal build engine hardcodes `pext/yotta:latest` as the
Docker image name. To use our image, pull it and tag it:

```bash
docker pull ghcr.io/league-microbit/yotta-compiler:latest
docker tag ghcr.io/league-microbit/yotta-compiler:latest pext/yotta:latest
```

Now `PXT_FORCE_LOCAL=1 pxt build` will find the image cached locally
under the name PXT expects and use it instead of pulling from Docker Hub.

This is a one-time setup. The `docker-pull` target in the
[nezha-robot-template](https://github.com/League-Robotics/nezha-robot-template)
Makefile does both steps for you.

### Option 2 — Use with `pxt serve`

Copy `pxtarget.json` from this repo into your project root
(alongside `pxt.json`). This tells `pxt serve` to stay in the
project directory rather than switching to the target directory.

### Option 3 — Build the image yourself

```bash
git clone https://github.com/League-Microbit/yotta-compiler.git
cd yotta-compiler
make build
```

## pxtarget.json

The `pxtarget.json` in this repo is minimal — it exists so `pxt serve`
stays in your project directory instead of switching to the target.
Copy it alongside your `pxt.json`:

```bash
curl -O https://raw.githubusercontent.com/League-Microbit/yotta-compiler/main/pxtarget.json
```

For `pxt build` with `PXT_FORCE_LOCAL=1`, PXT uses the Docker image
name hardcoded in the target's own config (`pext/yotta:latest`).
Use Option 1 above (docker pull + tag) to substitute our image.

## Make targets

| Command | What it does |
|---------|-------------|
| `make build` | Build the Docker image |
| `make rebuild` | Build from scratch (no cache) |
| `make push` | Push to ghcr.io |
| `make pull` | Pull from ghcr.io |
| `make test` | Build, then run `yotta --version` |
| `make shell` | Build, then open a shell in the container |
| `make clean` | Remove the local image |
| `make info` | Show image information |

## CI / Releases

On every push to `main`, the
[`docker-publish.yml`](.github/workflows/docker-publish.yml) workflow
builds the Docker image and pushes it to
`ghcr.io/league-microbit/yotta-compiler:latest`.

The image is also tagged with the short commit SHA
(`ghcr.io/league-microbit/yotta-compiler:sha-<hash>`) for pinning
to a specific build.

## License

MIT — see [LICENSE](LICENSE).