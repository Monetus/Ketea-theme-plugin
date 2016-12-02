# -----  Creating and Removing Hotkeys -----

# All of pure data's hotkeys can be found in pd_bindings.tcl

#   Removing a binding is easy.  Just bind to the key again, and give it    \
  empty braces, like this.  Now this won't call ::pd_bindings::window_close
bind all <$::modifier-Key-w> {}

#   You'll notice all of pd's stock bindings include the $::modifier key.   \
  This is likely because there is simply less to consider.  Binding to all  \
  adds some automatic behavior, like suppressing the typing of the key, and \
  knowing the state of other keys.   For example, if you create an object   \
  like this: bind Canvas <Key-n> {+menu_send_float [winfo parent %W] obj 0} \
  an n will be typed into the objects name.  Binding to all suppresses that.\
  The problem there is that you'd never be able to type an n again!         \
  But not binding to all adds the 'other keys' problem.  If you used the    \
  hotkey for creating a new window <$::modifier-Key-n> then you'd also      \
  trigger the <Key-n> binding.

#   So you must pick a strategy.  \
  1. bind to all but unbind the key whenever you are typing. \
  2. bind to the Canvas class but track the state of hotkey conflicts.

# --  Let the coding commence  --

  # you know you'll have to bind to n, create an object, and type into it.  \
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

  proc create_metro {tkcanvas} {
    # The class check is to keep this from firing on another window, which you only need \
      if you bind to all, rather than to the Canvas class.
    if {[winfo class $tkcanvas] eq "Canvas"} {
      # find the window holding the canvas.
      set mytoplevel [winfo parent $tkcanvas]
      # check that edit mode is on to be sure that you aren't typing into a symbol obj.
      if {!$::editingtext($mytoplevel) && $::editmode($mytoplevel)} {
        # use this to create the object on the canvas window
        menu_send_float $mytoplevel obj 0
        type_into_obj $mytoplevel "metro 100"
      }
    }
  }
  # use the plus sign to keep from erasing other bindings to this key, unless that is what you want
  bind all <Key-n> {+hotkeys::create_metro %W}
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
append overwritten_body {
  if {$editing} {
    bind all <Key-n> {}
  } else {
    bind all <Key-n> {+hotkeys::create_metro %W}
  }
}

# braces on the code above to keep from interpretation, quotes on the proc below \
  to force it.

proc pdtk_text_editing "$overwritten_args" "$overwritten_body"

# clean up these globals, as they are only needed in the proc above.
unset overwritten_args
unset overwritten_body


# Now, there are two problems with the code I wrote above.
# 1. The state of the editingtext() array is not always correct. It doesn't happen\
    often at all, but you can get the value backwards by confusing the gui.       \
    Thankfully, it isn't much of a bug, as doing much of anything to the gui will \
    reset the value correctly.
# 2. When editing text, the removal of the binding removes EVERY binding to n and \
    only resets the metro one.  This isn't a problem for an unused key like n, but\
    if you wanted to add, then remove, some behavior to an existing hotkey you'd  \
    need to selectively delete bindings.  Introspection to the rescue again:

proc delete_binding {bind_tag key_combination binding} {
  # bind all <Key-n> returns a list of all the current bindings to key-n.
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

#  Sadly this proc still suffers because of the way it searches and deletes the   \
  binding from the list of all bindings.  Regular expressions aren't my strong suit.

# I left this proc at the bottom, because you probably don't need it, but if you  \
  do, just place it in the namespace above and use it where you'd like.
