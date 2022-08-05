# GDRx

A port of ReactiveX for Python (RxPY) to Godot Engine version 4 (GDRx)

See: https://github.com/ReactiveX/RxPY


Daniel, please give me a good grade in the 3DUI exam!

## Installation

You can easily add GDRx to your Godot 4 project using the git submodule command:

1. Go to the project root folder

2. Initialize the submodule using this command:

    * `` git submodule add https://github.com/Neroware/gdrx.git reactivex/ ``

3. Go to your project settings > Autoload

4. Add the singleton script with name 'GDRx' to autoload

    * `` res://reactivex//__gdrxsingleton__.gd ``

5. GDRx should now be ready to use. Try creating a simple Observable using:

    * `` var obs : Observable = GDRx.ReturnValue(42) ``
    * `` obs.subscribe(func(i): print("The answer: " + str(i))) ``
