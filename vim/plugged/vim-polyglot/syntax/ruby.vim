if exists('g:polyglot_disabled') && index(g:polyglot_disabled, 'ruby') != -1
  finish
endif

" Vim syntax file
" Language:		Ruby
" Maintainer:		Doug Kearns <dougkearns@gmail.com>
" URL:			https://github.com/vim-ruby/vim-ruby
" Release Coordinator:	Doug Kearns <dougkearns@gmail.com>
" ----------------------------------------------------------------------------
"
" Previous Maintainer:	Mirko Nasato
" Thanks to perl.vim authors, and to Reimer Behrends. :-) (MN)
" ----------------------------------------------------------------------------

" Prelude {{{1
if exists("b:current_syntax")
  finish
endif

" this file uses line continuations
let s:cpo_sav = &cpo
set cpo&vim

" eRuby Config {{{1
if exists('main_syntax') && main_syntax == 'eruby'
  let b:ruby_no_expensive = 1
endif

" Folding Config {{{1
if has("folding") && exists("ruby_fold")
  setlocal foldmethod=syntax
endif

let s:foldable_groups = split(
      \	  get(
      \	    b:,
      \	    'ruby_foldable_groups',
      \	    get(g:, 'ruby_foldable_groups', 'ALL')
      \	  )
      \	)

function! s:foldable(...) abort
  if index(s:foldable_groups, 'NONE') > -1
    return 0
  endif

  if index(s:foldable_groups, 'ALL') > -1
    return 1
  endif

  for l:i in a:000
    if index(s:foldable_groups, l:i) > -1
      return 1
    endif
  endfor

  return 0
endfunction

function! s:run_syntax_fold(args) abort
  let [_0, _1, groups, cmd; _] = matchlist(a:args, '\(["'']\)\(.\{-}\)\1\s\+\(.*\)')
  if call('s:foldable', split(groups))
    let cmd .= ' fold'
  endif
  exe cmd
endfunction

com! -nargs=* SynFold call s:run_syntax_fold(<q-args>)

" }}}

syn cluster rubyNotTop contains=@rubyCommentNotTop,@rubyStringNotTop,@rubyRegexpSpecial,@rubyDeclaration,@rubyExceptionHandler,rubyConditional,rubyModuleName,rubyClassName,rubySymbolDelimiter

" Whitespace Errors {{{1
if exists("ruby_space_errors")
  if !exists("ruby_no_trail_space_error")
    syn match rubySpaceError display excludenl "\s\+$"
  endif
  if !exists("ruby_no_tab_space_error")
    syn match rubySpaceError display " \+\t"me=e-1
  endif
endif

" Operators {{{1
if exists("ruby_operators")
  syn match  rubyDotOperator	    "\.\|&\." containedin=rubyKeywordAsMethod
  syn match  rubyTernaryOperator    "[[:alnum:]]\@1<!?\|:"
  syn match  rubyArithmeticOperator "\*\*\|[*/%+]\|->\@!"
  syn match  rubyComparisonOperator "<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<<\@!\|>=\|[-=]\@1<!>"
  syn match  rubyBitwiseOperator    "[~^|]\|&\.\@!\|\%(class\s*\)\@<!<<\|>>"
  syn match  rubyBooleanOperator    "[[:alnum:]]\@1<!!\|&&\|||"
  syn match  rubyRangeOperator	    "\.\.\.\="
  syn match  rubyAssignmentOperator "=>\@!\|-=\|/=\|\*\*=\|\*=\|&&=\|&=\|||=\||=\|%=\|+=\|>>=\|<<=\|\^="
  syn match  rubyEqualityOperator   "===\|==\|!=\|!\~\|=\~"
  syn match  rubyScopeOperator	    "::"
  syn region rubyBracketOperator    matchgroup=rubyOperator start="\%(\w[?!]\=\|[]})]\)\@2<=\[\s*" end="\s*]" contains=ALLBUT,@rubyNotTop

  syn cluster rubyOperator contains=ruby.*Operator
endif

" String Interpolation and Backslash Notation {{{1
syn region rubyInterpolation	      matchgroup=rubyInterpolationDelimiter start="#{" end="}" contained contains=ALLBUT,@rubyNotTop
syn match  rubyInterpolation	      "#\$\%(-\w\|[!$&"'*+,./0:;<>?@\`~_]\|\w\+\)" display contained contains=rubyInterpolationDelimiter,@rubyGlobalVariable
syn match  rubyInterpolation	      "#@@\=\w\+"				   display contained contains=rubyInterpolationDelimiter,rubyInstanceVariable,rubyClassVariable
syn match  rubyInterpolationDelimiter "#\ze[$@]"				   display contained

syn match rubyStringEscape "\\\_."											    contained display
syn match rubyStringEscape "\\\o\{1,3}\|\\x\x\{1,2}"									    contained display
syn match rubyStringEscape "\\u\%(\x\{4}\|{\x\{1,6}\%(\s\+\x\{1,6}\)*}\)"						    contained display
syn match rubyStringEscape "\%(\\M-\\C-\|\\C-\\M-\|\\M-\\c\|\\c\\M-\|\\c\|\\C-\|\\M-\)\%(\\\o\{1,3}\|\\x\x\{1,2}\|\\\=\S\)" contained display

syn match rubyBackslashEscape "\\\\" contained display
syn match rubyQuoteEscape     "\\'"  contained display
syn match rubySpaceEscape     "\\ "  contained display

syn match rubyParenthesesEscape	   "\\[()]"  contained display
syn match rubyCurlyBracesEscape	   "\\[{}]"  contained display
syn match rubyAngleBracketsEscape  "\\[<>]"  contained display
syn match rubySquareBracketsEscape "\\[[\]]" contained display

