**IvKit API Documentation**

---

## 1. Introduction

`IvKit` is a global utility framework. It consolidates commonly used services, utility functions, enhanced type checking, player-management caches, signal handling, file system abstractions, logging helpers, and timing utilities into a single global table: `getgenv().IvKit`.

- **Namespace**: `IvKit` (in `getgenv()`)

---

## 2. Initialization

```lua
--> Prevent reinitialization
if not getgenv().IvKit then
    loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/IvKit/init.lua))()
end

--> Reassigns the active function’s environment reference to IvKit, rerouting all globals through IvKit's table proxy for isolated lexical binding
setfenv(1, IvKit) --> always have this to use IvKit

--> Load script here
--> e.g., loadstring(...)()
```

On first execution, `IvKit` caches services, sets up helpers, and prints load time:

```lua
print('IvKit load time:', timeFmt(os.clock() - init))
```

---

## 3. Services & Globals

| Property             | Description                        |
| -------------------- | ---------------------------------- |
| HttpGet(url)         | Shorthand for `game:HttpGet(url)`. |
| plr                  | Local player shortcut.             |
| plrs                 | Players service.                   |
| CoreGui              | CoreGui service.                   |
| Lighting             | Lighting service.                  |
| RunService           | RunService.                        |
| HttpService          | HttpService.                       |
| TweenService         | TweenService.                      |
| SoundService         | SoundService.                      |
| InputService         | User input service.                |
| TeleportService      | TeleportService.                   |
| TextChatService      | TextChat service.                  |
| CollectionService    | Collection service.                |
| ReplicatedStorage    | Replicated storage.                |
| MarketplaceService   | Marketplace service.               |

---

## 4. Player Management

### 4.1 Cache

Internally maintains a `players` table keyed by name for O(1) lookup.

### 4.2 Functions


| Function                    | Signature                                  | Description                                                                  |                                                                  |
| --------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| GetPlayers(exclude)       | (exclude: string)                          | {string}) -> {Players}                                                       | Returns all current players, optionally excluding given name(s). |
| GetPlayer(query, caller?) | (query: string, caller?: Player) -> Player | Flexible lookup by name prefix, special keywords ('me', 'random', 'others'). |                                                                  |

---

## 5. Type Checking

| Function                     | Description                                                                                           |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| type(ref, expected?, alt?)   | Returns **true** if `ref` matches the expected type(s). If no type is given, returns the type string. |
| typeof(ref, expected?, alt?) | Same as `type`, but uses Luau's `typeof`. Returns **true** or the actual type string.                 |
| isMatch(ref, v1, v2, v3)     | Returns **true** if `ref` matches any of the provided values.                                         |

## 6. Table Utilities

| Function     | Signature                                                | Description                                                                          |
| ------------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| table.size   | (tbl: table) → number                                    | Returns `#tbl` for arrays, or counts keys if it's a dictionary.                      |
| table.purge  | (tbl: table) → nil                                       | Clears all elements from the table (array or dictionary).                            |
| table.sample | (tbl: table, n?: number, noRep?: boolean) → any or {any} | Returns one random value, or `n` samples (optionally without repeats).               |
| table.flat   | (tbl: table, deep?: boolean) → {any}                     | Returns a flattened array of values. If `deep` is true, recurses into nested tables. |
| table.invoke | (tbl: {any}, callback: function)                         | Calls `callback(value)` on each element in the array.                                |


**Recursive flattening logic (deep mode)**:

When `deep` is true, `table.flat(tbl, true)` will recursively flatten any nested tables found within both arrays and dictionaries into a single-level array.

Example:

```lua
local result = table.flat({1, {2, 3}, {a = 4, b = {5, 6}}}, true)
--> result = {1, 2, 3, 4, 5, 6}
```

---

## 7. SignalRegistry
Manages RBXScriptConnections with ID-based control, suspension, and conditional listeners.

