# nth

> Prints the nth line.

## TLDR;

Consider:

```
// some-file.txt

1. Apples
2. Bananas
3. Carrots
4. Daniel Day Lewis
```

Then:

```sh
$ cat some-file.txt | nth 4
# > Daniel Day Lewis
```

Note that we index at 1. This is to keep in line with printing the nth word in a line via `awk`.
