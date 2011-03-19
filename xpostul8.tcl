#! /usr/bin/env wish8.5

##############################################
# eXpostulate - crossposting blog client and social network dashboard
# (c) tony baldwin / tony@baldwinsoftware.com / http://baldwinsoftware.com
# released according to the terms of the Gnu Public License, v. 3 or later
# further licensing details at the end of the code.

package require http

uplevel #0 [list source ~/.xpost/xpost.conf]

#############################
# I've been told that there are better ways to get stuff done
# than using tonso global variables.
# nonetheless, I'm about to name a whole herd of global variables:

global ljname
global ljpswd
global djpwsd
global djname
global ijname
global ijpswd
global dwname
global dwpswd
global wpname
global wppswd
global blgrname
global blgpswd
global filename
global brow
global wbg
global wtx
global post
global plength
global login
global lurl
global subject
global mood
global tunes
global tags
global year
global mon
global day
global hour
global min
global mood
global tunes
global tags
global ptext
global lprops
global usej
global usepic
global twname
global idname
global twpswd
global idpswd
global udate

set allvars [list txfg txbg brow wbg wtx ljname djname djpswd ljpswd ijname ijpswd dwname dwpswd twname idname twpswd idpswd udate novar]

set subject "subject"
set mood "mood"
set tags "enter, tags, here"
set tunes "music"
set usepic " "
set usej "which journal?"
set lurl " "
set udate "tweet, dent, status update"

set year [clock format [clock second] -format %Y]
set mon [clock format [clock seconds] -format %m]
set day [clock format [clock seconds] -format %d]
set hour [clock format [clock seconds] -format %H]
set min [clock format [clock seconds] -format %M]

set filename " "
set currentfile " "
set wrap word


font create font  -family fixed

set novar "cows"

set file_types {
{"All Files" * }
{"Text Files" { .txt .TXT}}
}

############33
# keybindings

bind . <Escape> leave
bind . <Control-z> {catch {.txt.txt edit undo}}
bind . <Control-r> {catch {.txt.txt edit redo}}
bind . <Control-a> {.txt.txt tag add sel 1.0 end}
bind . <F4> specialbox
bind . <F3> {FindPopup}
bind . <Control-s> {file_save}
bind . <Control-b> {file_saveas}
bind . <Control-o> {OpenFile}
bind . <Control-q> {clear}
bind . <F8> {prefs}
bind . <F7> {browz}
bind . <F5> {wordcount}

tk_setPalette background $::wbg foreground $::wtx

wm title . "eXp0stulate - x-posting blog client"

######3
# Menus
#################################

# menu bar buttons
frame .fluff -bd 1 -relief raised

tk::menubutton .fluff.mb -text File -menu .fluff.mb.f 
tk::menubutton .fluff.ed -text Edit -menu .fluff.ed.t 
tk::menubutton .fluff.ins -text Insert -menu .fluff.ins.t 
# tk::menubutton .fluff.pos -text Post -menu .fluff.pos.t
tk::menubutton .fluff.view -text View -menu .fluff.view.t
tk::label .fluff.font1 -text "Font size:" 
ttk::combobox .fluff.size -width 4 -value [list 8 10 12 14 16 18 20 22 24 28] -state readonly

bind .fluff.size <<ComboboxSelected>> [list sizeFont .txt.txt .fluff.size]

# file menu
#############################
menu .fluff.mb.f -tearoff 1
.fluff.mb.f add command -label "Open" -command {OpenFile} -accelerator Ctrl+o
.fluff.mb.f add command -label  "Save" -command {file_save} -accelerator Ctrl+s
.fluff.mb.f  add command -label "SaveAs" -command {file_saveas} -accelerator Ctrl-b
.fluff.mb.f add command -label "Clear" -command {clear} -accelerator Ctrl+q
.fluff.mb.f add separator
.fluff.mb.f  add command -label "Quit" -command {leave} -accelerator Escape


# edit menu
######################################3
menu .fluff.ed.t -tearoff 1
.fluff.ed.t add command -label "Cut" -command cut_text -accelerator Ctrl+x
.fluff.ed.t add command -label "Copy" -command copy_text -accelerator Ctrl+c
.fluff.ed.t add command -label "Paste" -command paste_text -accelerator Ctrl+v
.fluff.ed.t add command -label "Select all"	-command ".txt.txt tag add sel 1.0 end" -accelerator Ctrl+a
.fluff.ed.t add command -label "Undo" -command {catch {.txt.txt edit undo}} -accelerator Ctrl+z
.fluff.ed.t add command -label "Redo" -command {catch {.txt.txt edit redo}} -accelerator Ctrl+r
.fluff.ed.t add separator
.fluff.ed.t add command -label "Search/Replace" -command {FindPopup} -accelerator F3
.fluff.ed.t add separator
.fluff.ed.t add command -label "Word Count" -command {wordcount} -accelerator F5
.fluff.ed.t add command -label "Time Stamp" -command {indate}
.fluff.ed.t add command -label "Special Characters" -underline 0 -command specialbox -accelerator F4
.fluff.ed.t add separator
.fluff.ed.t add command -label "Preferences" -command {prefs} -accelerator F8


