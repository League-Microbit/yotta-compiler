# yotta-compiler — Docker image for local micro:bit compilation

A Docker container that replaces the deprecated
[`pext/yotta`](https://hub.docker.com/r/pext/yotta) image for
building micro:bit projects with native C++ code locally.

When you set `PXT_FORCE_LOCAL=1`, MakeCode's PXT build system pulls
this image and runs the yotta compiler inside it — no cloud compile
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

### Option 1 — Let PXT pull it automatically (recommended)

1. Copy `pxtarget.json` from this repo into the root of your
   MakeCode project (alongside `pxt.json`):

   ```bash
   curl -O https://raw.githubusercontent.com/League-Microbit/yotta-compiler/main/pxtarget.json
   ```

2. Build with local compilation:

   ```bash
   PXT_FORCE_LOCAL=1 pxt build
   ```

   PXT reads `pxtarget.json`, sees `compileService.dockerImage` pointing
   to `ghcr.io/league-microbit/yotta-compiler:latest`, pulls it from
   GHCR, and runs the yotta build inside the container.

### Option 2 — Pull manually

```bash
docker pull ghcr.io/league-microbit/yotta-compiler:latest
```

Then set `PXT_FORCE_LOCAL=1` and build as above. PXT will find the
image already cached locally.

### Option 3 — Build the image yourself

```bash
git clone https://github.com/League-Microbit/yotta-compiler.git
cd yotta-compiler
make build
```

## pxtarget.json

The `pxtarget.json` in this repo overrides the default compile
service config. Copy it to your project root alongside `pxt.json`:

```bash
curl -O https://raw.githubusercontent.com/League-Microbit/yotta-compiler/main/pxtarget.json
```

```json
{
    "compileService": {
        "dockerImage": "ghcr.io/league-microbit/yotta-compiler:latest",
        "buildEngine": "yotta",
        "yottaTarget": "bbc-microbit-classic-gcc-nosd"
    },
    "variants": {
        "mbcodal": {
            "compileService": {
                "dockerImage": "ghcr.io/league-microbit/yotta-compiler:latest"
            }
        }
    }
}
```

The top-level `compileService.dockerImage` covers the DAPLink (V1,
`mbdal`) yotta path. The `variants.mbcodal.compileService.dockerImage`
entry is **required** for micro:bit V2 projects: the CODAL build
engine uses its own Docker image setting, and without this variant-level
override PXT falls back to the deprecated `pext/yotta:latest`.

Without this file present in your project, PXT defaults to `pext/yotta`
images (which are deprecated and may not be available). With it, PXT
pulls from GHCR — no Docker Hub account needed.

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