syn region rubyNestedParentheses    start="("  skip="\\\\\|\\)"  matchgroup=rubyString end=")"	transparent contained
syn region rubyNestedCurlyBraces    start="{"  skip="\\\\\|\\}"  matchgroup=rubyString end="}"	transparent contained
syn region rubyNestedAngleBrackets  start="<"  skip="\\\\\|\\>"  matchgroup=rubyString end=">"	transparent contained
syn region rubyNestedSquareBrackets start="\[" skip="\\\\\|\\\]" matchgroup=rubyString end="\]"	transparent contained

syn cluster rubySingleCharEscape contains=rubyBackslashEscape,rubyQuoteEscape,rubySpaceEscape,rubyParenthesesEscape,rubyCurlyBracesEscape,rubyAngleBracketsEscape,rubySquareBracketsEscape
syn cluster rubyNestedBrackets	 contains=rubyNested.\+
syn cluster rubyStringSpecial	 contains=rubyInterpolation,rubyStringEscape
syn cluster rubyStringNotTop	 contains=@rubyStringSpecial,@rubyNestedBrackets,@rubySingleCharEscape

" Regular Expression Metacharacters {{{1
syn region rubyRegexpComment	  matchgroup=rubyRegexpSpecial	 start="(?#"								    skip="\\\\\|\\)"  end=")"  contained
syn region rubyRegexpParens	  matchgroup=rubyRegexpSpecial	 start="(\(?:\|?<\=[=!]\|?>\|?<[a-z_]\w*>\|?[imx]*-[imx]*:\=\|\%(?#\)\@!\)" skip="\\\\\|\\)"  end=")"  contained transparent contains=@rubyRegexpSpecial
syn region rubyRegexpBrackets	  matchgroup=rubyRegexpCharClass start="\[\^\="								    skip="\\\\\|\\\]" end="\]" contained transparent contains=rubyRegexpBrackets,rubyStringEscape,rubyRegexpEscape,rubyRegexpCharClass,rubyRegexpIntersection oneline
syn match  rubyRegexpCharClass	  "\\[DdHhRSsWw]"	 contained display
syn match  rubyRegexpCharClass	  "\[:\^\=\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):\]" contained
syn match  rubyRegexpCharClass	  "\\[pP]{^\=.\{-}}"	 contained display
syn match  rubyRegexpEscape	  "\\[].*?+^$|\\/(){}[]" contained " see commit e477f10
syn match  rubyRegexpQuantifier	  "[*?+][?+]\="		 contained display
syn match  rubyRegexpQuantifier	  "{\d\+\%(,\d*\)\=}?\=" contained display
syn match  rubyRegexpAnchor	  "[$^]\|\\[ABbGZz]"	 contained display
syn match  rubyRegexpDot	  "\.\|\\X"		 contained display
syn match  rubyRegexpIntersection "&&"			 contained display
syn match  rubyRegexpSpecial	  "\\K"			 contained display
syn match  rubyRegexpSpecial	  "|"			 contained display
syn match  rubyRegexpSpecial	  "\\[1-9]\d\=\d\@!"	 contained display
syn match  rubyRegexpSpecial	  "\\k<\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\=>" contained display
syn match  rubyRegexpSpecial	  "\\k'\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\='" contained display
syn match  rubyRegexpSpecial	  "\\g<\%([a-z_]\w*\|-\=\d\+\)>"		contained display
syn match  rubyRegexpSpecial	  "\\g'\%([a-z_]\w*\|-\=\d\+\)'"		contained display

syn cluster rubyRegexpSpecial contains=@rubyStringSpecial,rubyRegexpSpecial,rubyRegexpEscape,rubyRegexpBrackets,rubyRegexpCharClass,rubyRegexpDot,rubyRegexpQuantifier,rubyRegexpAnchor,rubyRegexpParens,rubyRegexpComment,rubyRegexpIntersection

" Numbers {{{1
syn match rubyInteger "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[xX]\x\+\%(_\x\+\)*r\=i\=\>"								 display
syn match rubyInteger "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0[dD]\)\=\%(0\|[1-9]\d*\%(_\d\+\)*\)r\=i\=\>"					 display
syn match rubyInteger "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[oO]\=\o\+\%(_\o\+\)*r\=i\=\>"							 display
syn match rubyInteger "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<0[bB][01]\+\%(_[01]\+\)*r\=i\=\>"							 display
syn match rubyFloat   "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0\|[1-9]\d*\%(_\d\+\)*\)\.\d\+\%(_\d\+\)*r\=i\=\>"					 display
syn match rubyFloat   "\%(\%(\w\|[]})\"']\s*\)\@<!-\)\=\<\%(0\|[1-9]\d*\%(_\d\+\)*\)\%(\.\d\+\%(_\d\+\)*\)\=\%([eE][-+]\=\d\+\%(_\d\+\)*\)i\=\>" display

" Identifiers {{{1
syn match rubyLocalVariableOrMethod "\<[_[:lower:]][_[:alnum:]]*[?!]\=" contains=NONE display transparent
syn match rubyBlockArgument	    "&[_[:lower:]][_[:alnum:]]"		 contains=NONE display transparent

syn match rubyClassName	       "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\u\%(\w\|[^\x00-\x7F]\)*\>\%(\s*(\)\@!" contained
syn match rubyModuleName       "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\u\%(\w\|[^\x00-\x7F]\)*\>\%(\s*(\)\@!" contained
syn match rubyConstant	       "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\u\%(\w\|[^\x00-\x7F]\)*\>\%(\s*(\)\@!"
syn match rubyClassVariable    "@@\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*" display
syn match rubyInstanceVariable "@\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*"  display
syn match rubyGlobalVariable   "$\%(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\|-.\)"
syn match rubySymbolDelimiter  ":" contained
syn match rubySymbol	       "[]})\"':]\@1<!:\%(\^\|\~@\|\~\|<<\|<=>\|<=\|<\|===\|[=!]=\|[=!]\~\|!@\|!\|>>\|>=\|>\||\|-@\|-\|/\|\[]=\|\[]\|\*\*\|\*\|&\|%\|+@\|+\|`\)" contains=rubySymbolDelimiter
syn match rubySymbol	       "[]})\"':]\@1<!:\$\%(-.\|[`~<=>_,;:!?/.'"@$*\&+0]\)"			    contains=rubySymbolDelimiter
syn match rubySymbol	       "[]})\"':]\@1<!:\%(\$\|@@\=\)\=\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*"  contains=rubySymbolDelimiter
syn match rubySymbol	       "[]})\"':]\@1<!:\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\%([?!=]>\@!\)\=" contains=rubySymbolDelimiter