tk::button .fluff.help -text "Help" -command {help}
tk::button .fluff.abt -text "About" -command {about}


# inserts menu
###########################3
menu .fluff.ins.t -tearoff 1
.fluff.ins.t add command -label "LJ Cut" -command {cutin}
.fluff.ins.t add command -label "User" -command {userin}
.fluff.ins.t add command -label "Community" -command {commin}
.fluff.ins.t add command -label "Hyperlink" -command {linkin}

# post menu
###############################
# menu .fluff.pos.t -tearoff 1
# .fluff.pos.t add command -label "Livejournal" -command {ljpost}
# .fluff.pos.t add command -label "InsaneJournal" -command {ijpost}
# .fluff.pos.t add command -label "DreamWidth" -command {dwpost}
# .fluff.pos.t add command -label "WordPress" -command {wppost}
# .fluff.pos.t add command -label "Blogger" -command {blpost}

# view menu
####################################
menu .fluff.view.t -tearoff 1
.fluff.view.t add command -label "My InsaneJournal" -command {
    exec $::brow "http://$::ijname.insanejournal.com" &
}

.fluff.view.t add command -label "My LiveJournal" -command {
    exec $::brow "http://$::ljname.livejournal.com" &
}
.fluff.view.t add command -label "My DreamWidth" -command {
    exec $::brow "http://$::ljname.livejournal.com" &
}
.fluff.view.t add command -label "LiveJournal.com" -command {
    exec $::brow http://www.livejournal.com &
    }
.fluff.view.t add command -label "InsaneJournal.com" -command {
    exec $::brow http://www.insanejournal.com &
    }
.fluff.view.t add command -label "DreamWidth.com" -command {
    exec $::brow http://www.dreamwidth.com &
    }

#tk::label .fluff.lbl1 -text "Post to:"
#tk::button .fluff.plj -text "LJ" -command ljpost
#tk::button .fluff.pij -text "IJ" -command ijpost
#tk::button .fluff.pdw -text "DW" -command dwpost

# pack em in...
############################

pack .fluff.mb -in .fluff -side left
pack .fluff.ed -in .fluff -side left
pack .fluff.ins -in .fluff -side left
# pack .fluff.pos -in .fluff -side left
pack .fluff.view -in .fluff -side left
pack .fluff.font1 -in .fluff -side left
pack .fluff.size -in .fluff -side left
# pack .fluff.lbl1 -in .fluff -side left
# pack .fluff.plj -in .fluff -side left
# pack .fluff.pij -in .fluff -side left
# pack .fluff.pdw -in .fluff -side left
pack .fluff.help -in .fluff -side right
pack .fluff.abt -in .fluff -side right

pack .fluff -in . -fill x


# a few post parameters
###########################################
frame .ljo
grid [tk::label .ljo.sujet -text "Subject:"]\
[tk::entry .ljo.assunto -textvariable subject]\
[tk::label .ljo.tagz -text "Tags:"]\
[tk::entry .ljo.tagit -textvariable tags]

grid [tk::label .ljo.md -text "Current mood:"]\
[tk::entry .ljo.mude -textvariable mood]\
[tk::label .ljo.tunages -text "Current music:"]\
[tk::entry .ljo.tunez -textvariable tunes]\

frame .dt

grid [tk::label .dt.ol -text "Tweet/Dent:"]\
[tk::entry .dt.ent -width 50 -textvariable udate]\
[tk::button .dt.dt -text "Dent" -command "dent"]\
[tk::button .dt.tw -text "Tweet" -command "tweet"]\
[tk::button .dt.qt -text "Quit" -command {leave}]



pack .ljo -in . -fill x
pack .dt -in . -fill x

# Here is the text widget
########################################TEXT WIDGET
# amazingly simple, this part, considering the great power in this little widget...
# of course, that's because someone a lot smarter than me built the widget already.
# that sure was nice of them...

frame .txt -bd 2 -relief sunken
text .txt.txt -yscrollcommand ".txt.ys set" -xscrollcommand ".txt.xs set" -maxundo 0 -undo true -wrap word -bg $::txbg -fg $::txfg

scrollbar .txt.ys -command ".txt.txt yview"
scrollbar .txt.xs -command ".txt.txt xview" -orient horizontal

pack .txt.xs -in .txt -side bottom -fill x
pack .txt.txt -in .txt -side left -fill both -expand true

pack .txt.ys -in .txt -side left -fill y
pack .txt -in . -fill both -expand true

