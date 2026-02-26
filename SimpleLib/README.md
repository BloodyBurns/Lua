## Setup

```lua
local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/BloodyBurns/Lua/refs/heads/main/SimpleLib/init.lua'))()
library:SetTitle('SimpleLib')
```

**Toggle UI Keybind ⇒** `Left Alt`



## API

`library:Destroy()` ⇒ Clears signals and destroys the UI (single-instance)

### SetTitle

```lua
library:SetTitle(title: string)
```

Updates the window header.

---

### CreateGroup

```lua
local group = library:CreateGroup(name: string)
```

* Maximum: **6 groups**
* Returns methods.

---

## Methods

### Button

```lua
group:CreateButton(label: string, callback: function, ...)
```

**Example**

```lua
group:CreateButton('hello', print, 'Hello', 123)
```

---

### Text

```lua
group:CreateText(label: string)
```

---

### Input

```lua
group:CreateInput(label: string, callback: function)
```

```lua
group:CreateInput('Set Title', function(text, textbox)
	library:SetTitle(text)
end)
```

---

### Toggle

```lua
group:CreateToggle(label: string, defaultState: boolean, callback: function)
```

```lua
group:CreateToggle('Enable Feature', false, function(state)
	print(state)
end)
```

---

### Slider

```lua
group:CreateSlider(label: string, config: table, callback: function)
```

Config:

| Field | Type    | Description             |
| ----- | ------- | ----------------------- |
| min   | number  | Minimum value           |
| max   | number  | Maximum value           |
| value | number  | Initial value           |
| p     | number? | Decimal precision (0–4) |

Example:

```lua
group:CreateSlider('Speed', {
	min = 0,
	max = 100,
	value = 50,
	p = 0
}, function(value, absoluteValue)
	print(value, absoluteValue)
end)
```

---

## Example

```lua
library:SetTitle('Iv Demo')

local g = library:CreateGroup('Main')

g:CreateText('Status: Ready')

g:CreateButton('Hello', print, 'Hello World')

g:CreateToggle('God Mode', false, function(state)
	local enabled = true
	print('God Mode:', enabled)
end)

g:CreateInput('print', function(text)
	print(text)
end)

g:CreateSlider('WalkSpeed', {
	min = 0,
	max = 200,
	value = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
}, function(v)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)

```
