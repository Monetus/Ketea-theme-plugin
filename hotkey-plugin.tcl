# -----  Creating and Removing Hotkeys -----

# All of pure data's hotkeys can be found in pd_bindings.tcl

#   Removing a binding is easy.  Just bind to the key again, and give it    \
  empty braces, like this.  Now this won't call ::pd_bindings::window_close
bind all <$::modifier-Key-w> {}

#   You'll notice all of pd's stock bindings include the $::modifier key.   \
  This is likely because there is simply less to consider.  Binding to all  \
  adds some automatic behavior, like suppressing the typing of the key, and \
  knowing the state of other keys.   For example, if you create an object   \
  like this: bind Canvas <Key-m> {+menu_send_float [winfo parent %W] obj 0} \
  an m will be typed into the objects name.  Binding to all suppresses that.\
  The problem there is that you'd never be able to type an m again!         \
  But not binding to all adds the problem of other keys.  If you used the   \
  hotkey for creating a new window <$::modifier-Key-m> then you'd also      \
  trigger the <Key-m> binding.

#   So you must pick a strategy.  \
  1. bind to all but unbind the key whenever you are typing. \
  2. bind to the Canvas class but track the state of hotkey conflicts.

# --  Let the coding commence  --

  # you know you'll have to bind to a letter, create an object, and type into it.  \
    so lets get that out of the way.

# the main point of this namespace is to keep the generically named procs \
  from being accidentally called by someone else's plugin.
namespace eval hotkeys:: {

  proc type_into_obj {mytoplevel text} {
    # type into box
    set text_length [string length $text]
    for {set index 0} {$index < $text_length} {incr index} {
      set letter [string index $text $index]
      scan $letter %c keynum
      pdsend "$mytoplevel key 1 $keynum 0"
    }
  }

  # looking around pd's source code, you'll find useful variables, like the array \
    ::editingtext().  It takes the name of the window holding a canvas and returns \
    a boolean (1 or 0) depending on whether or not you are editing an obj/msg.     \
    There is also the ::editmode() array that is true if in edit mode. \
    These array indices are only the names of PatchWindows!

  proc create_named_obj {tkcanvas obj_name} {
    # The class check is to keep this from firing on another window, which you only need \
      if you bind to all, rather than to the Canvas class.
    if {[winfo class $tkcanvas] eq "Canvas"} {
      # find the window holding the canvas.
      set mytoplevel [winfo parent $tkcanvas]
      # check that edit mode is on to be sure that you aren't typing into a symbol obj.
      if {!$::editingtext($mytoplevel) && $::editmode($mytoplevel)} {
        # use this to create the object on the canvas window
        menu_send_float $mytoplevel obj 0
        type_into_obj $mytoplevel $obj_name
      }
    }
  }

  # The only point to this variable is being concise.  Don't repeat yourself.
      # bindings for j, x, y, & z are weird
  set keybindings \
         "a {array } \
          b {b } \
          c {change } \
          d {del} \
          e {env~ } \
          f {f } \
          g {get } \
          h {hip~ } \
          i {inlet} \
          j {outlet} \
          k {key} \
          l {line~} \
          m {metro 100}\
          n {noise~} \
          o {osc~ } \
          p {pack } \
          q {qlist } \
          r {receive} \
          s {send} \
          t {t } \
          u {until } \
          v {vcf~ } \
          w {wrap~} \
          x {text } \
          y {print } \
          z {list }"
  # use the plus sign to keep from erasing other bindings to the key, unless that is what you want
  foreach {letter name} $hotkeys::keybindings {
    # The quotes are to force interpretation of the variable and\
    the curly braces are to keep a list as one argument, e.g. metro 100.
    bind all <Key-$letter> "+hotkeys::create_named_obj %W {$name}"
  }
}


# # This is the default content of this internal pd proc, as of pd-0.47.1
# proc pdtk_text_editing {mytoplevel tag editing} {
#     set tkcanvas [tkcanvas_name $mytoplevel]
#     if {$editing == 0} {selection clear $tkcanvas}
#     $tkcanvas focus $tag
#     set ::editingtext($mytoplevel) $editing
# }

# To be as optimized as possible, you'd embed the logic within that already     \
  existing if statement.  But that way, you'd have to check every update of pd  \
  and your gui plugins to see if they changed this proc too.  Instead, use      \
  introspection.
set overwritten_args [info args pdtk_text_editing]
set overwritten_body [info body pdtk_text_editing]
  # braces around all this to keep $editing from being interpeted
append overwritten_body {
  if {$editing} {
    foreach {letter name} $hotkeys::keybindings {
      bind all <Key-$letter> {}
    }
  } else {
    foreach {letter name} $hotkeys::keybindings {
      # yet again, quotes force interpretation, braces to keep the list as one arg
      bind all <Key-$letter> "+hotkeys::create_named_obj %W {$name}"
    }
  }
}

proc pdtk_text_editing "$overwritten_args" "$overwritten_body"

# clean up these globals, as they are only needed in the proc above.
unset overwritten_args
unset overwritten_body


# Now, there are two problems with the code I wrote above.
# 1. The state of the editingtext() array is not always correct. It doesn't happen\
    often at all, but you can get the value backwards by confusing the gui.       \
    Thankfully, it isn't much of a bug, as doing much of anything to the gui will \
    reset the value correctly.
# 2. When editing text, the removal of the binding removes EVERY binding and \
    only resets the one.  This isn't a problem for an unused key like n, but \
    if you wanted to add, then remove, some behavior to an existing hotkey you'd \
    need to selectively delete bindings.  Introspection to the rescue again:

proc delete_binding {bind_tag key_combination binding} {
  # bind all <Key-m> returns a list of all the current bindings to Key-m.
  set all_bindings [bind $bind_tag <$key_combination>]
  # find where the binding you want to delete starts in the list by searching for \
    the first word in the binding.
  set binding_index [lsearch -exact $all_bindings [lindex $binding 0]]
  # if it exists
  if {$binding_index ne -1} {
    # then, for the last index, find the size of the binding - 1 + starting index
    set all_bindings \
      [lreplace $all_bindings $binding_index [expr $binding_index+[llength $binding]-1]]
    # yet again, quotes rather than curly braces to force interpretation
    bind $bind_tag <$key_combination> "$all_bindings"
  }
}
  # You'd use this like:   delete_binding all Key-m "hotkeys::create_named_obj %W {metro 100}"
#  Sadly this proc still suffers because of the way it searches and deletes the   \
  binding from the list of all bindings.  Regular expressions aren't my strong suit.

# I left this proc at the bottom, because you probably don't need it, but if you  \
  do, just place it in the namespace above and use it where you'd like.