focus .txt.txt
set foco .txt.txt
bind .txt.txt <FocusIn> {set foco .txt.txt}


frame .lj1


# post buttons
###################
grid [tk::label .lj1.lbl1 -text "Post to:"]\
[tk::entry .lj1.uj -textvariable usej]\
[tk::label .lj1.oj -text "on:"]\
[tk::button .lj1.plj -text "LiveJournal" -command ljpost]\
[tk::button .lj1.pij -text "InsaneJournal" -command ijpost]\
[tk::button .lj1.pdj -text "DeadJournal" -command djpost]\
[tk::button .lj1.pdw -text "DreamWidth" -command dwpost]


pack .lj1 -in . -fill x

###
# font size, affects size of font in editor, not in post
# to affect font in post, you have to use html tags...sorry
# I should built that in.
########################################################

proc sizeFont {txt combo} {
	set font [$txt cget -font]
	font configure $font -size [list [$combo get]]
}


###
# open
############################

proc OpenFile {} {

if {$::filename != " "} {
	eval exec tcltext &
	} else {
	global filename
	set filename [tk_getOpenFile -filetypes $::file_types]
	wm title . "Now Tickling: $::filename"
	set data [open $::filename RDWR]
	.txt.txt delete 1.0 end
	while {![eof $data]} {
		.txt.txt insert end [read $data 1000]
		}
	close $data
	.txt.txt mark set insert 1.0
	}
}

##
# save & save-as
###########################

proc file_save {} {
	if {$::filename != " "} {
   set data [.txt.txt get 1.0 {end -1c}]
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
	} else {file_saveas}
 
}

proc file_saveas {} { 
global filename
set filename [tk_getSaveFile -filetypes $::file_types]
   set data [.txt.txt get 1.0 {end -1c}]
   wm title . "Now Tickling: $::filename"
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
}

# about message box
####################################ABOUT

proc about {} {

toplevel .about
wm title .about "About eXpostulate"
# tk_setPalette background $::wbg 

tk::message .about.t -text "eXpostulate\n by Tony Baldwin\n tony@baldwinsoftware.com\n A x-posting blogging client written in tcl/tk\n Released under the GPL\n For more info see README, or\n http://www.baldwinsoftware.com/xpost.html\n" -width 280
tk::button .about.o -text "Okay" -command {destroy .about} 
pack .about.t -in .about -side top
pack .about.o -in .about -side top

}

# find/replace/go to line
############################################FIND REPLACE DIALOG

proc FindPopup {} {

global seltxt repltxt

toplevel .fpop 

# -width 12c -height 4c

wm title .fpop "Find Stuff... (but not your socks)"

frame .fpop.l1 -bd 2 -relief raised

tk::label .fpop.l1.fidis -text "FIND     :"
tk::entry .fpop.l1.en1 -width 20 -textvariable seltxt
tk::button .fpop.l1.finfo -text "Forward" -command {FindWord  -forwards $seltxt}
tk::button .fpop.l1.finbk -text "Backward" -command {FindWord  -backwards $seltxt}
tk::button .fpop.l1.tagall -text "Highlight All" -command {TagAll}

pack .fpop.l1.fidis -in .fpop.l1 -side left
pack .fpop.l1.en1 -in .fpop.l1 -side left
pack .fpop.l1.finfo -in .fpop.l1 -side left
pack .fpop.l1.finbk -in .fpop.l1 -side left
pack .fpop.l1.tagall -in .fpop.l1 -side left
pack .fpop.l1 -in .fpop -fill x


frame .fpop.l2 -bd 2 -relief raised

tk::label .fpop.l2.redis -text "REPLACE:"
tk::entry .fpop.l2.en2 -width 20 -textvariable repltxt
tk::button .fpop.l2.refo -text "Forward" -command {ReplaceSelection -forwards}
tk::button .fpop.l2.reback -text "Backward" -command {ReplaceSelection -backwards}
tk::button .fpop.l2.repall -text "Replace All" -command {ReplaceAll}

pack .fpop.l2.redis -in .fpop.l2 -side left
pack .fpop.l2.en2 -in .fpop.l2 -side left
pack .fpop.l2.refo -in .fpop.l2 -side left
pack .fpop.l2.reback -in .fpop.l2 -side left
pack .fpop.l2.repall -in .fpop.l2 -side left
pack .fpop.l2 -in .fpop -fill x

frame .fpop.l3 -bd 2 -relief raised

tk::label .fpop.l3.goto -text "Line No. :"
tk::entry .fpop.l3.line -textvariable lino
tk::button .fpop.l3.now -text "Go" -command {gotoline}
tk::button .fpop.l3.dismis -text Done -command {destroy .fpop}

pack .fpop.l3.goto -in .fpop.l3 -side left
pack .fpop.l3.line -in .fpop.l3 -side left
pack .fpop.l3.now -in .fpop.l3 -side left
pack .fpop.l3.dismis -in .fpop.l3 -side right
pack .fpop.l3 -in .fpop -fill x


# focus .fpop.en1
}
########################FIND/REPLACE#########
## all this find-replace stuff needs work...
#############################################

