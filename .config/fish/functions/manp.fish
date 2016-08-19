function manp --description 'Open a man page in Skim'
	man -t $argv | ps2pdf14 - - | open -f -a Skim
end
