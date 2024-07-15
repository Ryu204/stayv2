# Graphics
## Winding order

Model's triangles winding order is **counter clockwise**, in left-handed coordinate:

```
y+
^
|       z+
|      / 
|     /
|    /
|   /
|  /
| /
|____________________________> x+
```

## Camera

The camera looks at its local `z-` axis. To be more specific:

Initially, the camera's coordinate looks like this:

```
y+  z+
|  /
| /
|_____x+
```

And its visible area has this coordinate:

```
    y+  z-
    |  /
    | /
    |_____x-
   /
  /
 /
z+
```

`z+` is the visible part.

## Color

Currently, this library supports 3 color mode: 

* true color, checked by `$COLORTERM` environment variable, the most accurate one
* 16 ansi colors, fallback mode, supports 8 basic ansi colors and their bright versions
* none, fallback mode, no color but use ascii characters to fake luminance