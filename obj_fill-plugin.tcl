# META NAME obj_fill-plugin
# META DESCRIPTION the obj_fill-plugin provides autocompletion via a database
# META AUTHOR monetus
# META VERSION 0.0.2
# META LICENSE "Standard Improved BSD License", "BSD 3-Clause License"

if {[catch {
            package require pdtk_canvas
            package require pdtk_text
           } no_vanilla_packages_error]
} {puts $no_vanilla_packages_error}

if {[catch {package require ketea}]} {
    # no ketea theme - use standard pd colors

} else {
    # We have a theme, use ketea's variables

}

namespace eval autocomplete:: {
  variable draw_flag 1
  variable last_canvas ""
  variable current_object ""
  variable position 127
  variable x1
  variable x2
  variable y1
  variable tags ""
  # The keys added to this dict should be sorted by increasing ascii, just in case.
  variable object_database ""

  # Find and format the object database
  proc read_object_db {} {
    set file [file join $::current_plugin_loadpath object_db.dict]
    set fp [open $file r]
    fconfigure $fp -blocking 0
    set data_to_format [read -nonewline $fp]
    close $fp
    dict for {lib db} $data_to_format {
      foreach {object separator arguments} $db {
        dict set autocomplete::object_database $lib $object $arguments
      }
    }
  }
  read_object_db

  # this highlights one past the end of the list.  fix or keep as a delete?.
  proc cycle_autocomplete_tags {} {
    if {$autocomplete::position < [llength $autocomplete::tags]} {
      $autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -fill $themed::active_fg
      incr autocomplete::position
    } else {
      set autocomplete::position 0
    }
    $autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -fill $themed::hl
    focus $autocomplete::last_canvas
  }

  proc blank {text} {
    set mytoplevel [winfo toplevel $autocomplete::last_canvas]
    for {set characters_to_delete [expr {1+[string length $text]}]} \
        {$characters_to_delete > 0} \
        {incr characters_to_delete -1} {
          #backspace
          pdsend "$mytoplevel key 1 8 0"
    }
  }
  #BUG fix the rename_obj_procs to skip args somehow.
  # write text into the object box
  proc rename_obj {text} {
    set mytoplevel [winfo toplevel $autocomplete::last_canvas]
    #set the draw command to be skipped
    set autocomplete::draw_flag 0
    #clear box
    autocomplete::blank $text
    set first_word [lindex $text 0]
    set first_and_second_word [lrange $text 0 1]
    dict for {lib db} $autocomplete::object_database {
      if {[dict exists $autocomplete::object_database $lib $first_and_second_word]} {
        set autocomplete::current_object $first_and_second_word
        break
      } elseif {[dict exists $autocomplete::object_database $lib $first_word]} {
        set autocomplete::current_object $first_word
        break
      } else {
        set autocomplete::current_object $text
        break
      }
    }
    set text_length [string length $autocomplete::current_object]
    #type into box
    for {set index 0} {$index < $text_length} {incr index} {
        set letter [string index $autocomplete::current_object $index]
        scan $letter %c keynum
        pdsend "$mytoplevel key 1 $keynum 0"
    }
    after idle "set autocomplete::draw_flag 1"
    $autocomplete::last_canvas delete autobox
    $autocomplete::last_canvas delete autotext
  }

  proc rename_obj_via_return {} {
    if {$autocomplete::tags eq ""} {return}
    autocomplete::rename_obj [
      $autocomplete::last_canvas itemcget [
        lindex $autocomplete::tags $autocomplete::position
      ] -text
    ]
  }

  proc rename_obj_via_click {} {
    autocomplete::rename_obj [
      $autocomplete::last_canvas itemcget current -text
    ]
  }

  proc hover_leave_color_check {} {
    if {[$autocomplete::last_canvas itemcget current -text] ne [$autocomplete::last_canvas itemcget [lindex $autocomplete::tags $autocomplete::position] -text]} {
      $autocomplete::last_canvas itemconfigure current -fill $themed::active_fg
    }
  }

  proc create_autotext {text row_adjustment} {
    lappend autocomplete::tags\
      [$autocomplete::last_canvas create text [expr $autocomplete::x1 + 4] [expr $autocomplete::y1 + $row_adjustment]\
        -text $text -tags autotext -fill $themed::active_fg\
        -font "$::font_family $::dialog_font::fontsize" -anchor nw]
  }