SynFold ':' syn region rubySymbol matchgroup=rubySymbolDelimiter start="[]})\"':]\@1<!:'"  end="'"  skip="\\\\\|\\'"  contains=rubyQuoteEscape,rubyBackslashEscape
SynFold ':' syn region rubySymbol matchgroup=rubySymbolDelimiter start="[]})\"':]\@1<!:\"" end="\"" skip="\\\\\|\\\"" contains=@rubyStringSpecial

syn match rubyCapitalizedMethod "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\u\%(\w\|[^\x00-\x7F]\)*\>\%(\s*(\)\@="

syn match  rubyBlockParameter	  "\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*" contained
syn region rubyBlockParameterList start="\%(\%(\<do\>\|{\)\_s*\)\@32<=|" end="|" oneline display contains=rubyBlockParameter

if exists('ruby_global_variable_error')
  syn match rubyGlobalVariableError "$[^A-Za-z_]"	display
  syn match rubyGlobalVariableError "$-[^0FIKWadilpvw]" display
endif

syn match rubyPredefinedVariable #$[!$&"'*+,./0:;<>?@\`~]#
syn match rubyPredefinedVariable "$\d\+"									    display
syn match rubyPredefinedVariable "$_\>"										    display
syn match rubyPredefinedVariable "$-[0FIWadilpvw]\>"								    display
syn match rubyPredefinedVariable "$\%(stderr\|stdin\|stdout\)\>"						    display
syn match rubyPredefinedVariable "$\%(DEBUG\|FILENAME\|LOADED_FEATURES\|LOAD_PATH\|PROGRAM_NAME\|SAFE\|VERBOSE\)\>" display
syn match rubyPredefinedConstant "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\%(ARGF\|ARGV\|ENV\|DATA\|FALSE\|NIL\|STDERR\|STDIN\|STDOUT\|TOPLEVEL_BINDING\|TRUE\)\>\%(\s*(\)\@!"
syn match rubyPredefinedConstant "\%(\%(^\|[^.]\)\.\s*\)\@<!\<\%(RUBY_\%(VERSION\|RELEASE_DATE\|PLATFORM\|PATCHLEVEL\|REVISION\|DESCRIPTION\|COPYRIGHT\|ENGINE\)\)\>\%(\s*(\)\@!"

" Deprecated/removed in 1.9
syn match rubyPredefinedVariable "$="
syn match rubyPredefinedVariable "$-K\>"		  display
syn match rubyPredefinedVariable "$\%(deferr\|defout\)\>" display
syn match rubyPredefinedVariable "$KCODE\>"		  display

syn cluster rubyGlobalVariable contains=rubyGlobalVariable,rubyPredefinedVariable,rubyGlobalVariableError

" Normal Regular Expressions {{{1
SynFold '/' syn region rubyRegexp matchgroup=rubyRegexpDelimiter start="\%(\%(^\|\<\%(and\|or\|while\|until\|unless\|if\|elsif\|when\|not\|then\|else\)\|[;\~=!|&(,{[<>?:*+-]\)\s*\)\@<=/" end="/[iomxneus]*" skip="\\\\\|\\/" contains=@rubyRegexpSpecial nextgroup=@rubyModifier skipwhite
SynFold '/' syn region rubyRegexp matchgroup=rubyRegexpDelimiter start="\%(\h\k*\s\+\)\@<=/\%([ \t=]\|$\)\@!"										   end="/[iomxneus]*" skip="\\\\\|\\/" contains=@rubyRegexpSpecial nextgroup=@rubyModifier skipwhite

