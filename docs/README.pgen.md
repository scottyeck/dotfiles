# pgen

> An extremely dumb and lightweight install / uninstall tool for vim plugins using [Pathogen](https://github.com/tpope/vim-pathogen).

## TLDR;

Add a plugin:

```sh
$ pgen add https://github.com/jceb/vim-orgmode
```

Add a plugin at a particular commit:

```sh
$ pgen add https://github.com/jceb/vim-orgmode 35e94218c12a0c063b4b3a9b48e7867578e1e13c
```

Remove a plugin:

```sh
$ pgen remove vim-orgmode
```

List all installed plugins:

```sh
$ pgen list
```

Install all plugins from your `.pathogenrc`:

```sh
$ pgen install
```

Sync data for manually installed plugins back to your `.pathogenrc`:

```sh
$ pgen sync
```

Remove plugins whose data is not listed in `.pathogenrc`:

```
$ pgen prune
```

## Motivation

I wrote this so that I could easily sync `vim` plugins installed using _Pathogen_ across machines, the idea being I could just pull down a `.pathogenrc` and run `pgen install`. From there it wasn't much extra to add an extra layer of abstraction to `add`/`remove`, etc.

My _guess_ is that this tool is (or was) a not-so-great idea built in lieu of just doing actual research to solve a particular problem,but it's here and integrated into my workflow now so 🤷‍♂️.

## Further thoughts

* The separation of `prune` (which is really a `clean`) and `sync` is somewhat unnecessary.
* Needs `--help`, etc.