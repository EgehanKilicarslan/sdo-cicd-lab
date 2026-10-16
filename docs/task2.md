# Task 2 — The Unprotected Docker Build

**Estimated time:** 20 minutes  
[← Task 1](task1.md) · [Lab Home](../README.md) · [Next: Task 3 →](task3.md)

**Need help?** Jump to the expandable hints below. Open one at a time.

## Mission

The C program now passes its functional test. The repository also contains a `docker-build` job that builds a Docker image using GitHub Actions.

But two things remain unproven:

1. **Dependency:** Will Docker build even when the functional test fails?
2. **Runtime:** Does an image that builds successfully actually start and run the application?

Your mission is to investigate both problems and make the pipeline more reliable.

### Part A — Protect the build

Inspect the two jobs in `.github/workflows/ci.yml`.

Make `docker-build` depend on a successful `test` job.

**Prove your change:** Temporarily make the functional test fail, commit and push your changes, and inspect the Actions run.

The Docker job should be **skipped**, not executed.

Restore the correct functional test afterward.

### Part B — Test the container

The Docker image is built using the same Docker Buildx actions introduced in the lecture.

However, building an image successfully does not prove that the container can actually start.

Extend the existing `docker-build` job to:

1. Start a container from the image tagged `expo:1.0`.
2. Pass base `2` and exponent `10` as arguments.
3. Capture the application's output.
4. Verify that the output is exactly `2 ^ 10 = 1024`.

If the container fails to start, investigate the Dockerfile and the error message before changing anything.

## Evidence to collect

- When the functional test fails, is `docker-build` skipped?
- Does the Docker image build step succeed?
- Does the container start successfully?
- What output does the container produce?
- If the container cannot start, which executable path does Docker attempt to use?
- Where is the executable actually located in the final image?

## Reference desk

### A. Job dependencies

GitHub Actions jobs run independently unless a dependency is declared.

For example, this unrelated job waits for another job to succeed:

```yaml
jobs:
  publish:
    needs: verify
    runs-on: ubuntu-latest
```

Use the actual job IDs from your workflow. A display name is not necessarily a job ID.

### B. Building images with Docker Buildx

In this lab, GitHub Actions uses dedicated Docker actions to build the image:

- `docker/setup-buildx-action@v3` prepares Docker Buildx.
- `docker/build-push-action@v6` builds the image.
- `context` specifies the Docker build context.
- `tags` assigns an image name and tag.
- `load: true` makes the built image available to the runner's Docker Engine.

The image build is already configured for you.

**You do not need to recreate the Docker build step.**

Your challenge is to determine what happens after the image is built.

### C. Running a Docker container

The general command structure is:

```text
docker run --rm IMAGE_NAME:TAG ARG1 ARG2
```

- `--rm` removes the container after execution.
- `IMAGE_NAME:TAG` identifies the image to run.
- `ARG1` and `ARG2` are arguments passed to the container's executable.

Use the workflow and the application source code to determine the correct values.

### D. Read a multi-stage Dockerfile

A Dockerfile can use multiple stages.

The final stage determines which files are available inside the running container.

For example:

```dockerfile
COPY --from=build /build/tool /usr/local/bin/tool
ENTRYPOINT ["/usr/local/bin/tool"]
```

In this unrelated example, the executable is copied to `/usr/local/bin/tool`, and the entrypoint uses the same location.

**The `ENTRYPOINT` path must refer to an executable that exists inside the final image.**

### E. Verify application output

A container returning exit code `0` is useful, but it does not prove that the application produced the expected answer.

Reuse the Bash output-capture and comparison technique from [Task 1](task1.md).

The CI step should fail if the actual output differs from the expected output.

## 🧩 Stuck? Open a hint

<details>
<summary>Hint 1 — The Docker job still runs when the test is red</summary>

Look for the job-level `needs:` property.

It belongs directly under the `docker-build` job, not inside its `steps` section.

</details>

<details>
<summary>Hint 2 — The Docker build succeeds, but the container fails</summary>

A successful image build does not guarantee a valid runtime configuration.

Compare the final-stage `COPY` destination with the `ENTRYPOINT` path in the Dockerfile.

</details>

<details>
<summary>Hint 3 — Which executable path should Docker use?</summary>

Follow the compiled executable through the Dockerfile.

Find where the final stage copies it, then compare that destination with the `ENTRYPOINT`.

The paths must match exactly.

</details>

<details>
<summary>Hint 4 — How do I test the container's output?</summary>

Use the same approach as Task 1:

1. Execute the application.
2. Capture its standard output using `$(...)`.
3. Print the observed output.
4. Compare it with the expected string using `test`.

This time, the application is executed through `docker run` rather than directly as `./expo`.

</details>

## Completion criteria

- [ ] The `docker-build` job depends on the `test` job.
- [ ] A deliberately failing functional test causes the Docker job to be skipped.
- [ ] The existing Docker Buildx configuration remains functional.
- [ ] The Docker image builds successfully.
- [ ] The container starts and executes the application.
- [ ] The actual container output is checked against `2 ^ 10 = 1024`.
- [ ] The underlying runtime configuration problem is identified and corrected.
- [ ] The correct functional test is restored and the workflow passes.

---

[← Task 1](task1.md) · [Lab Home](../README.md) · [Next: Task 3 — Kubernetes Investigation →](task3.md)
