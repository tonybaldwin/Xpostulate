#! /usr/bin/env wish8.5

##############################################
# Xpostulate - crossposting blog client and social network dashboard
# (c) tony baldwin / tony@baldwinsoftware.com / http://baldwinsoftware.com
# released according to the terms of the Gnu Public License, v. 3 or later
# further licensing details at the end of the code.

package require http
package require base64

uplevel #0 [list source ~/.xpost/xpost.conf]

#############################
# I've been told that there are better ways to get stuff done
# than using tonso global variables.
# nonetheless, I'm about to name a whole herd of global variables:

global tagsc
global tube
global tbname
global tbpswd
global wpname
global wppswd
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
global sname
global spswd
global udate
global loc
global priv
global cats
global cwpurl
global cwpname
global cwppass
global furl
global fname
global fpwrd

set allvars [list furl fname fpwrd surl spswd txfg txbg brow wbg wtx cwpurl cwpname cwppass wpname wppswd ljname djname djpswd ljpswd ijname ijpswd dwname dwpswd sname udate loc priv tube tbname tbpswd novar]

set tagsc "0"
set subject "subject"
set mood "mood"
set tags "enter, tags, here"
set tunes "music"
set usepic " "
set usej "which journal?"
set lurl " "
set udate "status.net update"
set loc "127.0.0.1"
set cats "unfiled"

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
{"Xposts" {.post}}
{"html, xml" {.html .HTML .xml .XML}}
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

wm title . "Xpostulate - x-posting blog client"

######3
# Menus
#################################

# menu bar buttons
frame .fluff -bd 1 -relief raised

tk::menubutton .fluff.mb -text File -menu .fluff.mb.f 
tk::menubutton .fluff.ed -text Edit -menu .fluff.ed.t 
tk::menubutton .fluff.ins -text Insert -menu .fluff.ins.t 
tk::menubutton .fluff.bb -text BBcode -menu .fluff.bb.t
tk::menubutton .fluff.view -text View -menu .fluff.view.t
tk::label .fluff.font1 -text "Font size:" 
ttk::combobox .fluff.size -width 4 -value [list 8 10 12 14 16 18 20 22] -state readonly

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
.fluff.ed.t add command -label "convert <tags>" -command {fixtags}
.fluff.ed.t add separator
.fluff.ed.t add command -label "Word Count" -command {wordcount} -accelerator F5
.fluff.ed.t add separator
.fluff.ed.t add command -label "Preferences" -command {prefs} -accelerator F8


tk::button .fluff.help -text "Help" -command {help}
tk::button .fluff.abt -text "About" -command {about}


# inserts menu
###########################3
menu .fluff.ins.t -tearoff 1
.fluff.ins.t add command -label "LJ Cut" -command {cutin}
.fluff.ins.t add command -label "LJ User" -command {userin}
.fluff.ins.t add command -label "Community" -command {commin}
.fluff.ins.t add command -label "Hyperlink" -command {linkin}
.fluff.ins.t add command -label "DW User" -command {userdw}
.fluff.ins.t add command -label "DW Cut" -command {cutdw} 
.fluff.ins.t add separator
.fluff.ins.t add command -label "Ruler" -command {hrin}
.fluff.ins.t add command -label "BlockQuote" -command {bquote}
.fluff.ins.t add command -label "LineBreak" -command {bne}
.fluff.ins.t add separator
.fluff.ins.t add command -label "Time Stamp" -command {indate}
.fluff.ins.t add command -label "Special Characters" -underline 0 -command specialbox -accelerator F4

# bbcode menu
##################
menu .fluff.bb.t -tearoff 1
.fluff.bb.t add command -label "Link" -command {bblink}
.fluff.bb.t add command -label "Image" -command {bimg}
.fluff.bb.t add command -label "E-mail" -command {bmail}
.fluff.bb.t add command -label "Friendika" -command {bfren}
.fluff.bb.t add command -label "Youtube" -command {ytube}
.fluff.bb.t add command -label "BlockQuote" -command {bquote}
.fluff.bb.t add command -label "CodeBlock" -command {bcode}
.fluff.bb.t add command -label "Time Stamp" -command {indate}


# view menu
####################################
menu .fluff.view.t -tearoff 1

.fluff.view.t add command -label "My WordPress" -command {
    exec $::brow http://$::wpname.wordpress.com &
    }
    
