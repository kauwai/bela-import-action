# BELA Import Action

GitHub Action for importing a repository into BELA without sending source code to BELA.

The action prepares the project in GitHub Actions, runs the matching BELA updater Docker image with `--network=none`, and uploads only `.bela/bela-update.ecd` to the BELA API.

## Usage

```yaml
name: Import to BELA

on:
  workflow_dispatch:

jobs:
  bela-import:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: juxhouse/bela-import-action@v0.1.0
        with:
          bela-api-url: ${{ secrets.BELA_API_URL }}
          bela-api-token: ${{ secrets.BELA_API_TOKEN }}
```

For monorepos, point `working-directory` at the project folder you want to import:

```yaml
- uses: juxhouse/bela-import-action@v0.1.0
  with:
    bela-api-url: ${{ secrets.BELA_API_URL }}
    bela-api-token: ${{ secrets.BELA_API_TOKEN }}
    working-directory: typescript
    source: ${{ github.repository }}/typescript
```

## Inputs

| Input | Required | Default | Description |
| --- | --- | --- | --- |
| `bela-api-url` | yes | | BELA backend URL. |
| `bela-api-token` | yes | | BELA API token. |
| `source` | no | `${{ github.repository }}` | Source name written to the ECD file. |
| `parent-element-path` | no | | Optional BELA parent element path. |
| `language` | no | `auto` | `auto`, `clojure`, `dotnet`, `java`, `ruby`, or `typescript`. |
| `updater-tag` | no | `latest` | Docker tag used for `juxhouse/bela-updater-*` images. |
| `working-directory` | no | `.` | Repository-relative directory to import. |

## Supported Detection

The `auto` language mode detects:

| Files | Language |
| --- | --- |
| `deps.edn`, `project.clj` | Clojure |
| `package.json` | TypeScript / JavaScript |
| `pom.xml`, `build.gradle`, `build.gradle.kts`, `gradlew` | Java |
| `Gemfile` | Ruby |
| `*.sln`, `*.csproj` | .NET |

## Security Model

Project preparation may use the network to download dependencies, as normal CI builds do.

The updater execution step runs with:

```sh
docker run --network=none --pull=never ...
```

That means the analysis container receives the prepared workspace but cannot access the network while reading customer code. The only data uploaded to BELA is `.bela/bela-update.ecd`.
