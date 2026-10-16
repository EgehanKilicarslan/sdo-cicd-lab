# Task 3 — Kubernetes Investigation

**Estimated time:** 20 minutes  
[← Task 2](task2.md) · [Lab Home](../README.md) · [Next: Bonus →](bonus.md)

**Need help?** Jump to the expandable hints below. Open one at a time.

## Mission

Your C application now passes its functional test, and its Docker image can run successfully.

The next challenge is to execute that same image as a **Kubernetes Job** using Minikube inside GitHub Actions.

Your repository already contains a Kubernetes manifest named `Job.yaml`, but the workflow does not yet execute it.

Extend the existing `docker-build` job to:

1. Start a temporary Minikube cluster.
2. Make the previously built Docker image available inside Minikube.
3. Create the Kubernetes Job defined in `Job.yaml`.
4. Wait for the Job to complete successfully.
5. Inspect the application's output and verify that it equals `2 ^ 10 = 1024`.

**Important:** There may be a configuration problem preventing the Kubernetes Job from completing.

Do not immediately change the manifest. First, investigate the failure and collect evidence.

## Evidence to collect

Before making changes, inspect `.github/workflows/ci.yml`, `Dockerfile`, and `Job.yaml`.

Answer the following questions:

- What is the Kubernetes Job's name?
- Which Docker image name and tag does the workflow build?
- Which image name and tag does `Job.yaml` request?
- What arguments are passed to the application?
- Does Kubernetes successfully create the Job?
- Does the Job complete, fail, or remain pending?
- What do the Pod status and events reveal?
- Does the application produce the expected output?

Remember that **a Kubernetes Job being created does not mean it completed successfully**.

## Reference desk

### A. Start Minikube in GitHub Actions

GitHub Actions can use an existing action to prepare a local Kubernetes environment.

For example:

```yaml
- name: Prepare local Kubernetes
  uses: medyagh/setup-minikube@latest
```

This action starts Minikube on the GitHub Actions runner.

You can then interact with the cluster using `kubectl`.

### B. Make the Docker image available to Kubernetes

Your workflow builds the Docker image using `docker/build-push-action@v6`.

Its `load: true` configuration makes the image available to Docker on the GitHub Actions runner.

However, **Minikube has its own container image environment**.

An image available to Docker on the runner is not necessarily available to Kubernetes.

Use the following command structure to transfer an existing image into Minikube:

```text
minikube image load IMAGE_NAME:TAG
```

The image name and tag must match the image built earlier in the workflow.

You do not need to push the image to Docker Hub or GitHub Container Registry.

### C. Kubernetes command reference

| Command                                                         | Purpose                                               |
| --------------------------------------------------------------- | ----------------------------------------------------- |
| `kubectl apply -f FILE`                                         | Create or update Kubernetes resources from a manifest |
| `kubectl get jobs,pods`                                         | Inspect Jobs and Pods                                 |
| `kubectl describe job NAME`                                     | Inspect Job status and events                         |
| `kubectl describe pod NAME`                                     | Inspect Pod status and events                         |
| `kubectl wait --for=condition=complete job/NAME --timeout=120s` | Wait for a Job to finish successfully                 |
| `kubectl logs job/NAME`                                         | Read the application's output                         |

These are command patterns, not a complete workflow.

Determine the correct filenames, resource names, image tags, and execution order from your repository.

### D. Why everything must run in the same job

GitHub Actions jobs normally execute on separate runners.

This means that a Docker image created in one job is not automatically available in another.

For this lab, keep the following operations inside the existing `docker-build` job:

1. Build the Docker image.
2. Verify the container's runtime behavior.
3. Start Minikube.
4. Load the image into Minikube.
5. Run and verify the Kubernetes Job.

The `docker-build` job should still depend on the successful completion of the `test` job from Task 1.

### E. Investigate Kubernetes failures

When a Kubernetes Job does not complete, the application itself may not be the problem.

For example, a Pod might be unable to start because its requested image is unavailable.

Start by inspecting the Job and Pod status.

If the container never starts, Pod events are often more useful than application logs.

You can add a diagnostic step that runs when an earlier step fails:

```yaml
- name: Inspect cluster after failure
  if: failure()
  run: kubectl get jobs,pods
```

You may extend this step with additional `kubectl describe` commands.

For optional diagnostic commands, `|| true` can prevent an unavailable resource from causing the diagnostic step to fail before other information is collected.

### F. Understand image pull behavior

Inspect the following field in `Job.yaml`:

```yaml
imagePullPolicy: Never
```

This tells Kubernetes not to download the image from a remote registry.

The image must already exist in Minikube's image store.

If the image name or tag does not match what was loaded into Minikube, the container cannot start.

Compare the image references carefully before changing anything.

### G. Verify the actual result

A completed Kubernetes Job is an important signal, but this lab requires more than successful execution.

Your workflow must also inspect the application's output.

Use the same output-capture and comparison approach from Tasks 1 and 2.

The workflow should fail if the application does not print:

```text
2 ^ 10 = 1024
```

## 🧩 Stuck? Open a hint

<details>
<summary>Hint 1 — The Kubernetes Job never completes</summary>

Start by inspecting the Jobs and Pods in the cluster.

Look at the Pod status and events before assuming the application has crashed.

If there are no application logs, the container may never have started.

</details>

<details>
<summary>Hint 2 — The Pod reports an image-related problem</summary>

Compare three places:

1. The image name and tag produced by the Docker Buildx step.
2. The image name and tag passed to `minikube image load`.
3. The image name and tag requested in `Job.yaml`.

All three must refer to the same image.

Remember that `imagePullPolicy: Never` prevents Kubernetes from downloading a missing image.

</details>

<details>
<summary>Hint 3 — The image exists on the runner, but Kubernetes cannot find it</summary>

The Docker Buildx action uses `load: true` to load the image into the runner's Docker Engine.

That does not automatically import it into Minikube.

Check whether the workflow includes an image-loading step **after Minikube starts** and **before the Kubernetes Job is created**.

</details>

<details>
<summary>Hint 4 — My diagnostic commands never execute</summary>

GitHub Actions normally skips later ordinary steps after a failure.

Add a separate diagnostic step using:

```yaml
if: failure()
```

Place it after the Kubernetes execution steps.

Use `kubectl get` and `kubectl describe` to collect information about the failed Job and its Pods.

</details>

<details>
<summary>Hint 5 — The Kubernetes Job completes, but how do I verify the output?</summary>

Use `kubectl logs` to retrieve the application's output from the completed Job.

Capture the result in a shell variable, print it, and compare it with the expected string using `test`.

This is the same verification technique you used in Tasks 1 and 2, but the application now runs inside Kubernetes.

</details>

## Completion criteria

- [ ] Minikube starts successfully inside the existing `docker-build` job.
- [ ] The Docker Buildx image is loaded into Minikube.
- [ ] The Kubernetes manifest is applied successfully.
- [ ] The Kubernetes Job completes successfully.
- [ ] The configuration mismatch is identified and corrected.
- [ ] The application's output is verified against `2 ^ 10 = 1024`.
- [ ] Useful Kubernetes diagnostics are available when execution fails.
- [ ] The complete GitHub Actions workflow passes without publishing or deploying the image to an external environment.

---

[← Task 2](task2.md) · [Lab Home](../README.md) · [Next: Bonus — Jenkins Pipeline Challenge →](bonus.md)
