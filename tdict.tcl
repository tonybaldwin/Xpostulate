#!//usr/bin/env wish8.5
# Tickle Dict 
# T-Dictionary, by tonytraductor@linguasos.org
# This program is provided according to the terms of the GNU GPL version 3, or at your option
# any later version.  All terms and conditions therein apply.   \


package require Tk
package require Ttk

global file_types

# user definable
set host dict.org
set port 2628
set linkcolor blue
set activecolor red
set resetonfail 1
# Proxy use is untested
set proxyinit {}

# don't touch
set DICT "All"
set DICTS(All) "*"
set CODE 0
set HIST ""
set HIND -1
set ERR 0
set QUIT 0

proc back {} {
	global HIST
	global HIND
	if {$HIND <= 0} {return}
	incr HIND -1
	sendquery [lindex $HIST $HIND] 1
}

proc forward {} {
	global HIST
	global HIND
	if {$HIND == [expr [llength $HIST] - 1]} {return}
	incr HIND
	sendquery [lindex $HIST $HIND] 1
}

proc connect {} {
	global server
	global host
	global port
	global proxyinit
	set server [socket -async $host $port]
	fconfigure $server -blocking 0 -buffering line -translation crlf
	fileevent $server readable readsock
	if [string length $proxyinit] {
		puts -nonewline $server $proxyinit
	}
}

proc sendquery {string args} {
	global server
	global DICT
	global DICTS
	global HIST
	global HIND
	regsub -all "\n" $string { } string
	regsub -all " +" $string " " string
	regsub -all "\"" $string {} string
	if [regexp {(\(|\)|\||\+|\*|\.|\?|\[|\]|\$|\^)} $string] {
		set mode 1
	} {set mode 0}
	if {$mode == 0} {
		puts $server "define $DICTS($DICT) \"$string\""
	} {puts $server "match $DICTS($DICT) re \"$string\""}
	if {$args == 1} {return}
	set HIST [lrange $HIST 0 $HIND]
	lappend HIST $string
	incr HIND
}

