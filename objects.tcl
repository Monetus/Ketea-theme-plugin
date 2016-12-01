package require pdtk_canvas

namespace eval autocomplete:: {
  variable draw_flag 0
  variable last_canvas ""
  variable current_text ""
  variable position 127
  variable current_object ""
  variable current_object_args ""
  variable x1
  variable x2
  variable y1
  variable tags ""
  variable objects [list\
    bang\
    float\
    symbol\
    int\
    send\
    receive\
    select\
    route\
    pack\
    unpack\
    trigger\
    spigot\
    moses\
    until\
    print\
    makefilename\
    change\
    swap\
    value\
    delay\
    metro\
    line\
    timer\
    cputime\
    realtime\
    pipe\
    mtof\
    ftom\
    powtodb\
    rmstodb\
    dbtopow\
    dbtorms\
    mod\
    div\
    sin\
    cos\
    tan\
    atan\
    atan2\
    sqrt\
    log\
    exp\
    abs\
    random\
    max\
    min\
    clip\
    notein\
    ctlin\
    pgmin\
    bendin\
    touchin\
    polytouchin\
    midiin\
    sysexin\
    noteout\
    ctlout\
    pgmout\
    bendout\
    touchout\
    polytouchout\
    midiout\
    makenote\
    stripnote\
    tabread\
    tabread4\
    tabwrite\
    soundfiler\
    loadbang\
    netsend\
    netreceive\
    qlist\
    openpanel\
    savepanel\
    bag\
    poly\
    key\
    keyup\
    keyname\
    clip~\
    wrap~\
    fft~\
    ifft~\
    rfft~\
    rifft~\
    framp~\
    mtof~\
    ftom~\
    rmstodb~\
    dbtorms~\
    dac~\
    adc~\
    sig~\
    line~\
    vline~\
    snapshot~\
    vsnapshot~\
    bang~\
    samplerate~\
    send~\
    receive~\
    throw~\
    {catch~}\
    block~\
    {switch~}\
    readsf~\
    writesf~\
    phasor~\
    cos~\
    osc~\
    tabwrite~\
    tabplay~\
    tabread~\
    tabread4~\
    tabosc4~\
    tabsend~\
    tabreceive~\
    vcf~\
    noise~\
    env~\
    hip~\
    lop~\
    bp~\
    biquad~\
    samphold~\
    print~\
    rpole~\
    rzero~\
    rzero_rev~\
    cpole~\
    czero~\
    delwrite~\
    delread~\
    table\
    inlet\
    outlet\
    inlet~\
    outlet~\
    struct\
    drawcurve\
    filledcurve\
    drawpolygon\
    filledpolygon\
    plot\
    drawnumber\
    drawsymbol\
    pointer\
    get\
    {set}\
    element\
    getsize\
    setsize\
    {append}\
    scalar\
    namecanvas\
    czero_rev~\
    threshold~\
    min~\
    max~\
    ==\
    !=\
    >\
    <\
    >=\
    <=\
    -\
    *\
    /\
    pow\
    +\
    &\
    &&\
    |\
    ||\
    %\
    +~\
    -~\
    *~\
    /~\
    declare\
    wrap\
    pow~\
    log~\
    exp~\
    abs~\
    {list}\
    {list append}\
    {list prepend}\
    {list split}\
    {list trim}\
    {list length}\
    {list fromsymbol}\
    {list tosymbol}\
    {array}\
    {array define}\
    {array size}\
    {array sum}\
    {array get}\
    {array set}\
    {array quantile}\
    {array random}\
    {array max}\
    {array min}\
    textfile\
    text\
    {text define}\
    {text get}\
    {text set}\
    {text delete}\
    {text size}\
    {text fromlist}\
    {text tolist}\
    {text search}\
    {text sequence}\
    <<\
    >>\
    sqrt~\
    oscparse\
    oscformat\
    sigmund~\
    bonk~\
    choice\
    hilbert~\
    {expr~}\
    {expr}\
    fexpr~\
    loop~\
    lrshift~\
    pd~\
    rev1~\
    rev2~\
    rev3~\
    stdout\
    bob~\
    clone\
    midirealtimein\
    midiclkin\
    delread4~\
    vd~\
    rsqrt~\
    q8_sqrt~\
    q8_rsqrt~\
  ]
  variable object_arguments [list\
    {}\
    {?float}\
    {?symbol}\
    {?integer}\
    {?name}\
    {name}\
    {?float||symbol...}\
    {?float||symbol...}\
    {?f||s||p...}\
    {?f||s||p...}\
    {b||f||s||p||a...}\
    {?integer}\
    {?float}\
    {}\
    {?name}\
    {format}\
    {?float}\
    {?float}\
    {?name}\
    {?time ?tempo ?unit}\
    {?time ?tempo ?unit}\
    {?float ?grain}\
    {?tempo ?unit}\
    {}\
    {}\
    {?time...}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?integer}\
    {?float}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?integer}\
    {?float}\
    {?float}\
    {?min ?max}\
    {?channel}\
    {?control ?channel}\
    {?channel}\
    {?channel}\
    {?channel}\
    {?channel}\
    {}\
    {}\
    {}\
    {?control ?channel}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?velocity ?duration}\
    {}\
    {?name}\
    {?name}\
    {?name}\
    {}\
    {}\
    {?-u ?-b}\
    {?-u ?-b ?port}\
    {}\
    {}\
    {}\
    {}\
    {?voices ?stealing}\
    {}\
    {}\
    {}\
    {?min ?max}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?channel...}\
    {?channel...}\
    {?float}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {name}\
    {?name}\
    {?name}\
    {name}\
    {?blocksize ?overlap ?up/downsampling}\
    {?blocksize ?overlap ?up/downsampling}\
    {?channels ?buffer}\
    {?channels}\
    {?frequency}\
    {}\
    {?frequency}\
    {?name}\
    {?name}\
    {?name}\
    {?name}\
    {?name}\
    {?name}\
    {?name}\
    {?frequency ?resonance}\
    {}\
    {?window ?period}\
    {?frequency}\
    {?frequency}\
    {?frequency ?resonance}\
    {?fb1 ?fb2 ?ff1 ?ff2 ?ff3}\
    {}\
    {?name}\
    {?float}\
    {?float}\
    {?float}\
    {?float ?float}\
    {?float ?float}\
    {?name ?time}\
    {?name ?time}\
    {?name ?size}\
    {?name}\
    {?name}\
    {?name}\
    {?name}\
    {?name ?type ?var...}\
    {?-n ?-v ?var ?-x rbg width x y...}\
    {?-n ?-v ?var ?-x rgb_in rbg_out width x y...}\
    {?-n ?-v ?var ?-x rbg width x y...}\
    {?-n ?-v ?var ?-x rbg_in rgb_out width x y...}\
    {?-n ?-v ?var ?-vs ?const||var ?-x ?-y ?-w ?curve name rbg x y spacing...}\
    {?-n ?-v ?var number x y rgb ?label}\
    {?-n ?-v ?var symbol x y rgb ?label}\
    {?template...}\
    {?template ?field...}\
    {?-symbol ?template ?field...}\
    {?template ?field...}\
    {?template ?field}\
    {?template ?field}\
    {?template ?field...}\
    {?define ?-k ?template ?name}\
    {name}\
    {?float ?float}\
    {?trigger ?ttime ?rest ?rtime}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {?float}\
    {(-path -stdpath -lib -stdlib) name}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?list}\
    {?list}\
    {?integer}\
    {}\
    {}\
    {}\
    {}\
    {}\
    {?-k ?name ?size}\
    {?-s ?-f ?name}\
    {?name ?onset ?points}\
    {?name ?onset ?points}\
    {?name}\
    {?name ?onset ?points}\
    {?name ?onset ?points}\
    {?name ?onset ?points}\
    {?name ?onset ?points}\
    {}\
    {}\
    {?-k name}\
    {?name ?onset ?points}\
    {?name||?-s template? ?line ?field}\
    {?name||?-s template?}\
    {?name||?-s template?}\
    {?name||?-s template?}\
    {?name||?-s template?}\
    {?name||?-s template ?operator ?field}\
    {?name||?-s template ?-g ?-w symbol||integer ?-t tempo units}\
    {integer}\
    {integer}\
    {}\
    {}\
    {?address...}\
    {?-t ?pitch ?notes ?env ?peaks ?tracks ?(-npts -hop -npeak -maxfreq -vibrato -stabletime -minpower -growth) <arg>}\
    {}\
    {?repetition}\
    {}\
    {?$v# ?$f# ?math ?array[index]}\
    {?$f# ?math ?array[index]}\
    {?$x[index] ?$y[index] ?math}\
    {}\
    {?shift}\
    {?-insig -outsig -sr -fifo? <integer> ?-pddir -scheddir? <path>}\
    {}\
    {?dB ?liveness ?frequency ?damping}\
    {?dB ?liveness ?frequency ?damping}\
    {}\
    {}\
    {?-s <arg> ?-x ?filename ?instances ?args...}\
    {}\
    {}\
    {?name}\
    {?name}\
    {}\
    {}\
    {}\
  ]

  # this highlights one past the end of the list.  fix or keep as a delete?.
  proc cycle_autocomplete_tags {} {
    if {$autocomplete::position < [llength $autocomplete::tags]} {
      $autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -fill $themed::active_bg
      incr autocomplete::position
    } else {
      set autocomplete::position 0
    }
    $autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -fill $themed::hl
    focus $autocomplete::last_canvas
  }

  proc blank {} {
    set mytoplevel [winfo toplevel $autocomplete::last_canvas]
    for {set characters_to_delete [expr {1+[string length $autocomplete::current_text]}]} \
        {$characters_to_delete > 0} \
        {incr characters_to_delete -1} {
          #backspace
          pdsend "$mytoplevel key 1 8 0"
    }
  }

  # write text into the object box
  proc rename_obj {text} {
    set mytoplevel [winfo toplevel $autocomplete::last_canvas]
    if {[string match *$autocomplete::current_object_args $text] && $autocomplete::current_object_args ne ""} {
      set text $autocomplete::current_object
    }
    set text_length [string length $text]
    #set number of draw commands to skip
    set autocomplete::draw_flag [expr {[string length $autocomplete::current_text]+$text_length}]
    #clear box
    autocomplete::blank
    set autocomplete::current_text $text
    #type into box
    for {set index 0} {$index < $text_length} {incr index} {
        set letter [string index $text $index]
        scan $letter %c keynum
        pdsend "$mytoplevel key 1 $keynum 0"
    }
    $autocomplete::last_canvas delete autobox
    $autocomplete::last_canvas delete autotext
  }

  proc rename_obj_via_return {} {
    if {$autocomplete::tags eq ""} {return}
    set selected_text \
      [lindex [$autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -text] 4]
    autocomplete::rename_obj $selected_text
  }

  proc rename_obj_via_click {} {
    set selected_text [lindex [$autocomplete::last_canvas itemconfigure current -text] 4]
    autocomplete::rename_obj $selected_text
  }

  proc hover_leave_color_check {} {
    if {[lindex [$autocomplete::last_canvas itemconfigure current -text] 4] ne [lindex [$autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -text] 4]} {
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


#overwrite ketea-theme-plugin's overwrite proc.
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
          negative to decr instead of incr
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
    # for some reason text_set is run after editing_text is set to zero.  So must check to skip the draw. \
      must also check to see if the text being edited is an obj and not a comment or label or something.
    if {!$::editingtext([winfo toplevel $tkcanvas]) || [lsearch -exact [$tkcanvas gettags [$tkcanvas find withtag $tag]] obj] eq -1} {return}
    if {$autocomplete::draw_flag eq 0} {
      set autocomplete::current_text $text
      set obj_names_indices [lsearch -glob -all $autocomplete::objects $text*]
      # I don't know why this returns null with less than 3 characters.  It doesn't in the console? wtf..
      # try to avoid redundant updates. add a comparison to check for a return here
      $tkcanvas delete autotext
      $tkcanvas delete autobox
      if {$autocomplete::current_object_args ne ""} {
        set draw_with_args_flag [string match "$autocomplete::current_object *" $autocomplete::current_text]
      } else {
        #boolean rather than -1
        set draw_with_args_flag 0
      }
      if {$obj_names_indices ne "" || $draw_with_args_flag} {
        set autocomplete::tags ""
        set y_iter 4
        set autobox_size 50
        if {$obj_names_indices eq ""} {
          set obj_and_args "$autocomplete::current_object $autocomplete::current_object_args"
          autocomplete::create_autotext $obj_and_args $y_iter
          incr y_iter $::dialog_font::fontsize
          set text_width [expr {[string length $obj_and_args] * int($::dialog_font::fontsize*0.75)}]
          if {$text_width > $autobox_size} {
            set autobox_size $text_width
          }
        }
        foreach obj_name_index $obj_names_indices {
          set obj_name [lindex $autocomplete::objects $obj_name_index]
          if {[string equal $obj_name $autocomplete::current_text]} {
            set autocomplete::current_object $obj_name
            set autocomplete::current_object_args [lindex $autocomplete::object_arguments $obj_name_index]
            append obj_name " $autocomplete::current_object_args"
          }
          set text_width [expr [string length $obj_name] * int($::dialog_font::fontsize*0.75)]
          if {$text_width > $autobox_size} {
            set autobox_size $text_width
          }
          autocomplete::create_autotext $obj_name $y_iter
          incr y_iter $::dialog_font::fontsize
        }
        autocomplete::create_autobox $autobox_size $y_iter
      }
    } else {
      #  this iterator is used to skip the drawing stuff during object renaming.
      # not sure its worth it though
      incr autocomplete::draw_flag -1
    }
  }

  proc pdtk_text_editing {mytoplevel tag editing} {
      set tkcanvas [tkcanvas_name $mytoplevel]
      set autocomplete::position 127
      if {$editing == 0} {
        $tkcanvas delete autobox
        $tkcanvas delete autotext
        set autocomplete::tags ""
        selection clear $tkcanvas
      } else {
        set autocomplete::last_canvas $tkcanvas
        # R for the obj instead of the text's width
        set coords [$tkcanvas bbox ${tag}R]
        set autocomplete::x1 [lindex $coords 0]
        set autocomplete::x2 [lindex $coords 2]
        set autocomplete::y1 [lindex $coords 3]
      }
      $tkcanvas focus $tag
      set ::editingtext($mytoplevel) $editing
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

  proc pdtk_canvas_new {mytoplevel width height geometry editable} {
      set l [pdtk_canvas_place_window $width $height $geometry]
      set width [lindex $l 0]
      set height [lindex $l 1]
      set geometry [lindex $l 2]

      # release the window grab here so that the new window will
      # properly get the Map and FocusIn events when its created
      ::pdwindow::busyrelease
      # set the loaded array for this new window so things can track state
      set ::loaded($mytoplevel) 0
      toplevel $mytoplevel -width $width -height $height -class PatchWindow
      wm group $mytoplevel .
      $mytoplevel configure -menu $::patch_menubar

      # we have to wait until $mytoplevel exists before we can generate
      # a <<Loading>> event for it, that's why this is here and not in the
      # started_loading_file proc.  Perhaps this doesn't make sense tho
      event generate $mytoplevel <<Loading>>

      wm geometry $mytoplevel $geometry
      wm minsize $mytoplevel $::canvas_minwidth $::canvas_minheight

      set tkcanvas [tkcanvas_name $mytoplevel]
      canvas $tkcanvas -width $width -height $height \
          -highlightthickness 0 -scrollregion [list 0 0 $width $height] \
          -xscrollcommand "$mytoplevel.xscroll set" \
          -yscrollcommand "$mytoplevel.yscroll set"
      scrollbar $mytoplevel.xscroll -orient horizontal -command "$tkcanvas xview"
      scrollbar $mytoplevel.yscroll -orient vertical -command "$tkcanvas yview"
      pack $tkcanvas -side left -expand 1 -fill both

      # for some crazy reason, win32 mousewheel scrolling is in units of
      # 120, and this forces Tk to interpret 120 to mean 1 scroll unit
      if {$::windowingsystem eq "win32"} {
          $tkcanvas configure -xscrollincrement 1 -yscrollincrement 1
      }

      ::pd_bindings::patch_bindings $mytoplevel

      # give focus to the canvas so it gets the events rather than the window
      focus $tkcanvas

      # let the scrollbar logic determine if it should make things scrollable
      set ::xscrollable($tkcanvas) 0
      set ::yscrollable($tkcanvas) 0

      # init patch properties arrays
      set ::editingtext($mytoplevel) 0
      set ::childwindows($mytoplevel) {}

      # this should be at the end so that the window and canvas are all ready
      # before this variable changes.
      set ::editmode($mytoplevel) $editable

      #autocomplete bindings - should be in pd_bindings but there is an unexplained error
      set autocomplete::last_canvas $tkcanvas
      $tkcanvas bind autotext <Enter> {+$autocomplete::last_canvas itemconfigure current -fill $themed::hl}
      $tkcanvas bind autotext <Leave> {+autocomplete::hover_leave_color_check}
      $tkcanvas bind autotext <ButtonPress-1> {+autocomplete::rename_obj_via_click}
      bind $tkcanvas <Tab> {+autocomplete::cycle_autocomplete_tags}
      bind $tkcanvas <KeyRelease-Return> {+autocomplete::rename_obj_via_return}
      # keyrelease so that the return is input before the obj is renamed
  }

  proc ::pd_menucommands::menu_aboutpd {} {
    # parse the textfile for the About Pd page
      set versionstring "Pd $::PD_MAJOR_VERSION.$::PD_MINOR_VERSION.$::PD_BUGFIX_VERSION$::PD_TEST_VERSION"
      set filename "$::sys_libdir/doc/1.manual/1.introduction.txt"
      if {[winfo exists .aboutpd]} {
          wm deiconify .aboutpd
          raise .aboutpd
      } else {
          toplevel .aboutpd -class TextWindow
          wm title .aboutpd [_ "About Pd"]
          wm group .aboutpd .
          .aboutpd configure -menu $::dialog_menubar
          text .aboutpd.text -relief flat -borderwidth 0 \
              -yscrollcommand ".aboutpd.scroll set" -background $themed::bg -selectforeground $themed::hl
          scrollbar .aboutpd.scroll -command ".aboutpd.text yview"
          pack .aboutpd.scroll -side right -fill y
          pack .aboutpd.text -side left -fill both -expand 1
          bind .aboutpd <$::modifier-Key-w>   "wm withdraw .aboutpd"

          set textfile [open $filename]
          while {![eof $textfile]} {
              set bigstring [read $textfile 1000]
              regsub -all PD_BASEDIR $bigstring $::sys_guidir bigstring2
              regsub -all PD_VERSION $bigstring2 $versionstring bigstring3
              .aboutpd.text insert end $bigstring3
          }
          close $textfile
      }
  }
}