proc FindWord {swit seltxt} {
global found
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
scan [.txt.txt index insert] %d cl
if {[string compare $swit "-forwards"] == 0 } {
set curpos [.txt.txt index "insert + $l1 chars"]

for {set i $cl} {$i < $nl} {incr i} {
		
	#.txt.txt mark set first $i.0
	.txt.txt mark set last  $i.end ;#another way "first lineend"
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search $swit -exact $seltxt $curpos]
	if {$curpos != ""} {
		selection clear .txt.txt 
		.txt.txt mark set insert "$curpos + $l1 chars "
		.txt.txt see $curpos
		set found 1
		break
		} else {
		set curpos $lpos
		set found 0
			}
	}
} else {
	set curpos [.txt.txt index insert]
	set i $cl
	.txt.txt mark set first $i.0
	while  {$i >= 1} {
		
		set fpos [.txt.txt index first]
		set i [expr $i-1]
		
		set curpos [.txt.txt search $swit -exact $seltxt $curpos $fpos]
		if {$curpos != ""} {
			selection clear .txt.txt
			.txt.txt mark set insert $curpos
			.txt.txt see $curpos
			set found 1
			break
			} else {
				.txt.txt mark set first $i.0
				.txt.txt mark set last "first lineend"
				set curpos [.txt.txt index last]
				set found 0
			}
		
	}
}
}

proc FindSelection {swit} {

global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
FindWord $swit $seltxt
}

proc FindValue {} {

FindPopup
}

proc TagSelection {} {
global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
TagAll 
}

proc ReplaceSelection {swit} {
global repltxt seltxt found
set l1 [string length $seltxt]
FindWord $swit $seltxt
if {$found == 1} {
	.txt.txt delete insert "insert + $l1 chars"
	.txt.txt insert insert $repltxt
	}
}

proc ReplaceAll {} {
global seltxt repltxt
set l1 [string length $seltxt]
set l2 [string length $repltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index 1.0]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
	
	if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		.txt.txt delete insert "insert + $l1 chars"
		.txt.txt insert insert $repltxt
		.txt.txt mark set insert "insert + $l2 chars"
		set curpos [.txt.txt index insert]
		} else {
			set curpos $lpos
			}
	}
}

proc TagAll {} {
global seltxt 
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index insert]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
		if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		scan [.txt.txt index "insert + $l1 chars"] %f pos
		.txt.txt tag add $seltxt $curpos $pos
		.txt.txt tag configure $seltxt -background yellow -foreground purple
		.txt.txt mark set insert "insert + $l1 chars"
		set curpos $pos
		} else {
			set curpos $lpos
			}
	}
}

###THEMES
######COLORPROCS
##############################################
# set text widget colors
#######################
 proc tback {} {
    global i
    set color [tk_chooseColor -initialcolor [.txt.txt cget -bg]]
    if {$color != ""} {.txt.txt configure -bg $color}
    set ::txbg $color    
 }
 
 proc tfore {} {
    global i
    set color [tk_chooseColor -initialcolor [.txt.txt cget -fg]]
    if {$color != ""} {.txt.txt configure -fg $color}
    set ::txfg $color    
 }

# set window color
################################

proc winback {} {
	global wbg
    set wbg [tk_chooseColor -initialcolor $::wbg]
    if {$wbg != ""} {tk_setPalette background $wbg}
    set $::wbg $wbg

 }

#set window font color
###################################

proc wintex {} {

	global wtx
    set wtx [tk_chooseColor -initialcolor $::wtx]
    if {$wtx != ""} {tk_setPalette background $::wbg foreground $wtx}
    set $::wtx $wtx

 }

# special character box
# largely borrowed from David "Pa" McClamrock's SuperNotepad
################################################################

global charlist
set charlist [list \
	"¡" "¢" "£" "¤" "¥" \
	"¦" "§" "¨" "©" "ª" \
	"«" "¬" "­" "®" "¯" \
	"°" "±" "²" "³" "´" \
	"µ" "¶" "·" "¸" "¹" \
	"º" "»" "¼" "½" "¾" \
	"¿" "À" "Á" "Â" "Ã" \
	"Ä" "Å" "Æ" "Ç" "È" \
	"É" "Ê" "Ë" "Ì" "Í" \
	"Î" "Ï" "Ð" "Ñ" "Ò" \
	"Ó" "Ô" "Õ" "Ö" "×" \
	"Ø" "Ù" "Ú" "Û" "Ü" \
	"Ý" "Þ" "ß" "à" "á" \
	"â" "ã" "ä" "å" "æ" \
	"ç" "è" "é" "ê" "ë" \
	"ì" "í" "î" "ï" "ñ" \
	"ò" "ó" "ô" "õ" "ö" \
	"÷" "ø"	"ù" "ú" "û" \
	"ü" "ý" "þ" "ÿ"]


