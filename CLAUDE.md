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
