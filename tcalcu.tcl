#!/bin/sh
# a calculator
# just tricking tcl here\
exec wish8.5 -f "$0" ${1+"$@"}

package require Tk
wm title . Calculator
grid [entry .e -textvar e -just right] -columnspan 5
bind .e <Escape> {exit}
bind .e <Return> =
set n 0
foreach row {
   {7 8 9 + -}
   {4 5 6 * /}
   {1 2 3 ( )}
   {C 0 . =  }
} {
   foreach key $row {
       switch -- $key {
           =       {set cmd =}
           C       {set cmd {set clear 1; set e ""}}
           default {set cmd "hit $key"}
       }
       lappend keys [button .[incr n] -text $key -command $cmd]
   }
   eval grid $keys -sticky we ;#-padx 1 -pady 1
   set keys [list]
}
grid .$n -columnspan 2 ;# make last key (=) double wide
proc = {} {
   regsub { =.+} $::e "" ::e ;# maybe clear previous result
   if [catch {set ::res [expr [string map {/ *1.0/} $::e]]}] {
       .e config -fg red
   }
   append ::e = $::res 
   .e xview end
   set ::clear 1
}
proc hit {key} {
   if $::clear {
       set ::e ""
       if ![regexp {[0-9().]} $key] {set ::e $::res}
       .e config -fg black
       .e icursor end
       set ::clear 0
   }
   .e insert end $key
}
set clear 0
focus .e           ;# allow keyboard input

wm title . tcalcu

wm resizable . 0 0

