# META NAME ketea-theme-plugin
# META DESCRIPTION the ketea-theme-plugin provides a theme for pure data
# META AUTHOR monetus
# META VERSION 0.0.4
# META LICENSE "Standard Improved BSD License", "BSD 3-Clause License"


#package require Tk 8.5
package require pd_bindings
package require pdtk_text
package require pdwindow

package provide ketea 0.0.4

#I've taken to just reassigning the colors, but its definitely confusing because,\
 while they still corellate to options, they should be renamed to describe \
 the edit & run mode changes.  Maybe make an advanced menu?
namespace eval themed:: {
  variable bg #ffffff
    variable fg #000000
    variable active_fg #000000
    variable active_bg #aaaaaa
    variable hl #000000
    variable hl_bg #C6FFFF
    variable disabled_fg #000000
    variable insert_bg #ffffff
    variable sel #aaaaaa
    variable sel_fg #000000
    variable sel_bg #C6FFFF
    variable trough #000000; #not a single thing with this on mac so far.
  variable all_color_options "\
   -background themed::bg\
   -foreground themed::fg\
   -activeForeground themed::active_fg\
   -activeBackground themed::active_bg\
   -highlightColor themed::hl\
   -highlightBackground themed::hl_bg\
   -disabledForeground themed::disabled_fg\
   -insertBackground themed::insert_bg\
   -selectColor themed::sel\
   -selectForeground themed::sel_fg\
   -selectBackground themed::sel_bg\
   -troughColor themed::trough"
   variable edit_or_runmode_text
   #making a pair of global arrays to keep track of every canvas and their \
     tags would make things easy, but I don't wanna do it without finding a \
     way to unset the arrays.
  proc configure_for_editmode {tkcanvas} {
    #set this for the pdtk_text_set proc
    set themed::edit_or_runmode_text $themed::fg
    #this tag is automatically handled by tk, flagging whats under the mouse
    #$tkcanvas itemconfigure current
      #$tkcanvas itemconfigure base1 -outline $themed::insert_bg
      #$tkcanvas itemconfigure base1 -fill $themed::insert_bg
      #$tkcanvas itemconfigure BASE2 -outline $themed::insert_bg
      #$tkcanvas itemconfigure PLED -fill $themed::insert_bg
      #$tkcanvas itemconfigure BASE2 -fill $themed::insert_bg
      #$tkcanvas itemconfigure BASE -fill $themed::active_fg
    # these don't log errors but they quietly fail, they need a proper glob

    $tkcanvas configure -background $themed::bg
    #need to add gop tag
    #msg & label have text tag too
    $tkcanvas itemconfigure {cord || graph || obj} -fill $themed::active_fg
    $tkcanvas itemconfigure commentbar -fill $themed::active_fg
    $tkcanvas itemconfigure GOP -fill $themed::active_bg
    $tkcanvas itemconfigure array -fill $themed::active_bg -activefill $themed::hl
    $tkcanvas itemconfigure atom -fill $themed::active_fg -activefill $themed::hl
    $tkcanvas itemconfigure msg -fill $themed::active_fg -activefill $themed::hl
    $tkcanvas itemconfigure text -fill $themed::fg
    #$tkcanvas itemconfigure label -fill $themed::fg
    $tkcanvas itemconfigure {inlet || outlet} -fill $themed::hl_bg -outline $themed::fg
    $tkcanvas raise {inlet || outlet}
    $tkcanvas lower cord
  }
  proc configure_for_runmode {tkcanvas} {
    #set this for the pdtk_text_set proc
    $tkcanvas configure -background $themed::insert_bg
    set themed::edit_or_runmode_text $themed::disabled_fg
    $tkcanvas itemconfigure {obj || graph} -fill $themed::trough
    $tkcanvas itemconfigure GOP -fill $themed::sel
    $tkcanvas itemconfigure array -fill $themed::sel -activefill $themed::sel_fg
    $tkcanvas itemconfigure msg -fill $themed::trough -activefill $themed::sel_fg
    $tkcanvas itemconfigure atom -fill $themed::trough -activefill $themed::sel_fg
    $tkcanvas itemconfigure text -fill $themed::disabled_fg
    #$tkcanvas itemconfigure label -fill $themed::fg
    $tkcanvas itemconfigure {inlet || outlet} -fill $themed::sel -outline $themed::disabled_fg
    $tkcanvas lower {inlet || outlet}
    $tkcanvas lower cord
  }
  proc configure_upon_editmode {window} {
    #need to test if this pdwindow check is necessary
    if {$window eq ".pdwindow"} {return}
    #as well as this
   	if { ! [winfo exists $window] } {return}
    set tkcanvas [tkcanvas_name $window]
    if {$::editmode($window) eq 1} {
      themed::configure_for_editmode $tkcanvas
    } else {
      themed::configure_for_runmode $tkcanvas
    }
  }
  proc configure_tk_palette {} {
    # notice that insertbackground is hl for the sake of the cursor\
              and disabledForeground is fg for the sake of dialogWindow text\
              should probably get away from this.
    tk_setPalette\
        background $themed::bg\
        foreground $themed::fg\
        activeForeground $themed::active_fg\
        activeBackground $themed::active_bg\
        highlightColor $themed::hl\
        highlightBackground $themed::hl_bg\
        disabledForeground $themed::fg\
        insertBackground $themed::hl\
        selectColor $themed::sel\
        selectForeground $themed::sel_fg\
        selectBackground $themed::sel_bg\
        troughColor $themed::trough
  }
  proc configure_the_backgrounds {color} {
    #these aren't being colored by the option database for some reason
    .pdwindow.header configure -background $color
    .pdwindow.header.dsp configure -background $color
    .pdwindow.header.loglabel configure -background $color
    .pdwindow.header.logmenu configure -background $color
    .pdwindow.header.ioframe configure -background $color
    .pdwindow.header.ioframe.iostate configure -background $color
    .pdwindow.header.ioframe.dio configure -background $color
    if {[winfo exists .pdwindow.tcl]} {
      .pdwindow.tcl configure -background $color
      if {[winfo exists .pdwindow.tcl.label]} {
        .pdwindow.tcl.label configure -background $color
      }
      if {[winfo exists .pdwindow.tcl.entry]} {
        .pdwindow.tcl.entry configure -highlightbackground $color
      }
    }
    #the audio error label is colored to be hidden
    .pdwindow.header.ioframe.dio configure -fg $color

    # the toplevel background color in dialog windows
    option add *DialogWindow.Background $color

    # the border around entry menus in dialog windows but not the pdWindow
    option add *Entry.highlightBackground $color

    # the color of the frame around the button, that also overlays when unfocused.
    option add *Button.highlightBackground $color

    # the background of the frames inserted in toplevel dialogs
    option add *Frame.Background $color
    option add *Labelframe.Background $color

    # the background of disabled entry menus in dialogWindows
    option add *Entry.DisabledBackground $themed::bg

    # the background of text windows like .aboutPd
    option add *Text.Background $themed::bg
  }
  proc recurse_and_configure_foreground {window color} {
    foreach child [winfo children $window] {
      $child configure -foreground $color
      themed::recurse_and_configure_foreground $child $color
    }
  }
  proc configure_misc_options {} {
    option add *Button.Foreground $themed::active_fg
    option add *Menu.Foreground $themed::active_fg
    if {[winfo exists .menubar]} {
      .menubar configure -foreground $themed::active_fg
      themed::recurse_and_configure_foreground .menubar $themed::active_fg
    }
    if {[winfo exists .openrecent]} {
      .openrecent configure -foreground $themed::active_fg
    }
    if {[winfo exists .popup]} {
      .popup configure -foreground $themed::active_fg
      themed::recurse_and_configure_foreground .popup $themed::active_fg
    }
  }
}

