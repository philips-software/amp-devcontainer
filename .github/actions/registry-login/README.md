# registry-login

Logs in to a container registry, with the credentials that are given, and otherwise with what the registry accepts.
This is for workflows that are used with registries other than ghcr.io, such as Docker Hub or Artifactory, where a missing credential must not turn into a failed login with the wrong identity.

The token of a workflow (`github.token`) is only valid for the GitHub Container Registry.
Sending it to another registry fails the login, and hands that registry a token it has no business with.
So the action decides per registry:

| Credentials           | Registry                               | Result                                                                                          |
|-----------------------|----------------------------------------|-------------------------------------------------------------------------------------------------|
| username and password | any                                    | Logs in with them (`authentication` is `credentials`).                                          |
| none                  | `ghcr.io`                              | Logs in with the identity of the workflow (`github`).                                           |
| none                  | any other                              | Does not log in, the registry is used anonymously (`anonymous`), enough to pull public images.  |
| none                  | any other, `require-credentials: true` | Fails, because pushing is not possible anonymously.                                             |
| only one of them      | any                                    | Fails, that is a mistake in the configuration.                                                  |

The login is undone when the job ends, by `docker/login-action`.

> [!NOTE]
> Anonymous pulls are enough for public images, but some registries rate limit them per IP address, and GitHub-hosted runners share their addresses. Docker Hub does, so pass credentials for it as well when a job pulls from it often.

## Usage

```yaml
- uses: philips-software/amp-devcontainer/.github/actions/registry-login@...
  with:
    registry: registry.example.invalid
    username: ${{ secrets.MY_REGISTRY_USERNAME }} # optional for ghcr.io, and to pull public images
    password: ${{ secrets.MY_REGISTRY_PASSWORD }}
    require-credentials: true # when the job pushes images
```

The caller needs `packages: read` (or `packages: write` to push) when the login uses the identity of the workflow, and a container engine on the runner.

## Inputs and outputs

| Name                  | Kind   | Required | Description                                                                                                  |
|-----------------------|--------|----------|--------------------------------------------------------------------------------------------------------------|
| `password`            | input  | no       | Password or token of the registry, required together with `username`.                                        |
| `registry`            | input  | yes      | Server address of the registry, e.g. `ghcr.io`.                                                              |
| `require-credentials` | input  | no       | Fail when there are no credentials for a registry other than ghcr.io. Defaults to `false`.                   |
| `username`            | input  | no       | Username of the registry, required together with `password`.                                                 |
| `authentication`      | output | -        | `credentials`, `github` or `anonymous`: how was logged in, for steps that need to pass the same identity on. |

## Tests

The tests run the script that makes the decision. Run them with [Bats](https://bats-core.readthedocs.io) from the repository root:

```bash
bats .github/actions/registry-login/test
```