# Procedure for finding correct text or entry widget
# and inserting special (or non-special) characters:
########################################################33

proc findwin {char} {
	global foco
	set winclass [winfo class $foco]
	$foco insert insert $char
	if {$winclass == "Text"} {
		$foco edit separator
		}
	after 10 {focus $foco}
}

###########################################################################################
# Procedure for setting up special-character selection box (borrowed from supernotepad by David "Pa" McClamrock)

proc range {start cutoff finish {step 1}} {
	
	# "Step" has to be an integer, and
	# no infinite loops that go nowhere are allowed:
	if {$step == 0 || [string is integer -strict $step] == 0} {
		error "range: Step must be an integer other than zero"
	}
	
	# Does the range include the last number?
	switch $cutoff {
		"to" {set inclu 1}
		"no" {set inclu 0}
		default {
			error "range: Use \"to\" for an inclusive range,\
			or \"no\" for a noninclusive range"
		}
	}
		
	# Is the range ascending or descending (or neither)?
	set ascendo [expr $finish - $start]
	if {$ascendo > -1} {
		set up 1
	} else {
		set up 0
	}
	
	# If range is descending and step is positive but doesn't have a "+" sign,
	# change step to negative:
	if {$up == 0 && $step > 0 && [string first "+" $start] != 0} {
		set step [expr $step * -1]
	}
	
	set ranger [list] ; # Initialize list variable for generated range
	switch "$up $inclu" {
		"1 1" {set op "<=" ; # Ascending, inclusive range}
		"1 0" {set op "<" ; # Ascending, noninclusive range}
		"0 1" {set op ">=" ; # Descending, inclusive range}
		"0 0" {set op ">" ; # Descending, noninclusive range}
	}
	
	# Generate a list containing the specified range of integers:
	for {set i $start} "\$i $op $finish" {incr i $step} {
		lappend ranger $i
	}
	return $ranger
}


set specialbutts [list]

#  This special box was borrowed from Pa McClamrock's Supernotepad.

proc specialbox {} {
	global charlist foco buttlist
	toplevel .spec
	wm title .spec "Special"
	set bigfons -adobe-helvetica-bold-r-normal--14-*-*-*-*-*-*
	set row 0
	set col 0
	foreach c [range 0 no [llength $charlist]] {
		set chartext [lindex $charlist $c]
		grid [button .spec.but($c) -text $chartext -font $bigfons \
			-pady 1 -padx 2 -borderwidth 1] \
			-row $row -column $col -sticky news
			bind .spec.but($c) <Button-1> {
			set butt %W
			set charx [$butt cget -text]
			findwin $charx
		}
		incr col
		if {$col > 4} {
			set col 0
			incr row
		}
	}
		
	grid [button .spec.amp -text "&"] -row $row -column 4 -sticky news
	bind .spec.amp <Button-1> {findwin "&amp;"}
	
	set bigoe_data "
	#define bigoe_width 17
	#define bigoe_height 13
	static unsigned char bigoe_bits[] = {
		0xf8, 0xfe, 0x01, 0xfe, 0xff, 0x01, 0xcf, 0x07, \
		0x00, 0x87, 0x07, 0x00, 0x07, 0x07, 0x00, 0x07, \
		0x3f, 0x00, 0x07, 0x3f, 0x00, 0x07, 0x07, 0x00, \
		0x07, 0x07, 0x00, 0x07, 0x07, 0x00, 0x8e, 0x07, \
		0x00, 0xfc, 0xff, 0x01, 0xf8, 0xfe, 0x01 };"
	image create bitmap bigoe -data $bigoe_data
	grid [button .spec.oebig -image bigoe \
		-pady 1 -padx 2 -borderwidth 1] \
		-row [expr $row+1] -column 0 -sticky news
	bind .spec.oebig <Button-1> {findwin "&#140;"}
	
	set liloe_data "
	#define liloe_width 13
	#define liloe_height 9
	static unsigned char liloe_bits[] = {
		0xbc, 0x07, 0xfe, 0x0f, 0xc3, 0x18, 0xc3, 0x18, \
		0xc3, 0x1f, 0xc3, 0x00, 0xe7, 0x18, 0xfe, 0x0f, \
		0x3c, 0x07 };"
	image create bitmap liloe -data $liloe_data
	grid [button .spec.oelil -image liloe -pady 1 \
		-pady 1 -padx 2 -borderwidth 1] \
		-row [expr $row+1] -column 1 -sticky news
	bind .spec.oelil <Button-1> {findwin "&#156;"}
	
	grid [button .spec.lt -text "<"] \
		-row [expr $row+1] -column 2 -sticky news
	bind .spec.lt <Button-1> {findwin "&lt;"}
	grid [button .spec.gt -text ">"] \
		-row [expr $row+1] -column 3 -sticky news
	bind .spec.gt <Button-1> {findwin "&gt;"}
	grid [button .spec.quot -text "\""] \
		-row [expr $row+1] -column 4 -sticky news
	bind .spec.quot <Button-1> {findwin "&quot;"}
	grid [button .spec.nbsp -text " "] \
		-row [expr $row+2] -column 0 -columnspan 2 -sticky news
	bind .spec.nbsp <Button-1> {findwin "&nbsp;"}
	grid [button .spec.close -text "Close" \
		-command {destroy .spec}] -row [expr $row+2] \
		-column 2 -columnspan 3 -sticky news
	foreach butt [list .spec.oebig .spec.oelil .spec.nbsp .spec.amp \
		.spec.lt .spec.gt .spec.quot .spec.close] {
		$butt configure -pady 1 -padx 2 -borderwidth 1
			
	}
}


## go to line number 

proc gotoline {} {
	set newlineno [.fpop.l3.line get]
	.txt.txt mark set insert $newlineno.0
	.txt.txt see insert
	focus .txt.txt
	set foco .txt.txt
}


## show word count

proc wordcount {} {
	set wordsnow [.txt.txt get 1.0 {end -1c}]
	set wordlist [split $wordsnow]
	set countnow 0
	foreach item $wordlist {
		if {$item ne ""} {
			incr countnow
		}
	}
	toplevel .count
	wm title .count "Word Count"
	tk::label .count.word -text "Current count:"
	tk::label .count.show -text "$countnow words"
	tk::button .count.ok -text "Okay" -command {destroy .count}
	
	pack .count.word -in .count -side top
	pack .count.show -in .count -side top
	pack .count.ok -in .count -side top
}


## insert time stamp

proc indate {} {
	if {![info exists date]} {set date " "}
	set date [clock format [clock seconds] -format "%R %p %D"]
	.txt.txt insert insert $date
}

proc userin {} {
.txt.txt insert insert "<lj user=\"put name here\"> "
}

proc commin {} {
.txt.txt insert insert "<lj comm=\"put name here\"> "
}

proc cutin {} {
.txt.txt insert insert "<lj-cut text=\"put text here\"> "
}

proc linkin {} {
.txt.txt insert insert "<a href=\"put link here\">put text here</a>"
}

# b'bye (quit procedure)
##################################

proc leave {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
		{file_save} 
		{exit}
				}
	if {$xanswer eq "no"} {exit}
		} else {exit}
}


## clear text widget / close document
#########################################

proc clear {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
	{file_save} 
	{yclear}
		}
	if {$xanswer eq "no"} {yclear}
	}
}

