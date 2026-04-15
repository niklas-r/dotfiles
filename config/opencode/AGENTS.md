## Load GitNexus context

If your current working directory contains ~/Code; You **MUST** run this at the start of every new session.

```sh
[ -d .gitnexus ] && echo "gitnexus is used" || echo "gitnexus is NOT used"
```

### Dynamically load more context

Load more GitNexus context if the current project is using GitNexus by reading `$HOME/.config/opencode/context/gitnexus.md`