" Generalized Regular Expressions {{{1
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r\z([~`!@#$%^&*_\-+=|\:;"',.?/]\)" end="\z1[iomxneus]*" skip="\\\\\|\\\z1" contains=@rubyRegexpSpecial nextgroup=@rubyModifier skipwhite
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r{"				   end="}[iomxneus]*"	skip="\\\\\|\\}"   contains=@rubyRegexpSpecial
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r<"				   end=">[iomxneus]*"	skip="\\\\\|\\>"   contains=@rubyRegexpSpecial,rubyNestedAngleBrackets
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r\["				   end="\][iomxneus]*"	skip="\\\\\|\\\]"  contains=@rubyRegexpSpecial
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r("				   end=")[iomxneus]*"	skip="\\\\\|\\)"   contains=@rubyRegexpSpecial
SynFold '%' syn region rubyRegexp matchgroup=rubyPercentRegexpDelimiter start="%r\z(\s\)"			   end="\z1[iomxneus]*" skip="\\\\\|\\\z1" contains=@rubyRegexpSpecial

" Characters {{{1
syn match rubyCharacter "\%(\w\|[]})\"'/]\)\@1<!\%(?\%(\\M-\\C-\|\\C-\\M-\|\\M-\\c\|\\c\\M-\|\\c\|\\C-\|\\M-\)\=\%(\\\o\{1,3}\|\\x\x\{1,2}\|\\\=\S\)\)"
syn match rubyCharacter "\%(\w\|[]})\"'/]\)\@1<!?\\u\%(\x\{4}\|{\x\{1,6}}\)"

" Normal Strings {{{1
let s:spell_cluster = exists('ruby_spellcheck_strings') ? ',@Spell' : ''
let s:fold_arg	    = s:foldable('string')		? ' fold'   : ''
exe 'syn region rubyString matchgroup=rubyStringDelimiter start="\"" end="\"" skip="\\\\\|\\\""  contains=@rubyStringSpecial'		       . s:spell_cluster . s:fold_arg
exe 'syn region rubyString matchgroup=rubyStringDelimiter start="''" end="''" skip="\\\\\|\\''"  contains=rubyQuoteEscape,rubyBackslashEscape' . s:spell_cluster . s:fold_arg
unlet s:spell_cluster s:fold_arg

" Shell Command Output {{{1
SynFold 'string' syn region rubyString matchgroup=rubyStringDelimiter start="`" end="`" skip="\\\\\|\\`" contains=@rubyStringSpecial

" Generalized Single Quoted Strings, Symbols, Array of Strings and Array of Symbols {{{1

" Non-bracket punctuation delimiters {{{2
let s:names = { '~': 'Tilde', '`': 'BackQuote', '!': 'Bang', '@': 'At', '#': 'Hash', '$': 'Dollar', '%': 'Percent', '^': 'Caret',
      \		'&': 'Ampersand', '*': 'Asterix', '_': 'Underscore', '-': 'Dash', '+': 'Plus', '=': 'Equals', '|': 'Bar',
      \		'\': 'Backslash', ':': 'Colon', ';': 'Semicolon', '"': 'DoubleQuote', "'": 'Quote', ',': 'Comma', '.': 'Period',
      \		'?': 'QuestionMark', '/': 'ForwardSlash' }

for s:delimiter in keys(s:names)
  let s:group = 'ruby' . s:names[s:delimiter] . 'Escape'

  if s:delimiter =~ '[\"]'
    let s:delimiter = '\' . s:delimiter
  endif

  exe 'syn match ' . s:group . ' "\V\\' . s:delimiter . '" contained display'
  exe 'syn cluster rubySingleCharEscape add=' . s:group
  exe 'SynFold ''%'' syn region rubyString matchgroup=rubyPercentStringDelimiter start="\V%q' . s:delimiter . '" end="\V' . s:delimiter . '" skip="\V\\\\\|\\' . s:delimiter . '" contains=rubyBackslashEscape,'		 . s:group . ' nextgroup=@rubyModifier skipwhite'
  exe 'SynFold ''%'' syn region rubyString matchgroup=rubyPercentStringDelimiter start="\V%w' . s:delimiter . '" end="\V' . s:delimiter . '" skip="\V\\\\\|\\' . s:delimiter . '" contains=rubyBackslashEscape,rubySpaceEscape,' . s:group . ' nextgroup=@rubyModifier skipwhite'
  exe 'SynFold ''%'' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="\V%s' . s:delimiter . '" end="\V' . s:delimiter . '" skip="\V\\\\\|\\' . s:delimiter . '" contains=rubyBackslashEscape,'		 . s:group . ' nextgroup=@rubyModifier skipwhite'
  exe 'SynFold ''%'' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="\V%i' . s:delimiter . '" end="\V' . s:delimiter . '" skip="\V\\\\\|\\' . s:delimiter . '" contains=rubyBackslashEscape,rubySpaceEscape,' . s:group . ' nextgroup=@rubyModifier skipwhite'
  exe 'hi def link ' . s:group . ' rubyStringEscape'
endfor

unlet s:delimiter s:group s:names
" }}}2

SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%q{"	  end="}"   skip="\\\\\|\\}"   contains=rubyBackslashEscape,rubyCurlyBracesEscape,rubyNestedCurlyBraces
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%q<"	  end=">"   skip="\\\\\|\\>"   contains=rubyBackslashEscape,rubyAngleBracketsEscape,rubyNestedAngleBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%q\["	  end="\]"  skip="\\\\\|\\\]"  contains=rubyBackslashEscape,rubySquareBracketsEscape,rubyNestedSquareBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%q("	  end=")"   skip="\\\\\|\\)"   contains=rubyBackslashEscape,rubyParenthesesEscape,rubyNestedParentheses
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%q\z(\s\)" end="\z1" skip="\\\\\|\\\z1" contains=rubyBackslashEscape,rubySpaceEscape

SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%w{"	  end="}"   skip="\\\\\|\\}"   contains=rubyBackslashEscape,rubySpaceEscape,rubyCurlyBracesEscape,rubyNestedCurlyBraces
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%w<"	  end=">"   skip="\\\\\|\\>"   contains=rubyBackslashEscape,rubySpaceEscape,rubyAngleBracketsEscape,rubyNestedAngleBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%w\["	  end="\]"  skip="\\\\\|\\\]"  contains=rubyBackslashEscape,rubySpaceEscape,rubySquareBracketsEscape,rubyNestedSquareBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%w("	  end=")"   skip="\\\\\|\\)"   contains=rubyBackslashEscape,rubySpaceEscape,rubyParenthesesEscape,rubyNestedParentheses

SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%s{"	  end="}"   skip="\\\\\|\\}"   contains=rubyBackslashEscape,rubyCurlyBracesEscape,rubyNestedCurlyBraces
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%s<"	  end=">"   skip="\\\\\|\\>"   contains=rubyBackslashEscape,rubyAngleBracketsEscape,rubyNestedAngleBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%s\["	  end="\]"  skip="\\\\\|\\\]"  contains=rubyBackslashEscape,rubySquareBracketsEscape,rubyNestedSquareBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%s("	  end=")"   skip="\\\\\|\\)"   contains=rubyBackslashEscape,rubyParenthesesEscape,rubyNestedParentheses
SynFold '%' syn region rubyString matchgroup=rubyPercentSymbolDelimiter start="%s\z(\s\)" end="\z1" skip="\\\\\|\\\z1" contains=rubyBackslashEscape,rubySpaceEscape

SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%i{"	  end="}"   skip="\\\\\|\\}"   contains=rubyBackslashEscape,rubySpaceEscape,rubyCurlyBracesEscape,rubyNestedCurlyBraces
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%i<"	  end=">"   skip="\\\\\|\\>"   contains=rubyBackslashEscape,rubySpaceEscape,rubyAngleBracketsEscape,rubyNestedAngleBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%i\["	  end="\]"  skip="\\\\\|\\\]"  contains=rubyBackslashEscape,rubySpaceEscape,rubySquareBracketsEscape,rubyNestedSquareBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%i("	  end=")"   skip="\\\\\|\\)"   contains=rubyBackslashEscape,rubySpaceEscape,rubyParenthesesEscape,rubyNestedParentheses

" Generalized Double Quoted Strings, Symbols, Array of Strings, Array of Symbols and Shell Command Output {{{1
" Note: %= is not matched here as the beginning of a double quoted string
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%\z([~`!@#$%^&*_\-+|\:;"',.?/]\)"       end="\z1" skip="\\\\\|\\\z1" contains=@rubyStringSpecial nextgroup=@rubyModifier skipwhite
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[QWx]\z([~`!@#$%^&*_\-+=|\:;"',.?/]\)" end="\z1" skip="\\\\\|\\\z1" contains=@rubyStringSpecial
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[QWx]\={"			       end="}"	 skip="\\\\\|\\}"   contains=@rubyStringSpecial,rubyNestedCurlyBraces
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[QWx]\=<"			       end=">"	 skip="\\\\\|\\>"   contains=@rubyStringSpecial,rubyNestedAngleBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[QWx]\=\["			       end="\]"  skip="\\\\\|\\\]"  contains=@rubyStringSpecial,rubyNestedSquareBrackets
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[QWx]\=("			       end=")"	 skip="\\\\\|\\)"   contains=@rubyStringSpecial,rubyNestedParentheses
SynFold '%' syn region rubyString matchgroup=rubyPercentStringDelimiter start="%[Qx]\z(\s\)"			       end="\z1" skip="\\\\\|\\\z1" contains=@rubyStringSpecial

" Array of interpolated Symbols
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%I\z([~`!@#$%^&*_\-+=|\:;"',.?/]\)" end="\z1" skip="\\\\\|\\\z1" contains=@rubyStringSpecial nextgroup=@rubyModifier skipwhite
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%I{"				   end="}"   skip="\\\\\|\\}"	contains=@rubyStringSpecial,rubyNestedCurlyBraces
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%I<"				   end=">"   skip="\\\\\|\\>"	contains=@rubyStringSpecial,rubyNestedAngleBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%I\["				   end="\]"  skip="\\\\\|\\\]"	contains=@rubyStringSpecial,rubyNestedSquareBrackets
SynFold '%' syn region rubySymbol matchgroup=rubyPercentSymbolDelimiter start="%I("				   end=")"   skip="\\\\\|\\)"	contains=@rubyStringSpecial,rubyNestedParentheses

" Here Documents {{{1
syn region rubyHeredocStart matchgroup=rubyHeredocDelimiter start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<[-~]\=\zs\%(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)+ end=+$+ oneline contains=ALLBUT,@rubyNotTop
syn region rubyHeredocStart matchgroup=rubyHeredocDelimiter start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<[-~]\=\zs"\%([^"]*\)"+					  end=+$+ oneline contains=ALLBUT,@rubyNotTop
syn region rubyHeredocStart matchgroup=rubyHeredocDelimiter start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<[-~]\=\zs'\%([^']*\)'+					  end=+$+ oneline contains=ALLBUT,@rubyNotTop
syn region rubyHeredocStart matchgroup=rubyHeredocDelimiter start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<[-~]\=\zs`\%([^`]*\)`+					  end=+$+ oneline contains=ALLBUT,@rubyNotTop

SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<\z(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+2   matchgroup=rubyHeredocDelimiter end=+^\z1$+	contains=rubyHeredocStart,@rubyStringSpecial keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<"\z([^"]*\)"\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+2					      matchgroup=rubyHeredocDelimiter end=+^\z1$+	contains=rubyHeredocStart,@rubyStringSpecial keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<'\z([^']*\)'\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+2					      matchgroup=rubyHeredocDelimiter end=+^\z1$+	contains=rubyHeredocStart		     keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})"']\)\s\|\w\)\@<!<<`\z([^`]*\)`\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+2					      matchgroup=rubyHeredocDelimiter end=+^\z1$+	contains=rubyHeredocStart,@rubyStringSpecial keepend

SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})]\)\s\|\w\)\@<!<<[-~]\z(\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*\)\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+3 matchgroup=rubyHeredocDelimiter end=+^\s*\zs\z1$+ contains=rubyHeredocStart,@rubyStringSpecial keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})]\)\s\|\w\)\@<!<<[-~]"\z([^"]*\)"\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+3				      matchgroup=rubyHeredocDelimiter end=+^\s*\zs\z1$+ contains=rubyHeredocStart,@rubyStringSpecial keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})]\)\s\|\w\)\@<!<<[-~]'\z([^']*\)'\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+3				      matchgroup=rubyHeredocDelimiter end=+^\s*\zs\z1$+ contains=rubyHeredocStart		     keepend
SynFold '<<' syn region rubyString start=+\%(\%(class\|::\|\.\@1<!\.\)\_s*\|\%([]})]\)\s\|\w\)\@<!<<[-~]`\z([^`]*\)`\ze\%(.*<<[-~]\=['`"]\=\h\)\@!+hs=s+3				      matchgroup=rubyHeredocDelimiter end=+^\s*\zs\z1$+ contains=rubyHeredocStart,@rubyStringSpecial keepend

