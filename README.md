# github-action-yaml-update-and-push

Useful to push images updates to a master repository containing central manifests.

### When to use it?

If you are using Kubernetes, usually, after building and pushing a Docker image to it's registry
you will probably need to push that new tag to the repository that has all your manifest.

### Flow:

-   Clones the central repository
-   Runs: yq edit set image
-   Pushes the resulted manifest to the central repository

There are different variables to setup the action:

## Inputs

### `yq-version` (argument)

yq version to use. Check: https://github.com/mikefarah/yq/releases

### `yaml-file` (argument)

Path and file name to update. For example env/values.yaml

### `yaml-path` (argument)

Path of the yaml property. The input must begin with a .
For example to update the path: image > tag
Use: .image.tag

### `yaml-value` (argument)

The new value for yaml-path input. Probably the new image tag

### `user-email` (argument)

The email that will be used for the commit in the destination-repository-name.

### `user-name` (argument) [optional]

The name that will be used for the commit in the destination-repository-name. If not specified, the `repository-username` will be used instead.

### `repository-username` (argument)

The repository we will push the yq results to.
For the repository `https://github.com/rusowyler/github-action-kustomize-and-push` is `rusowyler`.

### `repository-name` (argument)

For the repository `https://github.com/rusowyler/github-action-kustomize-and-push` is `github-action-kustomize-and-push`

### `branch` (argument) [optional]

The branch name for the destination repository. It defaults to `main`.

### `directory` (argument) [optional]

The directory to wipe and replace in the target repository. Defaults to wiping the entire repository

### `commit-message` (argument) [optional]

The commit message to be used. Defaults to "New image for YAML_FILE, YAML_PATH:YAML_VALUE from ORIGIN_COMMIT".
ORIGIN_COMMIT, GITHUB_REF, YAML_FILE, YAML_PATH and YAML_VALUE are replaced by they values

### `API_TOKEN_GITHUB` (environment)

E.g.:
`API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}`

Generate your personal token following the steps:

-   Go to the Github Settings (on the right hand side on the profile picture)
-   On the left hand side pane click on "Developer Settings"
-   Click on "Personal Access Tokens" (also available at https://github.com/settings/tokens)
-   Generate a new token, choose "Repo". Copy the token.

Then make the token available to the Github Action following the steps:

-   Go to the Github page for the repository that you push from, click on "Settings"
-   On the left hand side pane click on "Secrets"
-   Click on "Add a new secret" and name it "API_TOKEN_GITHUB"

## Example usage

```yaml
- name: Update yaml and push
  uses: rusowyler/github-action-yaml-update-and-push@main
  env:
      API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
  with:
      yq-version: "v4.20.2"
      yaml-file: "dev/values.yaml"
      yaml-path: ".image.tag"
      yaml-value: "1.0.1"
      repository-username: "rusowyler"
      repository-name: "central-k8s-repository"
      user-email: demo@usermail.com
```

## TODO:

-   Add real world examples
-   Add a working example
