param($OutputFile)
cpdf -merge -idir . -remove-duplicate-fonts -merge-add-bookmarks -o $OutputFile
cpdf -blacktext $OutputFile
cpdfsqueeze.exe $OutputFile $OutputFile