  proc create_autobox {x_margin y_margin} {
    $autocomplete::last_canvas create line $autocomplete::x1 $autocomplete::y1\
                          $autocomplete::x1 [expr $autocomplete::y1 + $y_margin + 2]\
                          [expr $autocomplete::x1 + $x_margin] [expr $autocomplete::y1 + $y_margin + 2]\
                          [expr $autocomplete::x1 + $x_margin] $autocomplete::y1\
                          $autocomplete::x2 $autocomplete::y1\
              -fill $themed::active_bg -dash 8 -tags autobox
  }

}
# could add object arg tracking, like table names, or struct fields.
if {
  [catch {
          #----------overwrite-procs------------------------
            # this triggers for any text change. keep light.
          set pdtk_text_set_args [info args pdtk_text_set]
          set pdtk_text_set_body [info body pdtk_text_set]
          append pdtk_text_set_body {
            if {$autocomplete::draw_flag} {
              $tkcanvas delete autotext
              $tkcanvas delete autobox
              # To keep the obj boxes from being small, the $text value is never less than three chars long.  It is padded with whitespace if less than 3.
              # For some reason text_set is run after editing_text is set to zero.  So must check to skip the draw.
              # Must also check to see if the text being edited is an obj and not a comment or label or something.
              if {
                $text eq "   " ||
                !$::editingtext([winfo toplevel $tkcanvas]) ||
                [lsearch -exact [$tkcanvas gettags [$tkcanvas find withtag $tag]] obj] eq -1
              } {return}
              # find the objects to display
              set autocomplete::tags ""
              set y_iter 4
              set autobox_size 50
              set first_word [string trim [lindex $text 0]]
              set first_and_second_word [string trim [lrange $text 0 1]]
              dict for {lib db} $autocomplete::object_database {
                if {[dict exists $autocomplete::object_database $lib $first_and_second_word]} {
                  set autocomplete::current_object $first_and_second_word
                  break
                } elseif {[dict exists $autocomplete::object_database $lib $first_word]} {
                  set autocomplete::current_object $first_word
                  break
                } else {
                  set autocomplete::current_object $text
                  break
                }
              }
              dict for {lib db} $autocomplete::object_database {
                dict for {obj arg} [dict filter $db key $autocomplete::current_object*] {
                  # delete or prepend space to args
                  if {[string match "$obj *" $text]} {
                    set arg " $arg"
                  } else {
                    set arg ""
                  }

                  # find width for the outline around the text
                  set text_width [expr {
                    [string length "$obj$arg"] * int($::dialog_font::fontsize*0.75)
                  }]
                  if {$text_width > $autobox_size} {
                    set autobox_size $text_width
                  }

                  # draw the suggestions
                  autocomplete::create_autotext "$obj$arg" $y_iter
                  incr y_iter $::dialog_font::fontsize
                }
              }

              # if the y_iter was never incremented, there is nothing to outline
              if {$y_iter ne 4} {
                autocomplete::create_autobox $autobox_size $y_iter
              }
            }
          }
          proc pdtk_text_set "$pdtk_text_set_args" "$pdtk_text_set_body"
          unset pdtk_text_set_args pdtk_text_set_body

          set pdtk_text_editing_args [info args pdtk_text_editing]
          set pdtk_text_editing_body [info body pdtk_text_editing]
          append pdtk_text_editing_body {
            set autocomplete::position 127
            if {$editing == 0} {
              $tkcanvas delete autobox
              $tkcanvas delete autotext
              set autocomplete::tags ""
            } else {
              set autocomplete::last_canvas $tkcanvas
              # R for the obj instead of the text's width
              set coords [$tkcanvas bbox ${tag}R]
              set autocomplete::x1 [lindex $coords 0]
              set autocomplete::x2 [lindex $coords 2]
              set autocomplete::y1 [lindex $coords 3]
            }
          }
          proc pdtk_text_editing "$pdtk_text_editing_args" "$pdtk_text_editing_body"
          unset pdtk_text_editing_args pdtk_text_editing_body

          set pdtk_canvas_new_args [info args pdtk_canvas_new]
          set pdtk_canvas_new_body [info body pdtk_canvas_new]
          append pdtk_canvas_new_body {
            #autocomplete bindings - should be in pd_bindings but there is an unexplained error
            set autocomplete::last_canvas $tkcanvas
            $tkcanvas bind autotext <Enter> {+$autocomplete::last_canvas itemconfigure current -fill $themed::hl}
            $tkcanvas bind autotext <Leave> {+autocomplete::hover_leave_color_check}
            $tkcanvas bind autotext <ButtonPress-1> {+autocomplete::rename_obj_via_click}
            bind $tkcanvas <Tab> {+autocomplete::cycle_autocomplete_tags}
            bind $tkcanvas <KeyRelease-Return> {+autocomplete::rename_obj_via_return}
            # keyrelease so that the return is input before the obj is renamed
          }
          proc pdtk_canvas_new "$pdtk_canvas_new_args" "$pdtk_canvas_new_body"
          unset pdtk_canvas_new_args pdtk_canvas_new_body
          #---------------------------------------------------
         } cant_overwrite_error]
    } {puts $cant_overwrite_error}
