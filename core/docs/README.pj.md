# pj

> Quick access to `package.json` segments

## TLDR;

Usage:

```
$ pj [path] [option]
```

Example:

See `scripts` available in current directory's `package.json`:

```
$ pj . scripts
```

See `dependencies` listed in `package.json` in a nested _yarn_ workspace.

```
$ pj apps/my-app deps
```

### Options

* `scripts`
* `deps` - dependencies
* `dev` - dev dependencies

