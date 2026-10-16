# Task 3 — Kubernetes Investigation

**Estimated time:** 20 minutes  
[← Task 2](task2.md) · [Lab Home](../README.md) · [Next: Bonus →](bonus.md)

**Need help?** [Jump to the expandable hints](#-stuck-open-a-hint-click-to-expand). Open one at a time.

## Mission

Your C application now passes its test and runs inside Docker. Next, execute the same image as a **Kubernetes Job** on Minikube, from GitHub Actions.

Extend the **existing `docker-build` job** to:

1. Start a local Kubernetes cluster.
2. Make the image built earlier in that job available to the cluster.
3. Create the Job described by `Job.yaml`.
4. Wait for the Job to finish.
5. Read the application's output and verify `2 ^ 10 = 1024`.

There may be a mismatch in the repository's configuration. **Use the failure to identify it.**

## Evidence to collect

Inspect `Job.yaml`, `Dockerfile`, and `.github/workflows/ci.yml`. Find the answers to these questions **before editing the manifest**:

- What is the Kubernetes Job's `metadata.name`?
- What image name and tag does `Job.yaml` request?
- What image name and tag does the Docker job build?
- What do the container arguments mean?
- If the Job does not complete, is the Pod pending, unable to start, or running but failing?

The Job's status and Pod **Events** are often more useful than application logs when the container never started.

## Reference desk

### A. Start Minikube in a GitHub Actions step

A GitHub Action can prepare a tool for later steps in the same job:

```yaml
- name: Prepare local Kubernetes
  uses: medyagh/setup-minikube@latest
```

### B. Command reference

| Command | Purpose |
| --- | --- |
| `minikube image load IMAGE:TAG` | Import a locally built image into Minikube |
| `kubectl apply -f FILE` | Create or update resources from a manifest |
| `kubectl get jobs,pods` | Show Jobs and Pods |
| `kubectl describe job NAME` | Inspect a Job and its events |
| `kubectl describe pod NAME` | Inspect a Pod's status and events |
| `kubectl wait --for=condition=complete job/NAME --timeout=120s` | Wait for successful Job completion |
| `kubectl logs job/NAME` | Read the output of the Job's Pod |

The commands above are **patterns**, not a ready-to-paste workflow. Work out the correct arguments and order from the files in your repository.

### C. Why the steps must stay in one job

GitHub Actions jobs normally run on separate virtual machines. A Docker image built in one job is **not automatically available** in another. Add Minikube and Kubernetes steps after Docker build and Docker runtime verification, inside the same `docker-build` job.

### D. Capture diagnostics even after failure

A step that fails normally stops later ordinary steps. For investigation, you can add a diagnostic step that runs on failure:

```yaml
- name: Inspect cluster after failure
  if: failure()
  run: kubectl get jobs,pods
```

You can extend this with `kubectl describe` when the Pod does not start. For optional diagnostic commands, `|| true` can prevent the diagnostic step itself from hiding the original error.

### E. Image pull behavior

`imagePullPolicy: Never` tells Kubernetes not to fetch the image from a remote registry. If the requested image is absent from the Minikube image store, the Pod cannot start. Compare **both** the name and tag.

## 🧩 Stuck? Open a hint (click to expand)

<details>
<summary>Hint 1 — The Job never completes</summary>

Start by listing the Pods and inspecting the relevant Pod's events. If no application logs exist, the container may never have started.

</details>

<details>
<summary>Hint 2 — The Pod reports an image-related problem</summary>

Compare the image used by `docker build`, the image passed to `minikube image load`, and the image requested in `Job.yaml`. They must refer to the same image and tag.

</details>

<details>
<summary>Hint 3 — Your diagnostic step doesn't run</summary>

Use `if: failure()` on a **separate step** after the Kubernetes commands. That way the original failing step is still visible, and diagnostics can run afterward.

</details>

## Completion criteria

- [ ] Minikube starts inside the Docker job.
- [ ] The built image is loaded into Minikube.
- [ ] The manifest's Job is created and completes.
- [ ] The actual Kubernetes application output is verified.
- [ ] The configuration mismatch is identified and corrected.
- [ ] Useful diagnostics appear when the Kubernetes run fails.

---

[← Task 2](task2.md) · [Lab Home](../README.md) · [Next: Bonus — Jenkins Pipeline Challenge →](bonus.md)
