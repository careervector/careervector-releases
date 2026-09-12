# CareerVector releases

Distribution artifacts for CareerVector and CareerVector TUI.

| Product | Package | Launch |
| --- | --- | --- |
| CareerVector desktop | `careervector` | Desktop application menu or Dock |
| CareerVector TUI | `careervector-tui` | `careervector` in a terminal |

The products install together. The desktop application owns its private Tauri
executable; the TUI owns the command on PATH. Both display the name CareerVector.

This repository holds release metadata and verified artifacts. It does not
mirror the application source repository. Each release declares its supported
platforms, exact source revision, checksums, validation evidence and applicable
license notices. Required corresponding source and relinking materials accompany
the artifacts that need them.

No installable release has been published here yet. Installation instructions
will be added with the first verified release.