proc yclear {} {
	.txt.txt delete 1.0 end
	.txt.txt edit reset
	.txt.txt edit modified 0
	set ::filename " "
	wm title . "eXp0stulate"
}

# open html in browser
###########################################

proc browz {} {
	global brow
	if {$brow != " "} {
	eval exec $::brow http://www.livejourna.com &
	} else {
	tk_messageBox -message "You have not chosen a browser.\nLet's set the browser now." -type ok -title "Set browser"
	set brow [tk_getOpenFile -filetypes $::file_types]
	{browz}
	}
}


proc sapro {} {
	set novar "cows"
	set header "#!/usr/bin/env wish8.5 "
   	set filename ~/.xpost/xpost.conf
   	set fileid [open $filename w]
   	puts $fileid $header
   	foreach var $::allvars {puts $fileid [list set $var [set ::$var]]}
   	close $fileid
   	
   	 tk_messageBox -message "Preferences saved" 
} 

proc setbro {} {
set filetypes " "
set ::brow [tk_getOpenFile -filetypes $filetypes -initialdir "/usr/bin"]
}


######################
#  global preferences


proc prefs {} {

toplevel .pref

wm title .pref "eXp0stulate preferences"


grid [tk::label .pref.lbl -text "Set global preferences here"]



grid [tk::button .pref.fc -text "Font Color" -command {tfore}]\
[tk::button .pref.bc -text "Text Background" -command {tback}]\
[tk::button .pref.wc -text "Window Color" -command {winback}]\
[tk::button .pref.wt -text "Window Text" -command {wintex}]


grid [tk::button .pref.bro -text "Set Browser" -command {setbro}]\
[tk::entry .pref.br0z -textvariable brow]

grid [tk::label .pref.ljo -text "LiveJournal settings:"]

grid [tk::label .pref.ljn -text "LJ Username:"]\
[tk::entry .pref.ljnome -textvariable ljname]\
[tk::label .pref.ljp -text "LJ password:"]\
[tk::entry .pref.ljpw -show * -textvariable ljpswd]

grid [tk::label .pref.ijo -text "InsaneJournal settings:"]

grid [tk::label .pref.ijn -text "ij Username:"]\
[tk::entry .pref.ijnome -textvariable ijname]\
[tk::label .pref.ijp -text "ij password:"]\
[tk::entry .pref.ijpw -show * -textvariable ijpswd]

grid [tk::label .pref.djn -text "dj Username:"]\
[tk::entry .pref.djnome -textvariable djname]\
[tk::label .pref.djp -text "dj password:"]\
[tk::entry .pref.djpw -show * -textvariable djpswd]

grid [tk::label .pref.dwo -text "Dreamwidth settings:"]

grid [tk::label .pref.dwn -text "dw Username:"]\
[tk::entry .pref.dwnome -textvariable dwname]\
[tk::label .pref.dwp -text "dw password:"]\
[tk::entry .pref.dwpw -show * -textvariable dwpswd]

grid [tk::label .pref.ddo -text "Identi.ca settings:"]

grid [tk::label .pref.idn -text "Id Username:"]\
[tk::entry .pref.idnome -textvariable idname]\
[tk::label .pref.idpp -text "Id password:"]\
[tk::entry .pref.idpw -show * -textvariable idpswd]

grid [tk::label .pref.ttwo -text "Twitter settings:"]

grid [tk::label .pref.twn -text "Tw Username:"]\
[tk::entry .pref.twnome -textvariable twname]\
[tk::label .pref.twp -text "Tw password:"]\
[tk::entry .pref.twpw -show * -textvariable twpswd]

grid [tk::button .pref.sv -text "Save Preferences" -command sapro]\
[tk::button .pref.ok -text "OK" -command {destroy .pref}]


}





