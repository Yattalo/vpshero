---
description: Gestione Pull Request con GitHub CLI
argument-hint: <action: list|create|view|merge|review> [args]
allowed-tools: Bash(gh:*), Bash(git:*), Read
model: sonnet
---

# Pull Request: $1

**Action**: $1
**Args**: $2 $3 $4
**Timestamp**: !`date '+%Y-%m-%d %H:%M:%S'`

---

## Current Context

### Git Status
```
Branch: !`git branch --show-current`
Status: !`git status --short | head -10`
Remote: !`git remote -v | head -2`
```

### Recent Commits (not pushed)
```
!`git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "Branch not tracking remote"`
```

---

## PR Actions

### list - Lista PR aperte
```
!`gh pr list --limit 10 2>/dev/null || echo "Run: gh auth login"`
```

### create - Crea nuova PR
Parametri: `$2` = title, `$3` = base branch (default: main)

Template:
```bash
gh pr create \
  --title "$2" \
  --body "## Summary
<describe changes>

## Test Plan
- [ ] Unit tests pass
- [ ] Manual testing done

## Checklist
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] No breaking changes

---
Generated with Claude Code" \
  --base ${3:-main}
```

### view - Visualizza PR
```
!`gh pr view $2 2>/dev/null || echo "Usage: /pr view <number>"`
```

### merge - Merge PR
```bash
# Merge with squash (recommended)
gh pr merge $2 --squash --delete-branch

# Merge with merge commit
gh pr merge $2 --merge

# Merge with rebase
gh pr merge $2 --rebase
```

### review - Review PR
```
!`gh pr diff $2 2>/dev/null | head -100 || echo "Usage: /pr review <number>"`
```

```bash
# Approve
gh pr review $2 --approve

# Request changes
gh pr review $2 --request-changes --body "Please fix..."

# Comment
gh pr review $2 --comment --body "Looks good, minor suggestions..."
```

---

## Quick Commands

```bash
# Lista tutte le PR
gh pr list --state all

# PR assegnate a me
gh pr list --assignee @me

# PR che richiedono mia review
gh pr list --search "review-requested:@me"

# Checkout PR localmente
gh pr checkout <number>

# Vedi checks/CI status
gh pr checks <number>

# Vedi commenti
gh pr view <number> --comments

# Chiudi PR senza merge
gh pr close <number>

# Riapri PR
gh pr reopen <number>

# Aggiungi label
gh pr edit <number> --add-label "bug"

# Assegna reviewer
gh pr edit <number> --add-reviewer @username
```

---

## PR Best Practices

### Title Format
```
type(scope): description

Examples:
- feat(auth): add OAuth2 support
- fix(api): resolve timeout issue
- docs(readme): update installation guide
- refactor(db): optimize queries
```

### Body Template
```markdown
## Summary
Brief description of changes

## Motivation
Why this change is needed

## Changes
- Change 1
- Change 2

## Testing
How to test these changes

## Screenshots
If applicable

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Reviewed by team
```

---

## Esegui Azione

Basandoti sull'azione richiesta ($1), esegui i comandi appropriati.

Per `create`: chiedi titolo e descrizione se non forniti.
Per `merge`: chiedi conferma prima di procedere.
Per `review`: mostra diff e chiedi feedback.
