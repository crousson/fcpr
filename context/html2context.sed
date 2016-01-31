# 1i\
# \\documentstyle{article}
# 1i\
# \\begin{document}
# $a\
# \\end{document}
# Too bad there's no way to make sed ignore case!
/<[Xx][Mm][Pp]>/,/<.[Xx][Mm][Pp]>/b lit
/<.[Xx][Mm][Pp]>/b lit
/<[Ll][Ii][Ss][Tt][Ii][Nn][Gg]>/,/<.[Ll][Ii][Ss][Tt][Ii][Nn][Gg]>/b lit
/<.[Ll][Ii][Ss][Tt][Ii][Nn][Gg]>/b lit
/<[Pp][Rr][Ee]>/,/<.[Pp][Rr][Ee]>/b pre
/<.[Pp][Rr][Ee]>/b pre
# Stuff to ignore
s?<[Ii][Ss][Ii][Nn][Dd][Ee][Xx]>??
s?</[Aa][Dd][Dd][Rr][Ee][Ss][Ss]>??g
s?<[Nn][Ee][Xx][Tt][Ii][Dd][^>]*>??g
# character set translations for LaTex special chars
s?&gt.?>?g
s?&lt.?<?g
s?\\?\\backslash ?g
s?{?\\{?g
s?}?\\}?g
s?%?\\%?g
s?\$?\\$?g
s?&?\\&?g
s?#?\\#?g
s?_?\\_?g
s?~?\\~?g
s?\^?\\^?g
# Paragraph borders
s?<[Pp]>??g
s?</[Pp]>??g
# Headings
s?<[Tt][Ii][Tt][Ll][Ee]>\([^<]*\)</[Tt][Ii][Tt][Ll][Ee]>?\\section*{\1}?g
s?<[Hh]n>?\\part{?g
s?</[Hh]n>?}?g
s?<[Hh]1>?\\section{?g
s?</[Hh][0-9]>?}?g
s?<[Hh]2>?\\subsection{?g
s?<[Hh]3>?\\subsubsection{?g
s?<[Hh]4>?\\subsubsection{?g
s?<[Hh]5>?\\paragraph{?g
s?<[Hh]6>?\\subparagraph{?g
# UL is itemize
s?<[Uu][Ll]>?\\startitemize?g
s?</[Uu][Ll]>?\\stopitemize?g
s?<[Ll][Ii]>?\\item ?g
s?</[Ll][Ii]>??g
# OL is itemize
s?<[Oo][Ll]>?\\startitemize[n]?g
s?</[Oo][Ll]>?\\stopitemize?g
# DL is description
s?<[Dd][Ll]>?\\begin{description}?g
s?</[Dd][Ll]>?\\end{description}?g
# closing delimiter for DT is first < or end of line which ever comes first NO
#s?<[Dd][Tt]>\([^<]*\)<?\\item[\1]<?g
#s?<[Dd][Tt]>\([^<]*\)$?\\item[\1]?g
#s?<[Dd][Dd]>??g
s?<[Dd][Tt]>?\\item[<?g
s?<[Dd][Dd]>?]?g
# Other common SGML markup.  this is ad-hoc
s?<sec[ab]>??
s?</sec[ab]>??g
# Italics
s?<it>\([^<]*\)</it>?{\\it \1 }?g
# Get rid of Anchors
:pre
s?<[Aa][^>]*>??g
s?</[Aa]>??g
# This is a subroutine in sed, in case you are not a sed guru
: lit
s?<[Xx][Mm][Pp]>?\\starttyping?g
s?</[Xx][Mm][Pp]>?\\stoptyping?
s?<[Ll][Ii][Ss][Tt][Ii][Nn][Gg]>?\\starttyping?g
s?</[Ll][Ii][Ss][Tt][Ii][Nn][Gg]>?\\stoptyping?