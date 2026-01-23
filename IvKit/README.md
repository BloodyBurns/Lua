# IvKit API Documentation

---

## 1. Introduction

`IvKit` is a global utility framework exposed via `getgenv().IvKit`.

IvKit is designed to be **setfenv-first** and act as a controlled global runtime.

---

## 2. Initialization

```lua
if not getgenv().IvKit then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/IvKit/init.lua'))()
end

setfenv(1, IvKit)
```

IvKit initializes once, caches services, installs globals, and reports load time via `IvLog`.
 
---

## 3. Services & Globals

### Core

| Property            | Description                |
| ------------------- | -------------------------- |
| HttpGet(url)        | Wrapper for `game:HttpGet` |
| plr                 | `Players.LocalPlayer`      |
| plrs                | Players service            |
| CoreGui             | CoreGui service            |
| Lighting            | Lighting service           |
| RunService          | RunService                 |
| HttpService         | HttpService                |
| TweenService        | TweenService               |
| SoundService        | SoundService               |
| UserInputService    | UserInputService           |
| TeleportService     | TeleportService            |
| TextChatService     | TextChatService            |
| CollectionService   | CollectionService          |
| ReplicatedStorage   | ReplicatedStorage          |
| MarketplaceService  | MarketplaceService         |
| AvatarEditorService | AvatarEditorService        |
| VirtualInputManager | VirtualInputManager        |

---

## 4. Global Utility Functions

| Function                   | Description                                        |
| -------------------------- | -------------------------------------------------- |
| type(v, expected?, alt?)   | Returns true if ref matches the expected type(s). If no type is given, returns the type string.       |
| typeof(v, expected?, alt?) | Same as type, but uses Luau's typeof. Returns true or the actual type string.    |
| isMatch(ref, ...)          | Returns true if `ref` equals any provided value    |
| _pack(...) | Packs varargs into `{n = select('#', ...), ...}` |
| _unpack(tbl) | Unpacks a `_pack` table safely using `tbl.n` |

---

## 5. Player Management

IvKit maintains an internal player cache keyed by name for O(1) lookup.

### Functions

| Function                  | Signature                                    | Description                                                       |
| ------------------------- | -------------------------------------------- | ----------------------------------------------------------------- |
| GetPlayers(...exclude)    | (...string : Player) -> {Player}             | Returns all players excluding names or instances                  |
| GetPlayer(query, caller?) | (string, Player?) -> Player : {Player} : nil | Supports `me`, `random`, `others`, prefix + display/name matching |

### Examples

```lua
--> get all players except local player
local others = GetPlayers(plr)

--> resolve player by prefix
local target = GetPlayer('blo')

--> special keywords
local me = GetPlayer('me')
local randomPlayer = GetPlayer('random')
local everyoneElse = GetPlayer('others')
```

---

## 6. Table Utilities

| Function     | Signature                                                | Description                                                                          |
| ------------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| table.size   | (tbl: table) → number                                    | Returns `#tbl` for arrays, or counts keys if it's a dictionary.                      |
| table.purge  | (tbl: table) → nil                                       | Clears all elements from the table (array or dictionary).                            |
| table.sample | (tbl: table, n?: number, noRep?: boolean) → any or {any} | Returns one random value, or `n` samples (optionally without repeats).               |
| table.flat   | (tbl: table, deep?: boolean) → {any}                     | Returns a flattened array of values. If `deep` is true, recurses into nested tables. |
| table.invoke | (tbl: table, fn: function, self?: any, ...)              | Invokes `fn(value, ...)` for each element; optional self allows colon calls.         |

### Examples

```lua
local t = {1, 2, 3, a = 4}

print(table.size(t)) --> 4

print(table.sample(t)) --> random value
print(table.sample(t, 2, true)) --> two unique samples

local flat = table.flat({1, {2, {3}}}, true)
--> {1, 2, 3}

local obj = {}
table.invoke({1,2,3}, function(self, v)
    print(v)
end, obj)
```

---

## 7. Logging (*IvLog*)

Controlled live logging with emojis.

**IvLog Properties**

| Property     | Type    | Description                          |
| ------------ | ------- | ------------------------------------ |
| live         | boolean | Enable/disable all logging           |
| emojis       | boolean | Toggle emojis in logs                |
| prettyTables | boolean | Multi-line table output when true    |
| maxInline    | number  | Max table length for inline printing |

---

