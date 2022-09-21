# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

## What is GodotRx?
GodotRx (short: GDRx) is a full implementation of ReactiveX for the Godot Game Engine 4. The code was originally ported from RxPY (see: https://github.com/ReactiveX/RxPY) as Python shares a lot of similarities with GDScript.

## Installation
You can easily add GDRx to your Godot 4 project:

1. Download this repository as an archive.
2. Navigate to your project root folder.
3. Extract GDRx into your project. The folder should be named '``res://reactivex/``'.
4. Add the singleton script with name 'GDRx' to autoload (``res://reactivex//__gdrxsingleton__.gd``).
5. GDRx should now be ready to use. Try creating a simple Observable using:

```csharp
var obs : Observable = GDRx.ReturnValue(42) \
    subscribe(func(i): print("The answer: " + str(i)))
```