.fluff.view.t add command -label "My InsaneJournal" -command {
    exec $::brow "http://$::ijname.insanejournal.com" &
}

.fluff.view.t add command -label "My LiveJournal" -command {
    exec $::brow "http://$::ljname.livejournal.com" &
}
.fluff.view.t add command -label "My DreamWidth" -command {
    exec $::brow "http://$::dwname.livejournal.com" &
}
.fluff.view.t add command -label "My Deadjournal" -command {
    exec $::brow "http://$::djname.deadjournal.com" &
}

.fluff.view.t add command -label "My Tumblr.com" -command {
    exec $::brow http://$::tbname.tumblr.com &
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
    .fluff.view.t add command -label "Deadjournal.com" -command {
    exec $::brow "http://www.deadjournal.com" &
}
    
.fluff.view.t add command -label "Tumblr.com" -command {
    exec $::brow http://www.tumblr.com &
    }

.fluff.view.t add command -label "Custom WP  Blog" -command {
    exec $::brow $::cwpurl &
    }
.fluff.view.t add command -label "Friendika" -command {
	exec $::brow $::furl &
}
.fluff.view.t add command -label "StatusNet" -command {
    exec $::brow "$::surl" &
}


# pack em in...
############################

pack .fluff.mb -in .fluff -side left
pack .fluff.ed -in .fluff -side left
pack .fluff.ins -in .fluff -side left
pack .fluff.bb -in .fluff -side left
pack .fluff.view -in .fluff -side left
pack .fluff.font1 -in .fluff -side left
pack .fluff.size -in .fluff -side left

pack .fluff.help -in .fluff -side right
pack .fluff.abt -in .fluff -side right

pack .fluff -in . -fill x


# a few post parameters
###########################################
frame .ljo
grid [tk::label .ljo.sujet -text "Subject:"]\
[tk::entry .ljo.assunto -textvariable subject]\
[tk::label .ljo.tagz -text "Tags:"]\
[tk::entry .ljo.tagit -textvariable tags]\
[tk::label .ljo.ct -text "Category:"]\
[tk::entry .ljo.cats -textvariable cats]


grid [tk::label .ljo.md -text "Mood:"]\
[tk::entry .ljo.mude -textvariable mood]\
[tk::label .ljo.tunages -text "Music:"]\
[tk::entry .ljo.tunez -textvariable tunes]\
[tk::label .ljo.l0c -text "Location:"]\
[tk::entry .ljo.lcn -textvariable loc]

frame .sec

grid [tk::label .sec.pr -text "Privacy:"]\
[tk::radiobutton .sec.pub   -value "default" -text "public"    -variable priv]\
[tk::radiobutton .sec.fri   -value "usemask" -text "friends" -variable priv]\
[tk::radiobutton .sec.pri   -value "private" -text "private"    -variable priv]




pack .ljo -in . -fill x
pack .sec -in . -fill x



frame .lj1


# post buttons
###################
tk::label .lj1.lbl1 -text "Post to:"
tk::entry .lj1.uj -textvariable usej
tk::label .lj1.oj -text "on:"
tk::menubutton .lj1.post -text "Post to: " -menu .lj1.post.t

# xml post menu
##############################
menu .lj1.post.t -tearoff 1

.lj1.post.t add command -label LiveJournal -command ljpost
.lj1.post.t add command -label InsaneJournal -command ijpost
.lj1.post.t add command -label DreamWidth -command dwpost
.lj1.post.t add command -label DeadJournal -command djpost
.lj1.post.t add command -label WordPress -command wppost
.lj1.post.t add command -label CustomWP -command cwpost
.lj1.post.t add command -label Tumblr -command tbpost
.lj1.post.t add command -label Friendika -command fpost

pack .lj1 -in . -fill x
pack .lj1.lbl1 -in .lj1 -side left
pack .lj1.uj -in .lj1 -side left
pack .lj1.oj -in .lj1 -side left
pack .lj1.post -in .lj1 -side left

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


# status net 
###########################################
frame .dt

grid [tk::label .dt.ol -text "StatusNet:"]\
[tk::entry .dt.ent -width 70 -textvariable udate]\
[tk::button .dt.tw -text "StatusNet" -command "snet"]\
[tk::button .dt.qt -text "Quit" -command {exit}]
pack .dt -in . -fill x

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

tk::message .about.t -text "Xpostulate\n by Tony Baldwin\n tony@baldwinsoftware.com\n A x-posting blogging client written in tcl/tk\n Released under the GPL\n For more info see README, or\n http://www.baldwinsoftware.com/xpost.html\n" -width 280
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

#############################################
# insertions menu commands

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

# note distinct dreamwidth cut and user
proc userdw {} {
.txt.txt insert insert "<user name=\"put name here\"> "
}

proc cutdw {} {
.txt.txt insert insert "<cut text=\"put text here\"> "
}

# bbcode tags
# to be inserted in the post.
###################################
proc bblink {} {

toplevel .link
wm title .link "Insert Hyperlink"

frame .link.s
grid [tk::label .link.s.l1 -text "URL:"]\
[tk::entry .link.s.e1 -width 40 -textvariable inurl]
grid [tk::label .link.s.l2 -text "Link text:"]\
[tk::entry .link.s.e2 -width 40 -textvariable ltxt]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[url=$inurl\]$ltxt\[/url\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}

proc bcode {} {
.txt.txt insert insert "\[code\]INSERT CODE TEXT HERE\[/code\]"
}

proc ytube {} {
.txt.txt insert insert "\[youtube\]INSERT VIDEO URL HERE\[/youtube\]"
}

proc bquote {} {
.txt.txt insert insert "\[quote\]INSERT QUOTED TEXT HERE\[/quote\]"
}

proc bimg {} {

toplevel .link
wm title .link "Insert Image"

frame .link.s
grid [tk::label .link.s.l1 -text "IMG URL:"]\
[tk::entry .link.s.e1 -width 40 -textvariable imurl]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[img\]$imurl\[/img\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}

proc bmail {} {

toplevel .link
wm title .link "Insert E-mail"

frame .link.s
grid [tk::label .link.s.l1 -text "E-mail address:"]\
[tk::entry .link.s.e1 -width 40 -textvariable eml]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "\[mail\]$eml\[/mail\]"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}


proc bfren {} {
.txt.txt insert insert "~friendika"
}
# some html tags
# for insertion
###################################
proc linkin {} {

toplevel .link
wm title .link "Insert Hyperlink"

frame .link.s
grid [tk::label .link.s.l1 -text "URL:"]\
[tk::entry .link.s.e1 -width 40 -textvariable url]
grid [tk::label .link.s.l2 -text "Link text:"]\
[tk::entry .link.s.e2 -width 40 -textvariable ltxt]

pack .link.s -in .link -side left

frame .link.btns

grid [tk::button .link.btns.in -text "Insert link" -command {.txt.txt insert insert "<a href=\"$url\">$ltxt</a>"}]\
[tk::button .link.btns.out -text "Done" -command {destroy .link}]

pack .link.btns -in .link -side left
}

proc hrin {} {
.txt.txt insert insert "<hr />"
}

proc bquote {} {
.txt.txt insert insert "<blockquote>INSERT QUOTE TEXT HERE</blockquote>"
}

proc bne {} {
.txt.txt insert insert "<br />"
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
	wm title . "Xpostulate"
}

# open html in browser
###########################################

proc browz {} {
	global brow
	if {$brow != " "} {
	eval exec $::brow http://www.livejournal.com &
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

proc fixtags {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
	} else {
	if { $::tagsc eq 1 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"&lt;" "<" 
	"&gt;" ">" 
	"&amp;" "&" 
	} $content]
	set ::tagsc "0"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
	}
   }
}

######################
#  global preferences


proc prefs {} {

toplevel .pref

wm title .pref "Xpostulate preferences"


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

grid [tk::label .pref.djo -text "DeadJournal settings:"]

grid [tk::label .pref.djn -text "dj Username:"]\
[tk::entry .pref.djnome -textvariable djname]\
[tk::label .pref.djp -text "dj password:"]\
[tk::entry .pref.djpw -show * -textvariable djpswd]

grid [tk::label .pref.dwo -text "Dreamwidth settings:"]

grid [tk::label .pref.dwn -text "dw Username:"]\
[tk::entry .pref.dwnome -textvariable dwname]\
[tk::label .pref.dwp -text "dw password:"]\
[tk::entry .pref.dwpw -show * -textvariable dwpswd]

grid [tk::label .pref.wpo -text "WordPress settings:"]
grid [tk::label .pref.wpn -text "WP Username:"]\
[tk::entry .pref.wpname -textvariable wpname]\
[tk::label .pref.wpp -text "WP password:"]\
[tk::entry .pref.wppw -show * -textvariable wppswd]

grid [tk::label .pref.cwpo -text "Custom WP settings:"]
grid [tk::label .pref.cwpn -text "WP Username:"]\
[tk::entry .pref.cwpname -textvariable cwpname]\
[tk::label .pref.cwpp -text "WP password:"]\
[tk::entry .pref.cwppw -show * -textvariable cwppass]

grid [tk::label .pref.cpwur -text "Custom WP url: "]\
[tk::entry .pref.cpru -textvariable cwpurl]

grid [tk::label .pref.ttwo -text "StatusNet settings:"]

grid [tk::label .pref.twn -text "SN Username:"]\
[tk::entry .pref.twnome -textvariable sname]\
[tk::label .pref.twp -text "SN password:"]\
[tk::entry .pref.twpw -show * -textvariable spswd]

grid [tk::label .pref.surl -text "StatusNet site url: "]\
[tk::entry .pref.snrl -textvariable surl]

grid [tk::label .pref.tumblr -text "Tumblr Settings:"]
grid [tk::label .pref.tbn -text "Tb blogname:"]\
[tk::entry .pref.tbnome -textvariable tbname]\
[tk::label .pref.tbp -text "Tb password:"]\
[tk::entry .pref.tbpw -show * -textvariable tbpswd]
grid [tk::label .pref.tube -text "Tumblr e-mail:"]\
[tk::entry .pref.tubular -textvariable tube]

grid [tk::label .pref.b1o -text "Friendika:"]

grid [tk::label .pref.b1un -text "Username:"]\
[tk::entry .pref.b1nome -textvariable fname]\
[tk::label .pref.b1p -text "password:"]\
[tk::entry .pref.b1pw -show * -textvariable fpwrd]

grid [tk::label .pref.b1n -text "Friendika Server:"]\
[tk::entry .pref.b1nm -text furl]\

grid [tk::button .pref.sv -text "Save Preferences" -command sapro]\
[tk::button .pref.ok -text "OK" -command {destroy .pref}]


}


################
# post to friendika

proc fpost {} {
    
set ptext [.txt.txt get 1.0 {end -1c}]
	set auth "$::fname:$::fpwrd"
	set auth64 [::base64::encode $auth]
	set myquery [::http::formatQuery "status" "$ptext" "source" "Xpostulate"]
	set myauth [list "Authorization" "Basic $auth64"]
	set token [::http::geturl $::furl/api/statuses/update.xml -headers $myauth -query $myquery]
	
}




################
# post to insanejournal...

proc ijpost {} {
if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]

global mypost
set mypost "<?xml version=\"1.0\"?>
<methodCall><methodName>LJ.XMLRPC.postevent</methodName>
<params><param>
<value><struct>
<member><name>year</name><value><int>$::year</int></value></member>
<member><name>mon</name><value><int>$::mon</int></value></member>
<member><name>day</name><value><int>$::day</int></value></member>
<member><name>hour</name><value><int>$::hour</int></value></member>
<member><name>min</name><value><int>$::min</int></value></member>
<member><name>usejournal</name><value><string>$::usej</string></value></member>
<member><name>event</name><value><string>$ptext</string></value></member>
<member><name>username</name><value><string>$::ijname</string></value></member>
<member><name>password</name><value><string>$::ijpswd</string></value></member>
<member><name>useragent</name><value><string>Xpostulate/0.2b</string></value></member>
<member><name>subject</name><value><string>$::subject</string></value></member>
<member><name>lineendings</name><value><string>unix</string></value></member>
<member><name>security</name><value><string>$::priv</string></value></member>
<member><name>ver</name><value><int>1</int></value></member>
<member><name>props</name>
<value><struct>
<member><name>useragent</name><value><string>Xpostulate</string></value></member>
<member><name>current_location</name><value><string>$::loc</string></value></member>
<member><name>current_mood</name><value><string>$::mood</string></value></member>
<member><name>taglist</name><value><string>$::tags</string></value></member>
<member><name>current_music</name><value><string>$::tunes</string></value></member>
</struct></value></member>
</struct></value>
</param></params>
</methodCall>"

global plength
set plength [string length $mypost]

set dopost [http::geturl http://www.insanejournal.com/interface/xmlrpc -query $::mypost -type "text/xml" ]
set ljmta [http::meta $dopost]
set ljstat [http::status $dopost]
set ljresponse [http::data $dopost]
# upvar #0 $dopost state
# puts $state(body)

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "Tweak says: $ljstat\nPost length: $::plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set ljv "http://$::usej.insanejournal.com"
    exec $::brow $ljv &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $ljresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

}

################
# post to deadjournal...

proc djpost {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]

global mypost
set mypost "<?xml version=\"1.0\"?>
<methodCall><methodName>LJ.XMLRPC.postevent</methodName>
<params><param>
<value><struct>
<member><name>year</name><value><int>$::year</int></value></member>
<member><name>mon</name><value><int>$::mon</int></value></member>
<member><name>day</name><value><int>$::day</int></value></member>
<member><name>hour</name><value><int>$::hour</int></value></member>
<member><name>min</name><value><int>$::min</int></value></member>
<member><name>usejournal</name><value><string>$::usej</string></value></member>
<member><name>event</name><value><string>$ptext</string></value></member>
<member><name>username</name><value><string>$::djname</string></value></member>
<member><name>password</name><value><string>$::djpswd</string></value></member>
<member><name>subject</name><value><string>$::subject</string></value></member>
<member><name>lineendings</name><value><string>unix</string></value></member>
<member><name>security</name><value><string>$::priv</string></value></member>
<member><name>ver</name><value><int>1</int></value></member>
<member><name>props</name>
<value><struct>
<member><name>useragent</name><value><string>Xpostulate</string></value></member>
<member><name>current_location</name><value><string>$::loc</string></value></member>
<member><name>current_mood</name><value><string>$::mood</string></value></member>
<member><name>taglist</name><value><string>$::tags</string></value></member>
<member><name>current_music</name><value><string>$::tunes</string></value></member>
</struct></value></member>
</struct></value>
</param></params>
</methodCall>"

global plength
set plength [string length $mypost]

set dopost [http::geturl http://www.deadjournal.com/interface/xmlrpc -query $::mypost -type "text/xml" ]
set ljmta [http::meta $dopost]
set ljstat [http::status $dopost]
set ljresponse [http::data $dopost]
# upvar #0 $dopost state
# puts $state(body)

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "Death says: $ljstat\nPost length: $::plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set ljv "http://$::usej.deadjournal.com"
    exec $::brow $ljv &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $ljresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

}


################
# post to dreamwidth...

proc dwpost {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]

global mypost
set mypost "<?xml version=\"1.0\"?>
<methodCall><methodName>LJ.XMLRPC.postevent</methodName>
<params><param>
<value><struct>
<member><name>year</name><value><int>$::year</int></value></member>
<member><name>mon</name><value><int>$::mon</int></value></member>
<member><name>day</name><value><int>$::day</int></value></member>
<member><name>hour</name><value><int>$::hour</int></value></member>
<member><name>min</name><value><int>$::min</int></value></member>
<member><name>usejournal</name><value><string>$::usej</string></value></member>
<member><name>event</name><value><string>$ptext</string></value></member>
<member><name>username</name><value><string>$::dwname</string></value></member>
<member><name>password</name><value><string>$::dwpswd</string></value></member>
<member><name>subject</name><value><string>$::subject</string></value></member>
<member><name>lineendings</name><value><string>unix</string></value></member>
<member><name>security</name><value><string>$::priv</string></value></member>
<member><name>ver</name><value><int>1</int></value></member>
<member><name>props</name>
<value><struct>
<member><name>useragent</name><value><string>Xpostulate</string></value></member>
<member><name>current_location</name><value><string>$::loc</string></value></member>
<member><name>current_mood</name><value><string>$::mood</string></value></member>
<member><name>taglist</name><value><string>$::tags</string></value></member>
<member><name>current_music</name><value><string>$::tunes</string></value></member>
</struct></value></member>
</struct></value>
</param></params>
</methodCall>"

global plength
set plength [string length $mypost]

set dopost [http::geturl http://www.dreamwidth.org/interface/xmlrpc -query $::mypost -type "text/xml" ]
set ljmta [http::meta $dopost]
set ljstat [http::status $dopost]
set ljresponse [http::data $dopost]
# upvar #0 $dopost state
# puts $state(body)

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "Dream voices say: $ljstat\nPost length: $::plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set ljv "http://$::usej.dreamwidth.org"
    exec $::brow $ljv &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $ljresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

}


#####################################
# Help dialog
proc help {} {
toplevel .help
wm title .help "Xpostulate help"

frame .help.bt
grid [tk::button .help.bt.vt -text "RTFM" -command {
set tlj "http://baldwinsoftware.com/wiki/pmwiki.php?n=Main.Xpostman"
exec $::brow $tlj &}]\
[tk::button .help.bt.lj -text "LJ Xpost Comm" -command {
set tlj "http://xpostulate.livejournal.com"
exec $::brow $tlj &}]\
[tk::button .help.bt.dw -text "DW Xpost Comm" -command {
set tlj "http://xpostulate.dreamwidth.org/"
exec $::brow $tlj &}]\
[tk::button .help.bt.out -text "Close" -command {destroy .help}]

frame .help.t

text .help.t.inf -width 80 -height 10
.help.t.inf insert end "Xpostulate, a FREE and ticklish cross-posting blogging client.\nThere is a manual and further info at http://baldwinsoftware.com/xpost.html\nClicking the RTFM button above will open the manual in your browser.\nFor additional support, join \nhttp://xpostulate.livejournal.com, http://xpostulate.dreamwidth.org\nor the http://baldwinsoftware.com/forum \nwhich can all be accessed by clicking the above buttons\n\nTony Baldwin tony@baldwinsoftware.com"

pack .help.bt -in .help -side top
pack .help.t -in .help -side top
pack .help.t.inf -in .help.t -fill x

}


# status updates to status.net
#####################################
proc snet {} {
	set auth "$::sname:$::spswd"
	set auth64 [::base64::encode $auth]
	if { [string length $::udate] > 500 } {
		toplevel .babbler 
		wm title .babbler "You talk too much!"
		tk::message .babbler.msg -text "Your updates is too long.\nIt can only have 500 characters,\nthere, smarty pants." -width 270
		tk::button .babbler.btn -text "Okay" -command {destroy .babbler} 
		pack .babbler.msg -in .babbler -side top
		pack .babbler.btn -in .babbler -side top
		} else {
		set myquery [::http::formatQuery "status" "$::udate" "source" "Xpostulate"]
		set myauth [list "Authorization" "Basic $auth64"]
		# puts "http::geturl $::serv -headers $myauth -query $myquery"
		set token [::http::geturl http://parlementum.net/api/statuses/update.xml -headers $myauth -query $myquery]
		}
}




################
# post to livejournal...

proc ljpost {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]

global mypost
set mypost "<?xml version=\"1.0\"?>
<methodCall><methodName>LJ.XMLRPC.postevent</methodName>
<params><param>
<value><struct>
<member><name>year</name><value><int>$::year</int></value></member>
<member><name>mon</name><value><int>$::mon</int></value></member>
<member><name>day</name><value><int>$::day</int></value></member>
<member><name>hour</name><value><int>$::hour</int></value></member>
<member><name>min</name><value><int>$::min</int></value></member>
<member><name>usejournal</name><value><string>$::usej</string></value></member>
<member><name>event</name><value><string>$ptext</string></value></member>
<member><name>username</name><value><string>$::ljname</string></value></member>
<member><name>password</name><value><string>$::ljpswd</string></value></member>
<member><name>subject</name><value><string>$::subject</string></value></member>
<member><name>lineendings</name><value><string>unix</string></value></member>
<member><name>security</name><value><string>$::priv</string></value></member>
<member><name>ver</name><value><int>1</int></value></member>
<member><name>props</name>
<value><struct>
<member><name>useragent</name><value><string>Xpostulate</string></value></member>
<member><name>current_location</name><value><string>$::loc</string></value></member>
<member><name>current_mood</name><value><string>$::mood</string></value></member>
<member><name>taglist</name><value><string>$::tags</string></value></member>
<member><name>current_music</name><value><string>$::tunes</string></value></member>
</struct></value></member>
</struct></value>
</param></params>
</methodCall>"

global plength
set plength [string length $mypost]

set dopost [http::geturl http://www.livejournal.com/interface/xmlrpc -query $::mypost -type "text/xml" ]
set ljmta [http::meta $dopost]
set ljstat [http::status $dopost]
set ljresponse [http::data $dopost]
# upvar #0 $dopost state
# puts $state(body)

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "Frank says: $ljstat\nPost length: $::plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set ljv "http://$::usej.livejournal.com"
    exec $::brow $ljv &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $ljresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

}

###############################3
# wordpress post

proc wppost {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	\"  "\""
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]
set time [clock format [clock seconds] -format %G%m%dT%T]

global mypost  
set mypost "<?xml version=\"1.0\"?>
<methodCall>
<methodName>metaWeblog.newPost</methodName> 
<params>
<param><value><string>MyBlog</string></value></param>
<param><value><string>$::wpname</string></value></param> 
<param><value><string>$::wppswd</string></value></param> 
<param><struct>
<member><name>categories</name><value><array><data><value>$::cats</value></data></array></value></member> 
<member><name>description</name><value><string>$ptext</string></value></member> 
<member><name>title</name><value><string>$::subject</string></value></member>
</struct></param>
<param><value><boolean>1</boolean></value></param> 
</params> 
</methodCall>"

set plength [string length $ptext]

set dopost [http::geturl http://$::wpname.wordpress.com/xmlrpc.php -query $::mypost -type "text/xml" ]
set wpstat [http::status $dopost]
set wpresponse [http::data $dopost]

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "WP says: $wpstat\nPost length: $plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set wpu "http://$::wpname.wordpress.com"
    exec $::brow $wpu &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $wpresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

}


############################################
# post to tumblr
proc tbpost {} {

set ptext [.txt.txt get 1.0 {end -1c}]

set login [::http::formatQuery mode login user $::tube password $::tbpswd ]
set log [http::geturl http://www.tumblr.com/api/authenticate -query $login]
    
set post [http::formatQuery mode postevent auth_method clear email $::tube password $::tbpswd type regular generator Xpostulate tags $::tags title $::subject body $ptext]
set plength [string length $post]
set dopost [http::geturl http://www.tumblr.com/api/write -query $post]
set ljmta [http::meta $dopost]
set ljl [http::size $dopost]
set ljstat [http::status $dopost]

toplevel .rsp 
wm title .rsp "Post Status"
grid [tk::label .rsp.lbl -text "Tumblr says: $ljstat\nPost length: $ljl"]
grid [tk::button .rsp.view -text "View Journal" -command {
    set ijv "http://$::tbname.tumblr.com"
    exec $::brow $ijv &
}]\
[tk::button .rsp.ok -text "DONE" -command {destroy .rsp}]

}


###############################3
# custom wp post

proc cwpost {} {

if { $::tagsc eq 0 } {
set content [.txt.txt get 1.0 end]
set escaped [string map {
	"<" "&lt;"
	">" "&gt;"
	"&" "&amp;"
	} $content]
	set ::tagsc "1"
.txt.txt delete 1.0 end
.txt.txt insert insert $escaped
}

set ptext [.txt.txt get 1.0 {end -1c}]
set time [clock format [clock seconds] -format %G%m%dT%T]

global mypost  
set mypost "<?xml version=\"1.0\"?>
<methodCall>
<methodName>metaWeblog.newPost</methodName> 
<params>
<param><value><string>MyBlog</string></value></param>
<param><value><string>$::cwpname</string></value></param> 
<param><value><string>$::cwppass</string></value></param> 
<param><struct>
<member><name>categories</name><value><array><data><value>$::cats</value></data></array></value></member> 
<member><name>description</name><value><string>$ptext</string></value></member> 
<member><name>title</name><value><string>$::subject</string></value></member>
</struct></param>
<param><value><boolean>1</boolean></value></param> 
</params> 
</methodCall>"

set plength [string length $ptext]
set hconf [http::config -useragent "Xpostulate 0.2" ]
set dopost [http::geturl $::cwpurl/xmlrpc.php -query $::mypost -type "text/xml" ]
set wpstat [http::status $dopost]
set wpresponse [http::data $dopost]

toplevel .rsp 
wm title .rsp "Post Status"

frame .rsp.btns
grid [tk::label .rsp.btns.lbl -text "Tony says: $wpstat\nPost length: $plength"]
grid [tk::button .rsp.btns.view -text "View Journal" -command {
    set bsu "$cwpurl"
    exec $::brow $bsu &
}]\
[tk::button .rsp.btns.ok -text "DONE" -command {destroy .rsp}]

frame .rsp.txt
text .rsp.txt.t -width 80 -height 20
.rsp.txt.t insert end $wpresponse

pack .rsp.btns -in .rsp -side top -fill x
pack .rsp.txt.t -in .rsp.txt -side top -fill x
pack .rsp.txt -in .rsp -side top -fill x

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
