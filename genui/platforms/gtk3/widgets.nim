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
    echo "Generating widget for " & pair[0]
    if testUI.customWidgets.hasKey($pair[1].variableSym.getTypeInst.toStrLit):
      echo "Custom Widget"
      result.add(testUI.customWidgets[$pair[1].variableSym.getTypeInst.toStrLit](pair[1]))
    else:
      let
        name = pair[0]
        elem = pair[1]
        s1 = elem.generatedSym
        s2 = elem.variableSym
        classes = testUI.members[name]
        cb = elem.callback
        optionsSym = elem.optionsSym
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
              if optionsSym == nil:
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
              else:
                let signalSym = genSym(nskVar)
                result.add(quote do:
                  var `s1` = gtk.newComboBoxTextWithEntry()
                  var active = -1
                  for index, text in pairs(`optionsSym`):
                    if text == `s2`:
                      active = index
                    gtk.append(`s1`, nil, text)
                  gtk.setActive(`s1`, active.cint)
                  var `signalSym` = gobject.gSignalConnect(`s1`, "changed", gobject.gCALLBACK(
                    proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                      `s2` = $gtk.getActiveText(`s1`)
                      `cbBlock`
                      postCallbackUpdate()
                  ), nil)
                )
                postCallbackUpdates.add(quote do:
                  gobject.signalHandlerBlock(`s1`, `signalSym`)
                  gtk.removeAll(`s1`)
                  for text in `optionsSym`:
                    gtk.append(`s1`, nil, text)
                  gtk.getChild(`s1`).Entry.setText(`s2`)
                  gobject.signalHandlerUnblock(`s1`, `signalSym`)
                )
            of ntyInt:
              var cbBlock = newStmtList()
              if cb != nil:
                cbBlock.add(quote do:
                  `cb`()
                )
              if optionsSym == nil:
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
                let signalSym = genSym(nskVar)
                result.add(quote do:
                  var `s1` = gtk.newComboBoxText()
                  for text in `optionsSym`:
                    gtk.append(`s1`, nil, text)
                  gtk.setActive(`s1`,`s2`.cint)
                  var `signalSym` = gobject.gSignalConnect(`s1`, "changed", gobject.gCALLBACK(
                    proc (widget: gtk.Widget, data: glib.Gpointer) {.cdecl.}  =
                      `s2` = gtk.getActive(`s1`)
                      `cbBlock`
                      postCallbackUpdate()
                  ), nil)
                )
                postCallbackUpdates.add(quote do:
                  gobject.signalHandlerBlock(`s1`, `signalSym`)
                  gtk.removeAll(`s1`)
                  for text in `optionsSym`:
                    gtk.append(`s1`, nil, text)
                  gtk.setActive(`s1`, `s2`.cint)
                  gobject.signalHandlerUnblock(`s1`, `signalSym`)
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
    proc disable(elem: gtk.Widget) =
      gtk.setSensitive(elem, false)
    proc enable(elem: gtk.Widget) =
      gtk.setSensitive(elem, true)
    proc postCallbackUpdate() =
      `postCallbackUpdates`
  )
  if after != nil:
    result.add(after)
  echo result.toStrLit

template startUI() =
  gtk.main()

