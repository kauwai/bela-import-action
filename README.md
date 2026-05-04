# BELA Import Action

GitHub Action for importing a repository into BELA without sending source code to BELA.

The action prepares the project in GitHub Actions, runs the matching BELA updater Docker image with `--network=none`, and uploads only `.bela/bela-update.ecd` to the BELA API.

## Recommended Usage

```yaml
name: Import to BELA

on:
  workflow_dispatch:

jobs:
  bela-import:
    uses: juxhouse/bela-import-action/.github/workflows/bela-import.yml@v0.1.0
    with:
      bela-api-url: ${{ vars.BELA_API_URL }}
    secrets:
      bela-api-token: ${{ secrets.BELA_API_TOKEN }}
```

## Advanced Usage

Use the action directly when you need to customize the job or run project-specific steps before the import.

```yaml
name: Import to BELA

on:
  workflow_dispatch:

jobs:
  bela-import:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - uses: juxhouse/bela-import-action@v0.1.0
        env:
          BELA_API_TOKEN: ${{ secrets.BELA_API_TOKEN }}
        with:
          bela-api-url: ${{ vars.BELA_API_URL }}
```

## Inputs

| Input | Required | Description |
| --- | --- | --- |
| `bela-api-url` | yes | BELA backend URL. |
| `parent-element-path` | no | Optional BELA parent element path. |

## Secrets

| Name | Required | Description |
| --- | --- | --- |
| `BELA_API_TOKEN` | yes | BELA API token. Use it as the `bela-api-token` secret in the reusable workflow or as the `BELA_API_TOKEN` environment variable when calling the action directly. |

## Supported Detection

The action automatically detects:

| Language | Files |
| --- | --- |
| C# | `*.sln`, `*.csproj` |
| Clojure | `deps.edn`, `project.clj` |
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts`, `gradlew` |
| JavaScript | `package.json` |
| Ruby | `Gemfile` |
| TypeScript | `package.json` |

## Security Model

Project preparation may use the network to download dependencies, as normal CI builds do.

The updater execution step runs with:

```sh
docker run --network=none --pull=never ...
```

That means the analysis container receives the prepared workspace but cannot access the network while reading customer code. The only data uploaded to BELA is `.bela/bela-update.ecd`.