" Module, Class, Method and Alias Declarations {{{1
syn match rubyAliasDeclaration	"[^[:space:];#.()]\+" contained contains=rubySymbol,@rubyGlobalVariable nextgroup=rubyAliasDeclaration2 skipwhite
syn match rubyAliasDeclaration2 "[^[:space:];#.()]\+" contained contains=rubySymbol,@rubyGlobalVariable
syn match rubyMethodDeclaration "[^[:space:];#(]\+"   contained contains=rubyConstant,rubyBoolean,rubyPseudoVariable,rubyInstanceVariable,rubyClassVariable,rubyGlobalVariable
syn match rubyClassDeclaration	"[^[:space:];#<]\+"   contained contains=rubyClassName,rubyOperator
syn match rubyModuleDeclaration "[^[:space:];#<]\+"   contained contains=rubyModuleName,rubyOperator

syn match rubyMethodName "\<[_[:alpha:]][_[:alnum:]]*[?!=]\=[[:alnum:]_.:?!=]\@!"										      contained containedin=rubyMethodDeclaration
syn match rubyMethodName "\%(\s\|^\)\@1<=[_[:alpha:]][_[:alnum:]]*[?!=]\=\%(\s\|$\)\@="										      contained containedin=rubyAliasDeclaration,rubyAliasDeclaration2
syn match rubyMethodName "\%([[:space:].]\|^\)\@1<=\%(\[\]=\=\|\*\*\|[-+!~]@\=\|[*/%|&^~]\|<<\|>>\|[<>]=\=\|<=>\|===\|[=!]=\|[=!]\~\|!\|`\)\%([[:space:];#(]\|$\)\@=" contained containedin=rubyAliasDeclaration,rubyAliasDeclaration2,rubyMethodDeclaration

syn cluster rubyDeclaration contains=rubyAliasDeclaration,rubyAliasDeclaration2,rubyMethodDeclaration,rubyModuleDeclaration,rubyClassDeclaration,rubyMethodName,rubyBlockParameter

" Keywords {{{1
" Note: the following keywords have already been defined:
" begin case class def do end for if module unless until while
syn match rubyControl	     "\<\%(and\|break\|in\|next\|not\|or\|redo\|retry\|return\)\>[?!]\@!"
syn match rubyOperator	     "\<defined?" display
syn match rubyKeyword	     "\<\%(super\|yield\)\>[?!]\@!"
syn match rubyBoolean	     "\<\%(true\|false\)\>[?!]\@!"
syn match rubyPseudoVariable "\<\%(nil\|self\|__ENCODING__\|__dir__\|__FILE__\|__LINE__\|__callee__\|__method__\)\>[?!]\@!" " TODO: reorganise
syn match rubyBeginEnd	     "\<\%(BEGIN\|END\)\>[?!]\@!"

" Expensive Mode {{{1
" Match 'end' with the appropriate opening keyword for syntax based folding
" and special highlighting of module/class/method definitions
if !exists("b:ruby_no_expensive") && !exists("ruby_no_expensive")
  syn match rubyDefine "\<alias\>"  nextgroup=rubyAliasDeclaration  skipwhite skipnl
  syn match rubyDefine "\<def\>"    nextgroup=rubyMethodDeclaration skipwhite skipnl
  syn match rubyDefine "\<undef\>"  nextgroup=rubyMethodName	    skipwhite skipnl
  syn match rubyClass  "\<class\>"  nextgroup=rubyClassDeclaration  skipwhite skipnl
  syn match rubyModule "\<module\>" nextgroup=rubyModuleDeclaration skipwhite skipnl

  SynFold 'def'    syn region rubyMethodBlock start="\<def\>"	 matchgroup=rubyDefine end="\%(\<def\_s\+\)\@<!\<end\>" contains=ALLBUT,@rubyNotTop
  SynFold 'class'  syn region rubyClassBlock  start="\<class\>"  matchgroup=rubyClass  end="\<end\>"			contains=ALLBUT,@rubyNotTop
  SynFold 'module' syn region rubyModuleBlock start="\<module\>" matchgroup=rubyModule end="\<end\>"			contains=ALLBUT,@rubyNotTop

  " modifiers
  syn match rubyLineContinuation    "\\$" nextgroup=@rubyModifier skipwhite skipnl
  syn match rubyConditionalModifier "\<\%(if\|unless\)\>"
  syn match rubyRepeatModifier	    "\<\%(while\|until\)\>"
  syn match rubyRescueModifier	    "\<rescue\>"

  syn cluster rubyModifier contains=rubyConditionalModifier,rubyRepeatModifier,rubyRescueModifier

  SynFold 'do' syn region rubyDoBlock matchgroup=rubyControl start="\<do\>" end="\<end\>" contains=ALLBUT,@rubyNotTop

  " curly bracket block or hash literal
  SynFold '{' syn region rubyCurlyBlock   matchgroup=rubyCurlyBlockDelimiter start="{"			   end="}" contains=ALLBUT,@rubyNotTop
  SynFold '[' syn region rubyArrayLiteral matchgroup=rubyArrayDelimiter      start="\%(\w\|[\]})]\)\@<!\[" end="]" contains=ALLBUT,@rubyNotTop

  " statements without 'do'
  SynFold 'begin' syn region rubyBlockExpression matchgroup=rubyControl     start="\<begin\>" end="\<end\>" contains=ALLBUT,@rubyNotTop
  SynFold 'case'  syn region rubyCaseExpression  matchgroup=rubyConditional start="\<case\>"  end="\<end\>" contains=ALLBUT,@rubyNotTop

  SynFold 'if' syn region rubyConditionalExpression matchgroup=rubyConditional start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+=-]\|\<then\s\|\%(\<\h\w*\)\@<![?!]\)\s*\)\@<=\%(if\|unless\)\>" end="\%(\%(\%(\.\@1<!\.\)\|::\)\s*\)\@<!\<end\>" contains=ALLBUT,@rubyNotTop

  syn match rubyConditional "\<\%(then\|else\|when\)\>[?!]\@!"	contained containedin=rubyCaseExpression
  syn match rubyConditional "\<\%(then\|else\|elsif\)\>[?!]\@!" contained containedin=rubyConditionalExpression

  syn match   rubyExceptionHandler  "\<\%(\%(\%(;\|^\)\s*\)\@<=rescue\|else\|ensure\)\>[?!]\@!" contained containedin=rubyBlockExpression,rubyDoBlock
  syn match   rubyExceptionHandler1 "\<\%(\%(\%(;\|^\)\s*\)\@<=rescue\|else\|ensure\)\>[?!]\@!" contained containedin=rubyModuleBlock,rubyClassBlock,rubyMethodBlock
  syn cluster rubyExceptionHandler  contains=rubyExceptionHandler,rubyExceptionHandler1

  " statements with optional 'do'
  syn region rubyOptionalDoLine matchgroup=rubyRepeat start="\<for\>[?!]\@!" start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+=-]\|\%(\<\h\w*\)\@<![!?]\)\s*\)\@<=\<\%(until\|while\)\>" matchgroup=rubyOptionalDo end="\<do\>" end="\ze\%(;\|$\)" oneline contains=ALLBUT,@rubyNotTop

  SynFold 'for' syn region rubyRepeatExpression start="\<for\>[?!]\@!" start="\%(\%(^\|\.\.\.\=\|[{:,;([<>~\*/%&^|+=-]\|\%(\<\h\w*\)\@<![!?]\)\s*\)\@<=\<\%(until\|while\)\>" matchgroup=rubyRepeat end="\<end\>" contains=ALLBUT,@rubyNotTop nextgroup=rubyOptionalDoLine

  if !exists("ruby_minlines")
    let ruby_minlines = 500
  endif
  exe "syn sync minlines=" . ruby_minlines