proc readsock {} {
	global server
	global CODE
	global ERR
	set lines ""
	if [eof $server] {
		global QUIT
		if {$QUIT} {exit}
		catch {close $server}
		connect
	}
	set line [gets $server]
	if {$CODE == 151} {
		if [string compare $line "."] {
			show "$line\n" word
			return
		} {
			show "\n" {}
		}
	}
	if {$CODE == 110} {
		if [string compare $line "."] {
			global DICTS
			.query.options.menu add radiobutton -label [lindex $line 1] -variable DICT
			set DICTS([lindex $line 1]) [lindex $line 0]
			return
		}
	}
	if {$CODE == 152} {
		global DICTS
		if [string compare $line "."] {
			foreach of [array names DICTS] {
				if ![string compare $DICTS($of) [lindex $line 0]] {
					set dict $of
					break
				}
			}
			catch {
				show "\t" {}
				show "[lindex $line 1]" link
				show " : $dict\n" {}
			}
			return
		}
	}
	set CODE 0
	regexp {^[1-5][0-8][0-9]} $line tempcode
	catch {set CODE $tempcode}
	if {$CODE == 151} {
		catch {show "[lindex $line 3]\n" bold}
	}
	if {$CODE == 150} {
		.main.text config -state normal
		.main.text delete 0.0 end
		.main.text config 
	}
	
	
	if {$CODE == 250} {
		set startTag 0.0
		.main.text config -state normal

	while {[string compare [.main.text search \{ $startTag end] ""] != 0} {
		set beginTag [.main.text search \{ $startTag end]
		.main.text delete $beginTag "$beginTag + 1 char"
		set startTag $beginTag
		set endTag  [.main.text search \} $startTag end]
		set nextBr [.main.text search \{ $startTag end]
		if {[string compare $nextBr ""] != 0} {
			if [.main.text compare $nextBr < $endTag] {continue}
		}
		.main.text delete $endTag "$endTag + 1 char"
		set startTag "$endTag+1c"
		.main.text tag add link $beginTag $endTag
		set endTag  [.main.text search \} "$startTag -1c" end]
		set nextBr [.main.text search \{ "$startTag -1c" end]
		if {[string compare $nextBr ""] != 0 && [string compare $endTag ""] != 0} {
			if [.main.text compare $nextBr > $endTag] {
				.main.text delete $endTag "$endTag + 1 char"
			}
		}
	}
	.main.text config 
	}
}

proc show {line flags} {
	.main.text config -state normal
	.main.text insert end $line $flags
	.main.text config 
# -state disabled
}



proc ApplySetting {win name var} {
	$win config -$name $var
	foreach of [winfo children $win] {
		ApplySetting $of $name $var
		catch {$of config -$name $var}
	}
}
catch {source /TPDictrc}
catch {source ::TPDictrc}
catch {source ~/.TPDictrc}
frame .main
text .main.text -yscrollcommand ".main.yscroll set" -bg #e7ebcf
# -state disabled -width 80
# -bg white
scrollbar .main.yscroll -orient vertical -command ".main.text yview" -takefocus 0
grid .main.text .main.yscroll -sticky news
grid rowconfigure .main 0 -weight 1
grid columnconfigure .main 0 -weight 1
.main.text tag config link -foreground $linkcolor
.main.text tag config active -foreground $activecolor
.main.text tag config word -font "[.main.text cget -font]"
.main.text tag bind link <Enter> {
	.main.text tag add active {@%x,%y wordstart} {@%x,%y wordend}
}
.main.text tag bind link <Leave> {
	.main.text tag remove active 0.0 end
}
.main.text tag bind link <Motion> {
	.main.text tag remove active 0.0 end
	set ind [.main.text index {@%x,%y}]
	set marks [.main.text tag nextrange link $ind]
	if ![string length $marks] {
		set marks [.main.text tag prevrange link $ind]
	}
	if {[.main.text compare $ind >= [lindex $marks 0]] && [.main.text compare $ind <= [lindex $marks 1]]} {
		.main.text tag add active [lindex $marks 0] [lindex $marks 1]
	} {
		set marks [.main.text tag prevrange link $ind]
		.main.text tag add active [lindex $marks 0] [lindex $marks 1]
	}
	unset marks
	unset ind
}
.main.text tag bind link <1> {
	set ind [.main.text index {@%x,%y}]
	set marks [.main.text tag nextrange link $ind]
	if ![string length $marks] {
		set marks [.main.text tag prevrange link $ind]
	}
	if {[.main.text compare $ind >= [lindex $marks 0]] && [.main.text compare $ind <= [lindex $marks 1]]} {
		sendquery [.main.text get [lindex $marks 0] [lindex $marks 1]]
	} {
		set marks [.main.text tag prevrange link $ind]
		sendquery [.main.text get [lindex $marks 0] [lindex $marks 1]]
	}
	unset marks
	unset ind
	break
}



frame .query
label .query.label -text "Enter term:"
pack .query.label -side left
entry .query.query
pack .query.query -side left
tk::button .query.go -text "Seek" -command {
	sendquery [.query.query get]
	.query.query delete 0 end
}
pack .query.go -side left
label .query.lbl1 -text "Resource:"
pack .query.lbl1 -side left
tk_optionMenu .query.options DICT All
pack .query.options -side left
bind .query.query <Return> {
	sendquery [.query.query get]
	.query.query delete 0 end
}
tk::button .query.back -text "Back" -command back
tk::button .query.forward -text "Forward" -command forward
tk::button .query.quit -text "Quit" -command exit
pack .query.quit -side right
pack .query.forward -side right
pack .query.back -side right
focus .query.query
pack .query -side top -fill x

.main.text tag bind word <3> {
	sendquery [.main.text get {@%x,%y wordstart} {@%x,%y wordend} ]
}

bind . <Escape> exit 
bind . <Next> {.main.text yview scroll 1 pages}
bind . <Prior> {.main.text yview scroll -1 pages}
bind . <Down> {.main.text yview scroll 1 units}
bind . <Up> {.main.text yview scroll -1 units}
bind . <Left> back
bind . <Right> forward
bind . <Control-Key-u> {.query.query delete 0 end}
pack .main -side top -fill both -expand true

frame .query2

tk::button .query2.bgcor -text "Background Color" -command setbg
tk::button .query2.sav -text "Save" -command {savedef}
tk::button .query2.sel -text "Select All" -command {.main.text tag add sel 1.0 end}
label .query2.2cp -text " -Ctrl-C to copy text- "
label .query2.fs -text "Font size:" 
ttk::combobox .query2.size -width 4 -value [list 8 10 12 14 16 18] -state readonly

bind .query2.size <<ComboboxSelected>> [list sizeFont .main.text .query2.size]

proc sizeFont {txt combo} {
	set font [$txt cget -font]
	font configure $font -size [list [$combo get]]
}

pack .query2.bgcor -side right
pack .query2.sav -side left
pack .query2.sel -side left
pack .query2.2cp -side left
pack .query2.fs -side left
pack .query2.size -side left


pack .query2 -in . -fill x

 proc setbg { } {
    global i
    set color [tk_chooseColor -initialcolor [.main.text cget -background]]
    if {$color != ""} {.main.text configure -background $color}
 }

set file_types {
{"All Files" * }
{"Text Files" { .txt .TXT}}
{"Html" {.html}}
}

proc savedef {} { 
global filename
set filename [tk_getSaveFile -filetypes $::file_types]
   set data [.main.text get 1.0 {end -1c}]
   wm title . "Now Tickling: $::filename"
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
}

wm protocol . WM_DELETE_WINDOW {
	set QUIT 1
	catch {puts $server quit}
	wm protocol . WM_DELETE_WINDOW exit
}
wm title . "Tickle Dict"
tk_setPalette background seashell1
if [catch {connect}] {
	wm withdraw .
	tk_dialog .error "Critical Error" "Could not contact remote server. Terminating." error 0
	exit
}
puts $server "client TPDict"
puts $server "show databases"
if {$argc > 0} {
	sendquery $argv
}

proc about {} {

tk_messageBox -type ok -title "About T-Dict" -message "Tcl Dictionary\n by Tony Baldwin\n tonytraductor\n @\n linguasos.org"

}

# This program was written by Anthony Baldwin / tonytraductor@linguasos.org
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
