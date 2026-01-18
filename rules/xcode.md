# Xcode Project Rules

## Files in Project Directory Are Auto-Detected

**When creating files inside an Xcode project's source directory, Xcode automatically detects them.**

You do NOT need to manually "Add Files to Project" if:
- The file is created inside an existing group/folder that's already in the project
- The folder structure already exists in Xcode's project navigator

### Example

```
ios/MyApp/MyApp/
├── ContentView.swift        ← Already in project
├── Services/                ← Need to create folder first
│   └── NewService.swift     ← Auto-detected if Services/ exists as group
└── Config/                  ← Need to create folder first
    └── Secrets.swift        ← Auto-detected if Config/ exists as group
```

### When Manual "Add Files" IS Required

1. **New top-level folders** — If creating a new folder that doesn't exist as a group in Xcode
2. **Files outside the project directory** — Files not within the `.xcodeproj`'s source tree
3. **Reference files** — Files you want to reference but not copy

### Best Practice for Agents

When creating Swift files for iOS/macOS projects:
1. Create the file in the correct directory within the Xcode project structure
2. **Do not** ask the user to manually add files—they're likely already visible
3. If unsure, check Xcode's project navigator to confirm

### Creating New Folder Groups

If you need to create a new organizational folder:
1. Create the folder in the filesystem
2. In Xcode: Right-click parent → "Add Files to [Project]" → Select the folder
3. Subsequent files in that folder will be auto-detected

---

*Last updated: 2025-01-18*
