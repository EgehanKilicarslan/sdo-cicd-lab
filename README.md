# CI/CD Lab — The Green Build That Lies

Welcome, investigators! Your repository contains a small C application and a CI pipeline. The initial build may look healthy, but **a successful build is not proof that the software works**.

Your mission is to gather evidence, uncover problems at different layers, and turn the pipeline into a reliable set of checks.

**Time:** approximately 60 minutes, plus an optional Jenkins bonus.  
**Tools:** GitHub, GitHub Actions, C, Docker, Minikube, Kubernetes; Jenkins for the bonus.  
**No local installation required:** work in the repository and inspect GitHub Actions logs.

## Mission map

| Mission | Investigation | Suggested time |
| --- | --- | --- |
| [Task 1 — The Green Build That Lies](docs/task1.md) | Does compilation prove the C program is correct? | 15 min |
| [Task 2 — The Unprotected Docker Build](docs/task2.md) | Are jobs ordered correctly, and can the image actually run? | 20 min |
| [Task 3 — Kubernetes Investigation](docs/task3.md) | Why won't a Kubernetes Job finish? | 20 min |
| [Bonus — Jenkins Pipeline Challenge](docs/bonus.md) | Can you reproduce the checks in a different CI system? | Optional |

## Case files

| File | What it controls |
| --- | --- |
| `expo.c` | The program's behavior |
| `.github/workflows/ci.yml` | GitHub Actions jobs and steps |
| `Dockerfile` | How the container image is assembled and launched |
| `Job.yaml` | The Kubernetes Job configuration |
| `Jenkinsfile` | The bonus Jenkins pipeline |

## Rules of investigation

1. **Observe first.** Read the relevant file and the CI log before changing code.
2. **Form a hypothesis.** What should happen? What actually happens?
3. **Change one cause at a time.** Avoid editing several unrelated files to hide a failure.
4. **Verify the result.** A green check matters only when the intended behavior was tested.
5. **Use the references and expandable hints.** They explain the tools without handing you a complete solution.

### Working with GitHub Actions

Open your repository's **Actions** tab, select **C Application CI**, open the latest run, then expand the relevant job and step. After editing files, commit and push to `main` to trigger a new run. If a step fails, read its **first useful error message** before retrying.

A failed run is evidence, not the end of the investigation.

**[Begin the investigation → Task 1](docs/task1.md)**

## Need a hint?

Every task page has a **🧩 Stuck? Open a hint** section with clickable, progressively more specific hints. Start with the mission, try the task, and open a hint only when you get stuck.