################
# post to insanejournal...

proc ijpost {} {

set ptext [.txt.txt get 1.0 {end -1c}]

set login [::http::formatQuery mode login user $::ijname password $::ijpswd ]
set log [http::geturl http://www.insanejournal.com/interface/flat:80 -query $login]
    
set post [::http::formatQuery mode postevent auth_method clear user $::ijname password $::ijpswd subject $::subject year $::year mon $::mon day $::day hour $::hour min $::min prop_current_music $::tunes prop_current_mood $::mood prop_taglist $::tags usejournal $::usej event $ptext ]
set plength [string length $post]
set dopost [http::geturl http://www.insanejournal.com/interface/flat:80 -query $post]
set ljmta [http::meta $dopost]
set ljl [http::size $dopost]
set ljstat [http::status $dopost]

toplevel .rsp 
wm title .rsp "Post Status"
grid [tk::label .rsp.lbl -text "Tweak says: $ljstat\nPost length: $ljl"]
grid [tk::button .rsp.view -text "View Journal" -command {
    set ijv "http://$::usej.insanejournal.com"
    exec $::brow $ijv &
}]\
[tk::button .rsp.ok -text "DONE" -command {destroy .rsp}]

}

################
# post to deadjournal...

proc djpost {} {

set ptext [.txt.txt get 1.0 {end -1c}]

set login [::http::formatQuery mode login user $::ijname password $::ijpswd ]
set log [http::geturl http://www.deadjournal.com/interface/flat:80 -query $login]
    
set post [::http::formatQuery mode postevent auth_method clear user $::djname password $::djpswd subject $::subject year $::year mon $::mon day $::day hour $::hour min $::min prop_current_music $::tunes prop_current_mood $::mood prop_taglist $::tags usejournal $::usej event $ptext ]
set plength [string length $post]
set dopost [http::geturl http://www.deadjournal.com/interface/flat:80 -query $post]
set ljmta [http::meta $dopost]
set ljl [http::size $dopost]
set ljstat [http::status $dopost]

toplevel .rsp 
wm title .rsp "Post Status"
grid [tk::label .rsp.lbl -text "Death says: $ljstat\nPost length: $ljl"]
grid [tk::button .rsp.view -text "View Journal" -command {
    set djv "http://$::usej.deadjournal.com"
    exec $::brow $djv &
}]\
[tk::button .rsp.ok -text "DONE" -command {destroy .rsp}]

}


################
# post to dreamwidth...

proc dwpost {} {

set ptext [.txt.txt get 1.0 {end -1c}]

set login [::http::formatQuery mode login user $::dwname password $::dwpswd ]
set log [http::geturl http://www.dreamwidth.org/interface/flat:80 -query $login]
    
set post [::http::formatQuery mode postevent auth_method clear user $::dwname password $::dwpswd subject $::subject year $::year mon $::mon day $::day hour $::hour min $::min prop_current_music $::tunes prop_current_mood $::mood prop_taglist $::tags usejournal $::usej event $ptext ]
set plength [string length $post]
set dopost [http::geturl http://www.dreamwidth.org/interface/flat:80 -query $post]
set ljmta [http::meta $dopost]
set ljl [http::size $dopost]
set ljstat [http::status $dopost]

toplevel .rsp 
wm title .rsp "Post Status"
grid [tk::label .rsp.lbl -text "The dream voice says: $ljstat\nPost length: $ljl"]
grid [tk::button .rsp.view -text "View Journal" -command {
    set dwv "http://$::usej.dreamwidth.org"
    exec $::brow $dwv &
}]\
[tk::button .rsp.ok -text "DONE" -command {destroy .rsp}]

}

################
# post to livejournal...

proc ljpost {} {
    
set ptext [.txt.txt get 1.0 {end -1c}]
set login [::http::formatQuery mode login user $::ljname password $::ljpswd ]
set log [http::geturl http://www.livejournal.com/interface/flat:80 -query $login]
    
set post [::http::formatQuery mode postevent auth_method clear user $::ljname password $::ljpswd subject $::subject year $::year mon $::mon day $::day hour $::hour min $::min prop_current_music $::tunes prop_current_mood $::mood prop_taglist $::tags usejournal $::usej event $ptext ]
set plength [string length $post]
set dopost [http::geturl http://www.livejournal.com/interface/flat:80 -query $post]
set ljmta [http::meta $dopost]
set ljl [http::size $dopost]
set ljstat [http::status $dopost]

toplevel .rsp 
wm title .rsp "Post Status"
grid [tk::label .rsp.lbl -text "Frank says: $ljstat\nPost length: $ljl"]
grid [tk::button .rsp.view -text "View Journal" -command {
    set ljv "http://$::usej.livejournal.com"
    exec $::brow $ljv &
}]\
[tk::button .rsp.ok -text "DONE" -command {destroy .rsp}]

}

#####################################
# Help dialog
proc help {} {
toplevel .help
wm title .help "eXp0stulate help"

frame .help.bt
grid [tk::button .help.bt.out -text "Okay" -command {destroy .help}]\
[tk::button .help.bt.vt -text "visit baldwinsoftware.com" -command {
set tlj "http://www.baldwinsoftware.com/"
exec $::brow $tlj &}]

frame .help.t

text .help.t.inf -width 80 -height 20
.help.t.inf insert end "eXp0stulate, a FREE and ticklish blogging client.\nBlog posting with eXp0stulate is pretty basic, at this juncture.\nMore features coming soon.\nFill in the fields, as described, which should be self-explanatory.\nChanging the font size in the editor is for your viewing pleasure,\nand won't affect your post (use html tags for that).\nThe 'View Journal' menu on the main interface will open your journal,\nthe button on the post response will open the journal to which you just posted,\nwhether yours, or a shared journal or community.\n\nMy IJ is http://tonybaldwin.insanejournal.com\nMy LJ is http://tonytraductor.livejourna.com\nMy DreamWidth is http://tonybaldwin.dreamwidth.org\nIf you have questions about how eXp0stulate works, feel free to e-mail me at\ntony@baldwinsoftware.com\nor join the baldwinsoftware.com/forum or googlegroups\nfurther info at http://baldwinsoftware.com/xpost.html"

pack .help.bt -in .help -side top
pack .help.t -in .help -side top
pack .help.t.inf -in .help.t -fill x

}

# status updates to identi.ca
##################################
proc dent {} {
	if { [string length $::udate] > 140 } {
		toplevel .babbler 
		wm title .babbler "You talk too much!"
		tk::message .babbler.msg -text "Your updates is too long.\nIt can only have 164 characters,\nthere, smarty pants." -width 270
		tk::button .babbler.btn -text "Okay" -command {destroy .babbler} 
		pack .babbler.msg -in .babbler -side top
		pack .babbler.btn -in .babbler -side top
		} else {
		exec curl -u $::idname:$::idpswd -d status="$::udate" http://identi.ca/api/statuses/update.xml
	}
}

# status updates to twitter.com
#####################################
proc tweet {} {
	if { [string length $::udate] > 140 } {
		toplevel .babbler 
		wm title .babbler "You talk too much!"
		tk::message .babbler.msg -text "Your updates is too long.\nIt can only have 140 characters,\nthere, smarty pants." -width 270
		tk::button .babbler.btn -text "Okay" -command {destroy .babbler} 
		pack .babbler.msg -in .babbler -side top
		pack .babbler.btn -in .babbler -side top
		} else {
		exec curl -u $::twname:$::twpswd -d status="$::udate" http://twitter.com/statuses/update.xml
	}
}

#############################################################################
# This program was written by Anthony Baldwin / http://baldwinsoftware.com/tonyb
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#########
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#########
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
############################################################################