else
  syn match rubyControl "\<def\>[?!]\@!"    nextgroup=rubyMethodDeclaration skipwhite skipnl
  syn match rubyControl "\<class\>[?!]\@!"  nextgroup=rubyClassDeclaration  skipwhite skipnl
  syn match rubyControl "\<module\>[?!]\@!" nextgroup=rubyModuleDeclaration skipwhite skipnl
  syn match rubyControl "\<\%(case\|begin\|do\|for\|if\|unless\|while\|until\|else\|elsif\|rescue\|ensure\|then\|when\|end\)\>[?!]\@!"
  syn match rubyKeyword "\<\%(alias\|undef\)\>[?!]\@!"
endif

" Special Methods {{{1
if !exists("ruby_no_special_methods")
  syn keyword rubyAccess    public protected private public_class_method private_class_method public_constant private_constant module_function
  " attr is a common variable name
  syn match   rubyAttribute "\%(\%(^\|;\)\s*\)\@<=attr\>\(\s*[.=]\)\@!"
  syn keyword rubyAttribute attr_accessor attr_reader attr_writer
  syn match   rubyControl   "\<\%(exit!\|\%(abort\|at_exit\|exit\|fork\|loop\|trap\)\>[?!]\@!\)"
  syn keyword rubyEval	    eval class_eval instance_eval module_eval
  syn keyword rubyException raise fail catch throw
  syn keyword rubyInclude   autoload gem load require require_relative
  syn keyword rubyKeyword   callcc caller lambda proc
  " false positive with 'include?'
  syn match   rubyMacro     "\<include\>[?!]\@!"
  syn keyword rubyMacro     extend prepend refine using
  syn keyword rubyMacro     alias_method define_method define_singleton_method remove_method undef_method
endif

" Comments and Documentation {{{1
syn match   rubySharpBang    "\%^#!.*" display
syn keyword rubyTodo	     FIXME NOTE TODO OPTIMIZE HACK REVIEW XXX todo contained
syn match   rubyEncoding     "[[:alnum:]-]\+" contained display
syn match   rubyMagicComment "\c\%<3l#\s*\zs\%(coding\|encoding\):"					contained nextgroup=rubyEncoding skipwhite
syn match   rubyMagicComment "\c\%<10l#\s*\zs\%(frozen_string_literal\|warn_indent\|warn_past_scope\):" contained nextgroup=rubyBoolean  skipwhite
syn match   rubyComment	     "#.*" contains=@rubyCommentSpecial,rubySpaceError,@Spell

syn cluster rubyCommentSpecial contains=rubySharpBang,rubyTodo,rubyMagicComment
syn cluster rubyCommentNotTop  contains=@rubyCommentSpecial,rubyEncoding

if !exists("ruby_no_comment_fold") && s:foldable('#')
  syn region rubyMultilineComment start="^\s*#.*\n\%(^\s*#\)\@=" end="^\s*#.*\n\%(^\s*#\)\@!" contains=rubyComment transparent fold keepend
  syn region rubyDocumentation	  start="^=begin\ze\%(\s.*\)\=$" end="^=end\%(\s.*\)\=$"      contains=rubySpaceError,rubyTodo,@Spell fold
else
  syn region rubyDocumentation	  start="^=begin\s*$"		 end="^=end\s*$"              contains=rubySpaceError,rubyTodo,@Spell
endif

" {{{1 Useless line continuations
syn match rubyUselessLineContinuation "\%([.:,;{([<>~\*%&^|+=-]\|\w\@1<![?!]\)\s*\zs\\$" nextgroup=rubyUselessLineContinuation skipwhite skipempty
syn match rubyUselessLineContinuation "\\$"						 nextgroup=rubyUselessLineContinuation skipwhite skipempty contained

" Keyword Nobbling {{{1
" Note: this is a hack to prevent 'keywords' being highlighted as such when called as methods with an explicit receiver
syn match rubyKeywordAsMethod "\%(\%(\.\@1<!\.\)\|::\)\_s*\%([_[:lower:]][_[:alnum:]]*\|\<\%(BEGIN\|END\)\>\)" transparent contains=NONE
syn match rubyKeywordAsMethod "\(defined?\|exit!\)\@!\<[_[:lower:]][_[:alnum:]]*[?!]"			       transparent contains=NONE