| Method        | Signature                                               | Description                                                                |
| ------------- | ------------------------------------------------------- | -------------------------------------------------------------------------- |
| connect       | (id, signal, callback, ...extraArgs)                    | Connects a signal and stores it under an ID. Ignores if already connected. |
| disconnect    | (id)                                                    | Disconnects and removes the stored listener for the given ID.              |
| suspend       | (id or RBXScriptConnection)                             | Temporarily disables the listener without disconnecting it.                |
| resume        | (id or RBXScriptConnection)                             | Re-enables a suspended connection.                                         |
| count         | () → number                                             | Returns the number of managed connections.                                 |
| clear         | () → void                                                      | Disconnects and removes all connections.                                   |
| getConnection | (id or RBXScriptConnection) → connectionObject or nil   | Retrieves a stored connection entry by ID or listener.                     |
| untilThen     | (signal, callback, condition, onTimeout?, ...extraArgs) | Connects once and disconnects when condition is met or timeout expires.    |

Usage:

```lua
--> Isolated Signals Manager
local signals = SignalRegistry()

--> Shared Signals Manager
local signals = SignalRegistry('token123')

signals.connect('workspaceListener', workspace.ChildAdded, print)

signals.suspend('workspaceListener') --> suspend by id

signals.resume('workspaceListener') --> resume by id

signals.disconnect('workspaceListener') --> disconnect by id

--> Callback-based condition (runs until it returns true)
signals.untilThen(player.Jumping, function()
	print('Player jumped!')
end, function()
	return player.Humanoid and player.Humanoid.Jump == true
end)

--> Signal-based condition (disconnects when another signal fires)
signals.untilThen(player.Jumping, function()
	print('Player jumped — listener will now stop.')
end, someOtherSignal)

--> Duration-based condition (auto-disconnect after timeout)
signals.untilThen(player.Jumping, function()
	print('Player jumped (but only tracked for 5 seconds).')
end, 5, function()
	print('Timed out after 5 seconds without condition being met.')
end)

--> Cleanup
signals.clear()
```

---

## 8. File System (*fileSys*)

| Function                             | Signature                       | Description                                                                                |
| ------------------------------------ | ------------------------------- | ------------------------------------------------------------------------------------------ |
| save(path, name, data)               | (string, string, string) -> nil | Saves data to path/name if writefile is available.                                         |
| read(path, name)                     | (string, string) -> string      | Reads contents of path/name if supported.                                                  |
| exist(path, method)                  | (string, function) -> boolean   | Checks existence using the provided function (isfile, isfolder, etc).                      |
| loadAsset(path, url, delete?, name?) | see code                        | Downloads or uses cached asset. Returns: getcustomasset path, success flag, and full path. |

---

## 9. Logging (*IvLog*)

Controlled live logging with emojis.

| Log Level      | Signature    | Description         |
| -------------- | ------------ | ------------------- |
| success(...) | ...any | Green check log.    |
| error(...)   | ...any | Red cross log.      |
| warn(...)    | ...any | Yellow warning log. |
| info(...)    | ...any | Info log.           |
| unknown(...) | ...any | Question mark log.  |

Toggle live output with:

```lua
IvLog.live = false      --> disable all logs
IvLog.emojis = false    --> disable emojis
```

---

## 10. Miscellaneous Utilities

| Function            | Signature                                 | Description                                                                            |
| ------------------- | ----------------------------------------- | -------------------------------------------------------------------------------------- |
| randomString(len) | (number) -> string                      | Generates alphanumeric random string.                                                  |
| timeFmt(elapse)   | (number) -> string                      | Formats elapsed seconds into µs/ms/s.                                                  |
| benchmark(fn,...) | (function, ...) -> (...results, number) | Measures execution time of any function call. Returns all results and elapsed seconds. |

**Usage**:

```lua
local result, time = benchmark(function()
    return table.flat({1, {2, 3}}, true)
end)
print('Took:', timeFmt(time))
```
<p align='center'>
  <img src='https://i.pinimg.com/736x/1e/23/41/1e2341a9fd387f550118bafcebb34a24.jpg' width=400/>
</p>
