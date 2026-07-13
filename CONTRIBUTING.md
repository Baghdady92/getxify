# Contributing to GetXify

Thanks for taking the time to contribute. Here's everything you need to get started.

## Table of contents

- [Code of conduct](#code-of-conduct)
- [Reporting bugs](#reporting-bugs)
- [Requesting features](#requesting-features)
- [Development setup](#development-setup)
- [Submitting a pull request](#submitting-a-pull-request)
- [Style guide](#style-guide)
- [Commit messages](#commit-messages)

---

## Code of conduct

Be respectful. Harassment, personal attacks, or discriminatory language will not be tolerated.

---

## Reporting bugs

1. Search [existing issues](https://github.com/Aniketkhote/getxify/issues) before opening a new one.
2. Use the **Bug report** template and fill in every section — issues without a minimal reproduction will be closed.

---

## Requesting features

1. Check [existing issues and discussions](https://github.com/Aniketkhote/getxify/discussions) first.
2. Use the **Feature request** template.
3. Keep requests focused on GetXify's core scope: state management, routing, and dependency injection.

---

## Development setup

**Prerequisites:** Flutter SDK ≥ 3.44.2, Dart SDK ≥ 3.12.2

```bash
# Clone the repo
git clone https://github.com/Aniketkhote/getxify.git
cd getxify

# Fetch dependencies
flutter pub get

# Run the full test suite
flutter test

# Run a single test file
flutter test test/state_manager_test.dart

# Check formatting and analysis
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
```

The `example/` directory contains a runnable Flutter app:

```bash
cd example
flutter pub get
flutter run
```

---

## Submitting a pull request

1. **Fork** the repository and create a branch from `master`.
2. Keep the branch focused — one concern per PR.
3. **Write or update tests** for every behavior change. The CI will fail without them.
4. Run `flutter analyze` and `dart format` locally before pushing.
5. Update `CHANGELOG.md` under `## Unreleased` (add the section if it doesn't exist).
6. Open the PR against `master` and fill in the pull request template.
7. A maintainer will review within a few days. Please be patient and responsive to feedback.

---

## Style guide

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines.
- All public APIs must have `///` doc comments with at least one sentence and, where useful, a code example.
- Prefer descriptive variable names over abbreviations.
- Keep functions small and focused.

---

## Commit messages

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <short description>

[optional body]

[optional footer: Fixes #123]
```

Common types: `fix`, `feat`, `refactor`, `test`, `docs`, `ci`, `chore`.

Examples:

```
fix(router): prevent duplicate route registration on hot reload
feat(state): add autoPlayOnUpdate to GetAnimatedBuilder
docs(contributing): add development setup instructions
```
