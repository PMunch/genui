import macros
from oldgtk3/gtk import nil
from oldgtk3/gobject import nil
from oldgtk3/glib import nil

template initUI() =
  gtk.initWithArgv()

macro createUI(after: untyped = nil): untyped =
  result = newStmtList()
  var callbackList = newStmtList()
  var postCallbackUpdates = newStmtList()
  result.add(quote do:
    proc setValue(label: gtk.Label, value: string) =
      gtk.setText(label, cstring(value))
    proc setValue(button: gtk.Button, value: string) =
      gtk.setLabel(button, cstring(value))
    proc postCallbackUpdate()
  )
  for pair in testUI.widgets.pairs:
    let
      name = pair[0]
      elem = pair[1]
      s1 = elem.generatedSym
      s2 = elem.variableSym
      classes = testUI.members[name]
      cb = elem.callback
    case elem.kind:
      of UIKind.call:
        case elem.variableType:
          of ntyString, ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                `cb`()
              )
            result.add(quote do:
              var `s1` = gtk.newButton($`s2`)
              discard gobject.gSignalConnect(`s1`, "clicked", gobject.gCALLBACK(
                proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `cbBlock`
                  postCallbackUpdate()
              ), nil)
            )
            postCallbackUpdates.add(quote do:
              `s1`.setValue($`s2`)
            )
          else: discard
      of UIKind.show:
        case elem.variableType:
          of ntyInt, ntyFloat, ntyString:
            result.add(quote do:
              var `s1` = gtk.newLabel(cstring($`s2`))
              gtk.setXalign(`s1`, 0)
            )
            postCallbackUpdates.add(quote do:
              `s1`.setValue($`s2`)
            )
          else:
            echo elem.variableType
      of UIKind.edit:
        case elem.variableType:
          of ntyString:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                `cb`()
              )
            result.add(quote do:
              var `s1` = gtk.newEntry()
              gtk.setText(`s1`, `s2`)
              discard gobject.gSignalConnect(`s1`, "changed", gobject.gCALLBACK(
                proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.} =
                  `s2` = $gtk.getText(`s1`)
                  `cbBlock`
                  postCallbackUpdate()
              ), nil)
            )
            postCallbackUpdates.add(quote do:
              gtk.setText(`s1`,$`s2`)
            )
          of ntyInt:
            var cbBlock = newStmtList()
            if cb != nil:
              cbBlock.add(quote do:
                `cb`()
              )
            result.add(quote do:
              var `s1` = gtk.newSpinButton(cdouble(`s2`.low), cdouble(`s2`.high), 1)
              gtk.setValue(`s1`, cdouble(`s2`))
              discard gobject.gSignalConnect(`s1`, "value-changed", gobject.gCALLBACK(
                proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                  `s2` = gtk.getValueAsInt(`s1`)
                  `cbBlock`
                  postCallbackUpdate()
              ), nil)
            )
            postCallbackUpdates.add(quote do:
              gtk.setValue(`s1`,cdouble(`s2`))
            )
          else:
            echo elem.variableType
      else: continue
    var context = genSym(nskVar)
    result.add(quote do:
      gtk.setName(`s1`, `name`)
      var `context` = gtk.getStyleContext(`s1`);
    )
    for class in classes:
      result.add(quote do:
        gtk.addClass(`context`,`class`);
      )
  result.add(callbackList)
  result.add(quote do:
    proc postCallbackUpdate() =
      `postCallbackUpdates`
  )
  if after != nil:
    result.add(after)
  echo result.toStrLit

template startUI() =
  gtk.main()