" More Symbols {{{1
syn match rubySymbol "\%([{(,]\_s*\)\@<=\l\w*[!?]\=::\@!"he=e-1
syn match rubySymbol "[]})\"':]\@1<!\<\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*[!?]\=:[[:space:],]\@="he=e-1
syn match rubySymbol "\%([{(,]\_s*\)\@<=[[:space:],{]\l\w*[!?]\=::\@!"hs=s+1,he=e-1
syn match rubySymbol "[[:space:],{(]\%(\h\|[^\x00-\x7F]\)\%(\w\|[^\x00-\x7F]\)*[!?]\=:[[:space:],]\@="hs=s+1,he=e-1

" __END__ Directive {{{1
SynFold '__END__' syn region rubyData matchgroup=rubyDataDirective start="^__END__$" end="\%$"

" Default Highlighting {{{1
hi def link rubyClass			rubyDefine
hi def link rubyModule			rubyDefine
hi def link rubyExceptionHandler1	rubyDefine
hi def link rubyDefine			Define
hi def link rubyAccess			rubyMacro
hi def link rubyAttribute		rubyMacro
hi def link rubyMacro			Macro
hi def link rubyMethodName		rubyFunction
hi def link rubyFunction		Function
hi def link rubyConditional		Conditional
hi def link rubyConditionalModifier	rubyConditional
hi def link rubyExceptionHandler	rubyConditional
hi def link rubyRescueModifier		rubyExceptionHandler
hi def link rubyRepeat			Repeat
hi def link rubyRepeatModifier		rubyRepeat
hi def link rubyOptionalDo		rubyRepeat
hi def link rubyControl			Statement
hi def link rubyInclude			Include
hi def link rubyInteger			Number
hi def link rubyCharacter		Character
hi def link rubyFloat			Float
hi def link rubyBoolean			Boolean
hi def link rubyException		Exception
if !exists("ruby_no_identifiers")
  hi def link rubyIdentifier		Identifier
else
  hi def link rubyIdentifier		NONE
endif
hi def link rubyClassVariable		rubyIdentifier
hi def link rubyConstant		Type
hi def link rubyClassName		rubyConstant
hi def link rubyModuleName		rubyConstant
hi def link rubyGlobalVariable		rubyIdentifier
hi def link rubyInstanceVariable	rubyIdentifier
hi def link rubyPredefinedIdentifier	rubyIdentifier
hi def link rubyPredefinedConstant	rubyPredefinedIdentifier
hi def link rubyPredefinedVariable	rubyPredefinedIdentifier
hi def link rubySymbol			Constant
hi def link rubyKeyword			Keyword

hi def link rubyOperator		Operator
hi def link rubyDotOperator		Operator
hi def link rubyTernaryOperator		Operator
hi def link rubyArithmeticOperator	Operator
hi def link rubyComparisonOperator	Operator
hi def link rubyBitwiseOperator		Operator
hi def link rubyBooleanOperator		Operator
hi def link rubyRangeOperator		Operator
hi def link rubyAssignmentOperator	Operator
hi def link rubyEqualityOperator	Operator
hi def link rubyScopeOperator		Operator

hi def link rubyBeginEnd		Statement
hi def link rubyEval			Statement
hi def link rubyPseudoVariable		Constant
hi def link rubyCapitalizedMethod	rubyLocalVariableOrMethod

hi def link rubyComment			Comment
hi def link rubyEncoding		Constant
hi def link rubyMagicComment		SpecialComment
hi def link rubyData			Comment
hi def link rubyDataDirective		Delimiter
hi def link rubyDocumentation		Comment
hi def link rubyTodo			Todo

hi def link rubyBackslashEscape		rubyStringEscape
hi def link rubyQuoteEscape		rubyStringEscape
hi def link rubySpaceEscape		rubyStringEscape
hi def link rubyParenthesesEscape	rubyStringEscape
hi def link rubyCurlyBracesEscape	rubyStringEscape
hi def link rubyAngleBracketsEscape	rubyStringEscape
hi def link rubySquareBracketsEscape	rubyStringEscape
hi def link rubyStringEscape		Special

hi def link rubyInterpolationDelimiter	Delimiter
hi def link rubySharpBang		PreProc
hi def link rubyStringDelimiter		Delimiter
hi def link rubyHeredocDelimiter	rubyStringDelimiter
hi def link rubyPercentRegexpDelimiter	rubyRegexpDelimiter
hi def link rubyPercentStringDelimiter	rubyStringDelimiter
hi def link rubyPercentSymbolDelimiter	rubySymbolDelimiter
hi def link rubyRegexpDelimiter		rubyStringDelimiter
hi def link rubySymbolDelimiter		rubySymbol
hi def link rubyString			String
hi def link rubyRegexpEscape		rubyRegexpSpecial
hi def link rubyRegexpQuantifier	rubyRegexpSpecial
hi def link rubyRegexpAnchor		rubyRegexpSpecial
hi def link rubyRegexpDot		rubyRegexpCharClass
hi def link rubyRegexpCharClass		rubyRegexpSpecial
hi def link rubyRegexpIntersection	rubyRegexpSpecial
hi def link rubyRegexpSpecial		Special
hi def link rubyRegexpComment		Comment
hi def link rubyRegexp			rubyString

hi def link rubyError			Error
if exists("ruby_line_continuation_error")
  hi def link rubyUselessLineContinuation rubyError
endif
hi def link rubyGlobalVariableError	rubyError
hi def link rubySpaceError		rubyError

" Postscript {{{1
let b:current_syntax = "ruby"

let &cpo = s:cpo_sav
unlet! s:cpo_sav

delc SynFold

" vim: nowrap sw=2 sts=2 ts=8 noet fdm=marker:
