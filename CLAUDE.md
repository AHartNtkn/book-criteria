# Fiction Pipeline

## Running the pipeline

```bash
nohup ./run.sh > state/pipeline-stdout.log 2>&1 &
```

Monitor with `tail -f state/pipeline-stdout.log`.

Do NOT run `./run.sh` inside Claude Code's background task system (`run_in_background`). The output gets captured into a task file and is not observable from the user's terminal.

## Stopping the pipeline

```bash
kill $(ps aux | grep '[r]un.sh' | awk '{print $2}' | head -1)
```

The `kill 0` trap in run.sh will clean up all child processes automatically.

## Restarting after a crash

1. Clean up failed status files from the interrupted round:
   ```bash
   find state/auditor-results/ -name '*.status' -exec grep -l -v '^OK$' {} \; -exec rm {} \;
   ```
2. Start the pipeline. It resumes from where it left off — completed audit targets are skipped, OK auditors within an interrupted round are reused.

## Pipeline state rules

- **Never manually edit `state/progress.json`.** The pipeline manages its own state. Manually changing `refinement_round` or `status` creates inconsistencies where the audit round directories and the progress state disagree, causing the pipeline to audit at one round number and fix at another.
- **To reset a round**, delete the round directory (`rm -rf state/auditor-results/TARGET/round-N`), delete any incomplete consolidation artifacts (`consolidated-batch-*.md`, `consolidated-feedback.md`), and clean failed statuses. The pipeline will detect the missing round and re-run it. Do not touch progress.json.
- **Kill the pipeline before cleaning state.** If the pipeline is running when you delete directories, it may recreate them immediately. Verify with `ps aux | grep '[r]un.sh'` that all processes are dead before modifying state.
- **Never start the pipeline without checking the log immediately.** Every restart must be followed by reading the first 10-20 lines of the log to verify it resumed from the correct point. Do not launch and walk away.
