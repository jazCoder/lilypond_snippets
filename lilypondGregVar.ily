#(define-markup-command (arrow-at-angle layout props angle-deg length fill)
   (number? number? boolean?)
   (let* (
          ;; PI-OVER-180 and degrees->radians are taken from flag-styles.scm
          (PI-OVER-180 (/ (atan 1 1) 45))
          (degrees->radians (lambda (degrees) (* degrees PI-OVER-180)))
          (angle-rad (degrees->radians angle-deg))
          (target-x (* length (cos angle-rad)))
          (target-y (* length (sin angle-rad))))
     (interpret-markup layout props
                       (markup
                        #:translate (cons (/ target-x 2) (/ target-y 1))
                        #:rotate angle-deg
                        #:translate (cons (/ length -2) 0)
                        #:concat (#:draw-line (cons length 0)
                                              #:arrow-head X RIGHT fill)))))

splitStaffBarLineMarkup = \markup  \with-dimensions #'(0 . 0) #'(0 . 0)  {
  \combine
    \arrow-at-angle #35 #(sqrt 8) ##f
    \arrow-at-angle #-35 #(sqrt 8) ##f
}

unisonUpBarLineMarkup = \markup \with-dimensions #'(0 . 0) #'(0 . 0) {
      \arrow-at-angle #35 #(sqrt 8) ##f
}

unisonDownBarLineMarkup = \markup \with-dimensions #'(0 . 0) #'(0 . 0) {
      \arrow-at-angle #-35 #(sqrt 8) ##f
}

splitStaffBarLine = {
  \once \override Staff.BarLine.stencil =
    #(lambda (grob)
       (ly:stencil-combine-at-edge
        (ly:bar-line::print grob)
        X RIGHT
        
        (grob-interpret-markup grob splitStaffBarLineMarkup)
        0))
  \break
}


splitStaffBarLineFour = {
  \once \override Staff.BarLine.stencil =
    #(lambda (grob)
       (ly:stencil-combine-at-edge
        (ly:bar-line::print grob)
        X RIGHT
        
        (grob-interpret-markup grob splitStaffBarLineMarkup)
        4))
  \break
}

splitStaffBarLineTwo = {
  \once \override Staff.BarLine.stencil =
    #(lambda (grob)
       (ly:stencil-combine-at-edge
        (ly:bar-line::print grob)
        X RIGHT
        
        (grob-interpret-markup grob splitStaffBarLineMarkup)
       2))
  \break
}

moveRight = \once \override NoteColumn #'force-hshift = #1.75

moveLeft = \once \override NoteColumn #'force-hshift = #-1.75

unisonUpBarLine = {
  \once \override Staff.BarLine.stencil =
    #(lambda (grob)
       (ly:stencil-combine-at-edge
        (ly:bar-line::print grob)
        X RIGHT
        (grob-interpret-markup grob unisonUpBarLineMarkup)
        0))
  \break
}

unisonDownBarLine = {
  \once \override Staff.BarLine.stencil =
    #(lambda (grob)
       (ly:stencil-combine-at-edge
        (ly:bar-line::print grob)
        X RIGHT
        (grob-interpret-markup grob unisonDownBarLineMarkup)
        0))
  \break
}

startCoda = {
            \bar"||"
            \stopStaff \cadenzaOn s1  
            \startStaff
            \cadenzaOff 
            \once \override Staff.Clef.font-size=#2
            \set Staff.forceClef = ##t
         }

#(define-markup-command (diagonal-stroke layout props arg)
  (markup?)
  #:category font
  #:properties ((font-size 0) (thickness 1
                                ) (extension 0.07))
"
 Draw a diagonal stroke through @var{arg} arg.
"
  (let*
   ((thick (* (magstep font-size)
      (ly:output-def-lookup layout 'line-thickness)))
    (underline-thick (* thickness thick))
    (markup (interpret-markup layout props arg))
    (x1 (car (ly:stencil-extent markup X)))
    (x2 (cdr (ly:stencil-extent markup X)))
    (y1 (car (ly:stencil-extent markup Y)))
    (y2 (cdr (ly:stencil-extent markup Y)))
    (dx (* extension (- x2 x1)))
    (dy (* extension (- y2 y1)))
    (line (make-line-stencil underline-thick
      (- x1 dx) (- y1 dy)
      (+ x2 dx) (+ y2 dy))))
   (ly:stencil-add markup line)))

stroke =
#(define-scheme-function (parser location color x-ext y-ext)
  ((symbol? #f) pair? pair?)
"
 Returns a diagonal stroke.
 For use with @code{\\mark}
"
#{
  \markup {
    \null
    \with-dimensions #empty-interval #empty-interval
    \with-color #(x11-color color)
    \diagonal-stroke 
    \with-dimensions #x-ext #y-ext
    \null
  }
#})

#(define-markup-command (ezscore layout props mus) (ly:music?)
  #:properties ((size 0))
  (interpret-markup layout props
    #{
      \markup {
        \score {
          \new RhythmicStaff { $mus }
          \layout {
            \context {
              \RhythmicStaff
              \remove Clef_engraver
              \remove Time_signature_engraver
              \omit StaffSymbol
              fontSize = #size
              \override StaffSymbol.staff-space = #(magstep size)
              \override StaffSymbol.thickness = #(magstep size)
            }
            indent = 0
          }
        }
      }
    #}))

doitBefore= #(define-music-function (parser location grace)
  (ly:pitch?)
  #{
\once \override BendAfter.springs-and-rods
      = #ly:spanner::set-spacing-rods
    \once \override BendAfter.minimum-length = #2
    \once \override BendAfter.extra-offset = #' ( -2 . 0 ) 
    \once \hideNotes
    \grace $grace 4 \bendAfter#+2 
  #})

glissBefore = #(define-music-function (parser location grace)
  (ly:pitch?)
  #{
\once \override Glissando.springs-and-rods
      = #ly:spanner::set-spacing-rods
    \once \override Glissando.minimum-length = #3
     \once \hideNotes
    \grace $grace \glissando 
  #})


crossHead = { \once \override Voice.NoteHead.style = #'cross }

#(define-markup-command (gregText layout props text)
 (markup?)
  (interpret-markup layout props
    #{
     \markup \raise#1.25 \italic \fontsize#0 { $text }
    #}))

#(define-markup-command (gregTextDown layout props text)
 (markup?)
  (interpret-markup layout props
    #{
     \markup \raise#-2.25 \italic \fontsize#0 { $text }
    #}))

#(define-markup-command (gregTextNorm layout props text)
 (markup?)
  (interpret-markup layout props
    #{
     \markup \raise#1.25 \fontsize#0 { $text }
    #}))

#(define-markup-command (dynText layout props dynamic text)
 (markup? markup?)
  (interpret-markup layout props
    #{
     \markup  \raise#1.25 { \dynamic $dynamic \italic $text } 
    #}))   
