---
name: Bug report
about: Report a reproducible bug to help us improve GetXify
title: '[Bug] '
labels: 'bug, needs triage'
assignees: aniketkhote
---

<!--
STOP — please read before filing.

• This tracker is for confirmed bugs in GetXify only.
• For usage questions, use GitHub Discussions or Stack Overflow (tag: getxify).
• Issues that skip the template or lack a reproduction will be closed without comment.
-->

## Description

<!-- A clear and concise description of what the bug is. -->

## Reproduction

<!--
Provide the *minimal* code that reproduces the problem.
Remove everything that is not necessary to trigger the bug.
Issues without a minimal reproduction will be closed.
-->

```dart
import 'package:flutter/material.dart';
import 'package:getxify/getxify.dart';

void main() => runApp(GetMaterialApp(home: BugPage()));

class BugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // minimal reproduction here
    return Scaffold();
  }
}
```

## Steps to reproduce

1. 
2. 
3. 

## Expected behavior

<!-- What did you expect to happen? -->

## Actual behavior

<!-- What actually happened? Include stack traces or error messages if applicable. -->

<details>
<summary>Stack trace / error output (if any)</summary>

```
paste here
```

</details>

## Environment

| Field              | Value |
|--------------------|-------|
| GetXify version    | <!-- e.g. 4.0.0 --> |
| Flutter version    | <!-- e.g. 3.44.6 — run `flutter --version` --> |
| Dart version       | <!-- e.g. 3.12.2 --> |
| Platform/device    | <!-- e.g. Android 14, iOS 17, Chrome 125, macOS 14 --> |
| IDE                | <!-- e.g. VS Code 1.90, Android Studio Hedgehog --> |

## Additional context

<!-- Screenshots, related issues, or anything else that might help. -->
