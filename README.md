GenUI
=====

This is still a very early stage, basically just mucking about with some ideas about cross platform native UIs.

The idea for this project is to create a system of macros that will allow Nim to compile away any abstraction and simply create the code to make a UI based on the target platform. This will leave the user able to configure everything to their hearts desire by using platform specific code, while still allowing code sharing between platforms. For now only a couple of widgets have been implemented in Gtk3, but in the future I plan to write wrappers for Karax and possibly also Win32 and Cocoa (or whatever is the name for the current UI toolkits for Windows and Mac).

In test2 you will find the simple structure that would be present in the project itself. It is simply a couple of types and a request to create a GUI based on those types. The wrapper will then create callbacks and everything else to make the variables update and take input automatically, allowing the user to only focus on the actual application code.

Next steps will include recreating the current example in Karax, then creating a layouting system, and writing code to generate more widgets.
