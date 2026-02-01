# PipsUUF
Adds noticeable pips to the empowered player castbar of Unhalted Unit Frames.

I was having a difficult time seeing the default pips on the default blue castbar 
in UUF, so I created this addon to make them more visible.  This was done by increasing
the height of the pip and changing its color to white.  I also slightly increased the 
width of the last pip to make it more noticeable.

In the spirit of keeping this addon simple and lightweight, there is no UI for 
customization.  However, one can edit the values at the top the PipsUUF.lua file, 
as illustrated below.

```
local PIP_WIDTH = 2           -- Width of each pip
local PIP_LAST_WIDTH = 3      -- Width of the last pip
local PIP_COLOR = { 1, 1, 1 } -- Color of each pip
local PIP_ALPHA = 1           -- Alpha of each pip
```

Coded with 100% **VIBE**
