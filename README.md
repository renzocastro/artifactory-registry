
# Artifactory Registry

[![npm version](https://img.shields.io/npm/v/artifactory-registry.svg?style=flat)](npm-url)

> Tested only on MacOS.

CLI for set up [JFrog Artifactory](artifactory-url) with scope in NPM config.

[npm-url]:https://www.npmjs.com/package/artifactory-registry
[artifactory-url]:https://jfrog.com/artifactory/


## Usage

You don't need to install it. Instead you will use `npx`.


### `init`

Go to the root path of the project and initialize the tool:

```shell
$ npx artifactory-registry init
```

That command create `artifactory.json` file:

```json
{
  "scope": "my-scope",
  "host": "http://localhost:8081",
  "repositoryName": "my-project.npm.dev"
}
```

Configure `artifactory.json` using your JFrog Artifactory NPM configuration.


### `add`

Set the new configuration in NPM config. Require JFrog Artifactory authetication.

```shell
$ npx artifactory-registry add
```

Check the new NPM configuration:

```shell
$ cat ~/.npmrc
```


### `remove`

If you want to remove a NPM configuration:

```shell
$ npx artifactory-registry remove
```

This only remove the same data setted in `artifactory.json` file.