proc overwrite_pd_color_procs {} {
    #overwrite the proc that changes the color of the audio error label
  proc ::pdwindow::pdtk_pd_dio {red} {
    if {$red == 1} {
        .pdwindow.header.ioframe.dio configure -foreground $themed::trough
    } else {
        .pdwindow.header.ioframe.dio configure -foreground $themed::bg
    }
  }

    #overwrite the proc that changes the color of the tcl_entry menu.
  proc ::pdwindow::validate_tcl {} {
    variable tclentry
    if {[info complete $tclentry]} {
        .pdwindow.tcl.entry configure -background $themed::bg
    } else {
      scan $themed::bg #%2x%2x%2x BGr BGg BGb
      set BGr [expr {$BGr-($BGr/4)}]
      set BGg [expr {$BGg-($BGg/4)}]
      set BGb [expr {$BGb-($BGb/4)}]

      set darker_bg ""
      append darker_bg #\
        [string trim [format %02X $BGr]] [string trim [format %02X $BGg]] [string trim [format %02X $BGb]]

        .pdwindow.tcl.entry configure -background $darker_bg
    }
  }

    #this is the proc that underlies pdwindow::post, error, debug, & verbose
  proc ::pdwindow::set_layout {} {
        # note that the order is fatal, post, debug, verbose
    variable maxloglevel
    .pdwindow.text.internal tag configure log0 -foreground $themed::hl -background $themed::hl_bg
    .pdwindow.text.internal tag configure log1 -foreground $themed::active_fg
    # log2 messages are the foreground color
    .pdwindow.text.internal tag configure log3 -foreground $themed::active_bg

    scan $themed::fg #%2x%2x%2x FGr FGg FGb
    scan $themed::bg #%2x%2x%2x BGr BGg BGb

    # divide by twenty three to give a little extra room, make sure its a float and the bounds are 0-255\
          times -1 to decr instead of incr
    set FGr_i [expr {int( ($FGr-$BGr) / -23.)}]
    set FGg_i [expr {int( ($FGg-$BGg) / -23.)}]
    set FGb_i [expr {int( ($FGb-$BGb) / -23.)}]

    # 0-20(4-24) is a rough useful range of 'verbose' levels for impl debugging
    set start 4
    set end 25

    for {set i $start} {$i < $end} {incr i} {
      incr FGr $FGr_i
      incr FGg $FGg_i
      incr FGb $FGb_i
      #format probably could be used once without trimming the whitespace. yet again, badly done.
      set rgb_hex_bg ""
      append rgb_hex_bg #\
        [string trim [format %02X $FGr]] [string trim [format %02X $FGg]] [string trim [format %02X $FGb]]
      .pdwindow.text.internal tag configure log${i} -foreground $rgb_hex_bg
    }
  }
    #this is apparently called before the guiplugins so you have to call it again.
  pdwindow::set_layout

    # this triggers for any text change. keep light.
  proc pdtk_text_set {tkcanvas tag text} {
    $tkcanvas itemconfigure $tag -text $text -fill $themed::edit_or_runmode_text
  }

  proc pdtk_text_new {tkcanvas tags x y text font_size color} {
    $tkcanvas create text $x $y -tags $tags -text $text -fill $themed::fg \
        -anchor nw -font [get_font_for_size $font_size]
    set mytag [lindex $tags 0]
    $tkcanvas bind $mytag <Home> "$tkcanvas icursor $mytag 0"
    $tkcanvas bind $mytag <End>  "$tkcanvas icursor $mytag end"
    # select all
    $tkcanvas bind $mytag <Triple-ButtonRelease-1>  \
        "pdtk_text_selectall $tkcanvas $mytag"
    if {$::windowingsystem eq "aqua"} {
      # emacs bindings for Mac OS X
        $tkcanvas bind $mytag <Control-a> "$tkcanvas icursor $mytag 0"
        $tkcanvas bind $mytag <Control-e> "$tkcanvas icursor $mytag end"
    }
  }
}