| Log Level      | Signature    | Description         |
| -------------- | ------------ | ------------------- |
| success(...) | ...any | Green check log.    |
| error(...)   | ...any | Red cross log.      |
| warn(...)    | ...any | Yellow warning log. |
| info(...)    | ...any | Info log.           |
| unknown(...) | ...any | Question mark log.  |

```lua
--> Pretty Tables Example
IvLog.prettyTables = true
IvLog.info('Small Table:', {a = 1, b = 2, 'thirdVal'}) 
IvLog.info('Large Table:', {a = 1, b = 2, c = 3, d = 4})

--> Inline Tables Example
IvLog.prettyTables = false
IvLog.info('prettyTables disabled:', {a = 1, b = 2, c = 3, d = 4})
```

```
ℹ️ [IvLog] → Small Table: {a = 1, b = 2, thirdVal}

ℹ️ [IvLog] → Large Table:{
	a = 1,
	b = 2,
	c = 3,
	d = 4
}

ℹ️ [IvLog] → prettyTables disabled: tbl_memory_address
```

---

## 8. SignalRegistry

SignalRegistry manages RBXScriptConnections with IDs, suspension, and automatic cleanup.

```lua
local signals = SignalRegistry()
local shared = SignalRegistry('shared-token')
```

### Methods

| Method                                                       | Description                         |
| ------------------------------------------------------------ | ----------------------------------- |
| connect(id, signal, callback, ...extra)                      | Registers a connection              |
| disconnect(id **or** connection)                                  | Disconnects entry                   |
| suspend(id **or** connection)                                     | Temporarily disables listener       |
| resume(id **or** connection)                                      | Re-enables listener                 |
| count()                                                      | Active connection count             |
| clear()                                                      | Disconnects all                     |
| getConnection(id **or** connection)                               | Resolves registry entry             |
| untilThen(signal, callback, condition, onTimeout?, ...extra) | Auto-disconnects based on condition |

### Examples

```lua
signals.connect('jump', plr.Character.Humanoid.Jumping, function(active)
    if active then print('jumping') end
end)

signals.suspend('jump')
signals.resume('jump')

signals.untilThen(
    workspace.ChildAdded,
    function(child)
        print('added', child.Name)
        return child.Name == 'StopHere'
    end
)
```

### untilThen Behavior

* `condition` may be:

  * function → evaluated after each callback
  * number → timeout in seconds
  * RBXScriptSignal → kills listener when fired
* Returning `true` from `callback` **immediately disconnects**

---

## 9. File System (`IvKit.fs`)

Modern replacement for the old `fileSys`.

### Core Functions

| Function               | Description                   |
| ---------------------- | ----------------------------- |
| normalizePath(path)    | Cleans and normalizes slashes |
| joinPath(...)          | Safe path concatenation       |
| dirName(path)          | Parent directory              |
| exists(path)           | File or folder existence      |
| readFile(path)         | Reads file contents           |
| writeFile(path, data)  | Writes file                   |
| appendFile(path, data) | Appends to file               |
| listFiles(path)        | Lists directory               |
| makeDir(path)          | Recursive mkdir               |
| deleteFile(path)       | Deletes file                  |
| deleteFolder(path)     | Deletes folder                |
| loadFile(path)         | Loads Lua chunk               |
| doFile(path)           | Executes Lua file             |

### Asset Loader

`fs.loadAsset(folder, url, deleteOld?, key?)`

* Uses SHA256 hashing
* Caches assets deterministically
* Supports cleanup via metadata

Old `IvKit.fileSys` is deprecated and removed.

### Asset Loader

```lua
local assetId, ok = fs.loadAsset('IvKit/assets', 'https://example.com/image.png', true, 'icon')
```

### Examples

```lua
local dir = fs.joinPath('IvKit', 'data')
fs.makeDir(dir)

local file = fs.joinPath(dir, 'test.txt')
fs.writeFile(file, 'hello')

IvLog.info(fs.readFile(file))

for x, v in fs.listFiles(dir) do
    IvLog.info(v)
end
```
---

## 10. Timing Utilities

| Function           | Description                        |
| ------------------ | ---------------------------------- |
| benchmark(fn, ...) | Returns all results + elapsed time |
| timeFmt(seconds)   | Formats µs / ms / s                |

---
<p align='center'>
  <img src='https://i.pinimg.com/736x/1e/23/41/1e2341a9fd387f550118bafcebb34a24.jpg' width=400/>
</p>
