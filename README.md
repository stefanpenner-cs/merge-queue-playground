# Minimal Merge Queue Playground

This repository is intentionally tiny. It gives you one required GitHub check that runs on both pull requests and merge queue merge groups, plus a helper script that creates a few demo branches so you can observe:

- merge queue without batching
- merge queue with batching
- a batched merge group that fails even though each PR passes by itself

## What the check does

Every PR adds one file under `queue/` whose contents are a single token.

The validation script passes when all tokens are unique.

That means:

- PR A adding `alpha` passes
- PR B adding `beta` passes
- PR C adding `collision` passes
- PR D adding `collision` also passes on its own
- a merge group containing both collision PRs fails

That last case is the interesting one for batching.

## Local setup

Initialize the repo and make the first commit:

```bash
git init -b main
git add .
git commit -m "Initial merge queue playground"
```

Create the demo branches:

```bash
./scripts/create-demo-branches.sh
```

This gives you four local branches:

- `demo/ok-1`
- `demo/ok-2`
- `demo/collision-1`
- `demo/collision-2`

## GitHub setup

1. Create an empty GitHub repository and push `main`.
2. Open the repository settings and create a branch ruleset or branch protection rule for `main`.
3. Turn on these protections:
   - require a pull request before merging
   - require status checks to pass before merging
   - require merge queue
4. Make sure the required status check includes the workflow job `queue-check`.
5. Keep "require branch to be up to date" off when using merge queue.

The workflow in [`.github/workflows/queue-check.yml`](/Users/stef/src/stefanpenner/-mq/.github/workflows/queue-check.yml) already runs for both `pull_request` and `merge_group`.

## Scenario 1: No batching

Configure the merge queue limits on `main` so only one PR is processed at a time:

- minimum group size: 1
- maximum group size: 1

Then:

1. Push `demo/ok-1` and `demo/ok-2`
2. Open PRs for both against `main`
3. Add both PRs to the merge queue

Expected result:

- GitHub creates one merge group per PR
- both groups pass
- both PRs merge serially

## Scenario 2: Batching with a clean batch

Configure the merge queue to allow batching:

- minimum group size: 2
- maximum group size: 2

Queue the same two PRs:

- `demo/ok-1`
- `demo/ok-2`

Expected result:

- GitHub can evaluate them together in one merge group
- the batch passes
- both PRs merge together

## Scenario 3: Batching with a hidden conflict

Keep batching enabled and queue:

- `demo/collision-1`
- `demo/collision-2`

Expected result:

- each PR is green by itself
- the combined merge group fails the `queue-check`
- GitHub removes or reshuffles the failing batch depending on queue behavior

This is the fastest way to see why `merge_group` checks matter.

## Helpful commands

Run the check locally:

```bash
./scripts/validate-queue.sh
```

See the tokens currently in the repo:

```bash
find queue -type f -maxdepth 1 -print -exec cat {} \\;
```