proc enact_theme_menu {} {
  # look into whether the c ties are necessary

  namespace eval dialog_theme:: {variable ketea_loadpath $::current_plugin_loadpath}
  #-----load and save configuration file--------
  proc dialog_theme::load_palette_colors_from_file {} {
    set palette_file [file join $dialog_theme::ketea_loadpath palette.tcllist]
    if {[file isfile $palette_file]} {
      #open a read-only channel to palette.tcllist
      set channel_id [open $palette_file r]

      #write contents to variable
      set save_file [read $channel_id]

      #close I/O channel
      close $channel_id

      # this load is bound to the number of options saved.  Remember.
      if {[llength $save_file] != 24} {
        pdwindow::error "The palette could not be loaded\n"
        return
      }

      set list_index 1
      foreach {option hexvalue} $save_file {
        set [lindex $themed::all_color_options $list_index] $hexvalue
        incr list_index 2
      }
      #will need to make this proc colorize upon loading a save if multiple are allowed
      #themed::configure_tk_palette
      #themed::configure_the_backgrounds $themed::bg
      #themed::configure_misc_options
      #overwrite_pd_color_procs
      #dialog_theme::configure_buttons_entries_and_canvases .
    }
  }

  proc dialog_theme::save_palette_colors_to_file {} {
    #location of file
    set palette_file [file join $dialog_theme::package_location palette.tcllist]

    #open a write-only channel to palette.tcllist
    set channel_id [open $palette_file w]

    puts $channel_id "background $themed::bg\
                      foreground $themed::fg\
                      activeForeground $themed::active_fg\
                      activeBackground $themed::active_bg\
                      highlightColor $themed::hl\
                      highlightBackground $themed::hl_bg\
                      disabledForeground $themed::disabled_fg\
                      insertBackground $themed::insert_bg\
                      selectColor $themed::sel\
                      selectForeground $themed::sel_fg\
                      selectBackground $themed::sel_bg\
                      troughColor $themed::trough"

    #close I/O channel
    close $channel_id
  }
  #---------------------------------------------
  #-----setting the bg of the preview labels----
  proc dialog_theme::set_hexcolor_bg {chosen_color} {
    foreach {color e_val r_val} $dialog_theme::palette_colors {
      if {[set ::dialog_theme::check1_val_$color]} {
        .theme.labelframe.colbox_e_$color configure -background $chosen_color
      }
      if {[set ::dialog_theme::check2_val_$color]} {
        .theme.labelframe.colbox_r_$color configure -background $chosen_color
      }
    }
  }

  proc dialog_theme::set_hexcolor_bg_by_palette {window} {
    set chosen_color [lindex [$window configure -background] 4]
    dialog_theme::set_hexcolor_bg $chosen_color
  }

  proc dialog_theme::set_hexcolor_bg_by_swatch {} {
    set chosen_color\
      [tk_chooseColor -title [_ "Pick a Color"] -initialcolor [lindex $dialog_theme::last_checked_checkbutton 1]]
    if {$chosen_color ne ""} {
      dialog_theme::set_hexcolor_bg $chosen_color
    }
    focus [lindex $dialog_theme::last_checked_checkbutton 0]
  }
  #---------------------------------------------
  proc dialog_theme::log_last_checked_checkbutton {window color} {
    if {[set [$window cget -variable]]} {
      set dialog_theme::last_checked_checkbutton "$window $color"
    }
  }

  proc dialog_theme::create_hexcolors {mytoplevel} {
    labelframe $mytoplevel.colors -borderwidth 1 -text [_ "Colors"] -padx 5 -pady 5\
      -relief groove -labelanchor n
    grid $mytoplevel.colors -row $::dialog_theme::row_iterator -columnspan 3
    button $mytoplevel.colors.swatch_button -text [_ "Palette"]\
      -command dialog_theme::set_hexcolor_bg_by_swatch
    grid $mytoplevel.colors.swatch_button -row $::dialog_theme::row_iterator

    # color scheme by Mary Ann Benedetto http://piR2.org

    #if this foreach pair looks weird its because the variables r, hexcols, & i are being instantiated \
        with a list to iterate through.  Very nifty foreach in tcl.
    foreach r {0 1 2} hexcols {
      { "#FFFFFF" "#DFDFDF" "#BBBBBB" "#FFC7C6" "#FFE3C6" "#FEFFC6" "#C6FFC7" "#C6FEFF" "#C7C6FF" "#E3C6FF" }
      { "#9F9F9F" "#7C7C7C" "#606060" "#FF0400" "#FF8300" "#FAFF00" "#00FF04" "#00FAFF" "#0400FF" "#9C00FF" }
      { "#404040" "#202020" "#000000" "#551312" "#553512" "#535512" "#0F4710" "#0E4345" "#131255" "#2F004D" } } \
    {
      frame $mytoplevel.colors.r$r
      grid $mytoplevel.colors.r$r -sticky n
      foreach i { 0 1 2 3 4 5 6 7 8 9} hexcol $hexcols \
      {
        label $mytoplevel.colors.r$r.c$i -background $hexcol -activebackground $hexcol\
          -relief ridge -padx 7 -pady 0 -width 1
        grid $mytoplevel.colors.r$r.c$i -row [expr $::dialog_theme::row_iterator + $r] -column $i
        bind $mytoplevel.colors.r$r.c$i <Button> "dialog_theme::set_hexcolor_bg_by_palette %W"
      }
    }
    incr ::dialog_theme::row_iterator 3
  }

  proc dialog_theme::add_theme_buttons {mytoplevel} {
    label $mytoplevel.label_e -text [_ "edit"]
    label $mytoplevel.label_r -text [_ "run"]
    grid configure $mytoplevel.label_e -column 1 -row 0
    grid configure $mytoplevel.label_r -column 2 -row 0

    foreach {color e_val r_val} $dialog_theme::palette_colors {
      variable ::dialog_theme::check1_val_$color 0
      variable ::dialog_theme::check2_val_$color 0
      label $mytoplevel.label_$color -text [_ "$color"]
      label $mytoplevel.colbox_e_$color -background $e_val -relief ridge -width 2
      label $mytoplevel.colbox_r_$color -background $r_val -relief ridge -width 2
      checkbutton $mytoplevel.check1_$color -variable ::dialog_theme::check1_val_$color\
        -command "dialog_theme::log_last_checked_checkbutton \
                  $mytoplevel.check1_$color [$mytoplevel.colbox_e_$color cget -background]"
      checkbutton $mytoplevel.check2_$color -variable ::dialog_theme::check2_val_$color\
        -command "dialog_theme::log_last_checked_checkbutton \
                  $mytoplevel.check2_$color [$mytoplevel.colbox_r_$color cget -background]"
      grid configure $mytoplevel.label_$color -column 0 -row $::dialog_theme::row_iterator -rowspan 2
      grid configure $mytoplevel.check1_$color -column 1 -row $::dialog_theme::row_iterator
      grid configure $mytoplevel.check2_$color -column 2 -row $::dialog_theme::row_iterator
      grid configure $mytoplevel.colbox_e_$color -column 1 -row [expr $::dialog_theme::row_iterator+1]
      grid configure $mytoplevel.colbox_r_$color -column 2 -row [expr $::dialog_theme::row_iterator+1]
      incr ::dialog_theme::row_iterator 2
    }
  }

  proc dialog_theme::create_dialog {gfxstub} {
    # todo: add keyboard shortcut to menu
    if [winfo exists $gfxstub] {
      wm deiconify $gfxstub
      raise $gfxstub
      focus $gfxstub
    } else {
      set ::dialog_theme::palette_colors "Overlay $themed::active_fg $themed::trough\
                                          Inlay $themed::active_bg $themed::sel\
                                          Background $themed::bg $themed::insert_bg\
                                          Foreground $themed::fg $themed::disabled_fg\
                                          Highlight $themed::hl $themed::sel_fg\
                                          Hl-Background $themed::hl_bg $themed::sel_bg"

      # must init this to avoid potentially setting an empty inital color in the swatch.
      set ::dialog_theme::last_checked_checkbutton ".theme.labelframe.colbox_e_Background $themed::bg"

      toplevel $gfxstub -class DialogWindow
      $gfxstub configure -menu $::dialog_menubar -background $themed::bg

      labelframe $gfxstub.labelframe -text "Choose your palette"\
        -relief groove -padx 5 -pady 5 -labelanchor n -takefocus 1
      #really have no idea why this errors when used upon instantiation, so config
      #$gfxstub.labelframe configure -style ketea.TLabelframe

      button $gfxstub.save -text [_ "save"]\
        -command {dialog_theme::ok .theme}
      button $gfxstub.apply -text [_ "apply"]\
        -command {dialog_theme::apply .theme}
      button $gfxstub.cancel -text [_ "cancel"]\
        -command {dialog_theme::cancel .theme}
        # the gfxstub variable will have been unset, you have to be specific
        #   and say .theme for the command's argument ... i think

      set ::dialog_theme::row_iterator 1
      dialog_theme::add_theme_buttons $gfxstub.labelframe
      dialog_theme::create_hexcolors $gfxstub
      #check keybindings

      wm title $gfxstub [_ "Theme"]
      wm minsize $gfxstub 282 475
      wm maxsize $gfxstub 282 475
      wm resizable $gfxstub 0 0
        #unsure about this for the moment
      #wm transient $gfxstub
        #topmost is actually kinda annoying; reserve for important dialogs.
      #catch {wm attributes $gfxstub -topmost 1}
      #if {$::windowingsystem eq "x11"} {
      #  wm attributes $gfxstub -type dialog
      #}

      wm group $gfxstub .

      ::pd_bindings::dialog_bindings $gfxstub "theme"
      #not sure how the hidden menus this creates are being used to be honest.\
            Will peruse the c side.

      bind $gfxstub <KeyPress-Return> "::dialog_theme::ok $gfxstub"
      bind $gfxstub <KeyPress-Escape> "::dialog_theme::cancel $gfxstub"
      bind $gfxstub <$::modifier-Key-w> "::dialog_theme::cancel $gfxstub"
      wm protocol $gfxstub WM_DELETE_WINDOW "dialog_theme::cancel $gfxstub"

      # add this to bind maybe?
      # ; break

      grid $gfxstub.save -column 2 -columnspan 1 -row $::dialog_theme::row_iterator -ipadx 3 -pady 4 -sticky s
      grid $gfxstub.apply -column 1 -columnspan 1 -row $::dialog_theme::row_iterator -ipadx 2 -pady 4 -sticky s
      grid $gfxstub.cancel -column 0 -columnspan 1 -row $::dialog_theme::row_iterator -pady 4 -sticky s
      grid $gfxstub.labelframe -column 0 -columnspan 3 -row 0 -rowspan 3 -sticky new

      unset ::dialog_theme::row_iterator
      #grid anchor $gfxstub.labelframe center
      #grid anchor $gfxstub.apply w
      #grid anchor $gfxstub.cancel e

      # todo:  add sizegrip
         # test and configure weights
      #grid columnconfigure $gfxstub 0 -weight 1
      #grid columnconfigure $gfxstub 1 -weight 1
      #grid columnconfigure $gfxstub 2 -weight 1
      #grid columnconfigure $gfxstub 3 -weight 1
      #grid rowconfigure $gfxstub 0 -weight 0
      #grid rowconfigure $gfxstub 1 -weight 1
      #grid rowconfigure $gfxstub 2 -weight 1
      #grid rowconfigure $gfxstub 3 -weight 1
      #grid rowconfigure $gfxstub 4 -weight 0

      #raise $gfxstub
      #if {$::focused_window ne $gfxstub} {
      #  focus $gfxstub
      #}
      #tkwait window $gfxstub
    }
  }

  proc dialog_theme::configure_buttons_entries_and_canvases {mytoplevel} {
    #really shouldn't need anything but the canvas change.\
            think tk_setpalette is the problem, \
            option add won't configure existing widgets but tk_setpalette does.\
            maybe abstract away from themed::hl_bg?
    foreach window [winfo children $mytoplevel] {
      set class [winfo class $window]
      if {$class eq "Button"} {
        $window configure -foreground $themed::active_fg
        $window configure -highlightbackground $themed::bg
      } elseif {$class eq "Entry"} {
        $window configure -highlightbackground $themed::bg
      } elseif {$class eq "PatchWindow"} {
        themed::configure_upon_editmode $window
      }
      dialog_theme::configure_buttons_entries_and_canvases $window
    }
  }

  proc dialog_theme::apply {gfxstub} {
    set ::themed::active_fg [lindex [.theme.labelframe.colbox_e_Overlay configure -background] 4]
    set ::themed::active_bg [lindex [.theme.labelframe.colbox_e_Inlay configure -background] 4]
    set ::themed::bg [lindex [.theme.labelframe.colbox_e_Background configure -background] 4]
    set ::themed::fg [lindex [.theme.labelframe.colbox_e_Foreground configure -background] 4]
    set ::themed::hl [lindex [.theme.labelframe.colbox_e_Highlight configure -background] 4]
    set ::themed::hl_bg [lindex [.theme.labelframe.colbox_e_Hl-Background configure -background] 4]
      #edit^ and run_ mode
    set ::themed::trough [lindex [.theme.labelframe.colbox_r_Overlay configure -background] 4]
    set ::themed::sel [lindex [.theme.labelframe.colbox_r_Inlay configure -background] 4]
    set ::themed::insert_bg [lindex [.theme.labelframe.colbox_r_Background configure -background] 4]
    set ::themed::disabled_fg [lindex [.theme.labelframe.colbox_r_Foreground configure -background] 4]
    set ::themed::sel_fg [lindex [.theme.labelframe.colbox_r_Highlight configure -background] 4]
    set ::themed::sel_bg [lindex [.theme.labelframe.colbox_r_Hl-Background configure -background] 4]

    overwrite_pd_color_procs

    themed::configure_tk_palette
    themed::configure_the_backgrounds $themed::bg
    themed::configure_misc_options
    dialog_theme::configure_buttons_entries_and_canvases .
  }

  #---required placeholder procs---
  proc dialog_theme::cancel {gfxstub} {
    # called on window close
    # why is this used in other dialogs?  Why create a pd object?
    #if {$gfxstub ne ".pdwindow"} {
    #  pdsend "$gfxstub cancel"
    #}
    foreach {color e_val r_val} $dialog_theme::palette_colors {
      unset ::dialog_theme::check1_val_$color
      unset ::dialog_theme::check2_val_$color
    }
    unset dialog_theme::palette_colors
    unset dialog_theme::last_checked_checkbutton
    destroy $gfxstub
  }
  proc dialog_theme::ok {gfxstub} {
    dialog_theme::apply $gfxstub
    dialog_theme::save_palette_colors_to_file
    dialog_theme::cancel $gfxstub
  }
  #---required placeholder procs---

  .menubar.edit insert 9 command -label [_ "Theme"]\
    -command {dialog_theme::create_dialog .theme}

  dialog_theme::load_palette_colors_from_file
  bind all <$::modifier-Key-\'> {+dialog_theme::create_dialog .theme}
}

enact_theme_menu; #this must come before overwriting the procs, or they will have the wrong color in the pdwindow
overwrite_pd_color_procs
themed::configure_tk_palette
themed::configure_the_backgrounds $themed::bg
themed::configure_misc_options
bind PatchWindow <<EditMode>> {+themed::configure_upon_editmode %W}
      #r                                #e
    #themed::trough      "overlay"    themed::active_fg
    #themed::sel         "inlay"      themed::active_bg
    #themed::insert_bg   "background" themed::bg
    #themed::disabled_fg "foreground" themed::fg
    #themed::sel_fg      "Hl"         themed::hl
    #themed::sel_bg      "Hl-Bg"      themed::hl_bg
