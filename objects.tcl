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
      $autocomplete::last_canvas itemconfigure [lindex $autocomplete::tags $autocomplete::position] -fill $themed::active_fg
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


  # this triggers for any text change. keep light.
set pdtk_text_set_args [info args pdtk_text_set]
set pdtk_text_set_body [info body pdtk_text_set]
append pdtk_text_set_body {
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
