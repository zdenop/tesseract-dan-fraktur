#!/bin/sh
LANGCODE=slk_frak

for i in *.tif
  do echo $i:
  tesseract $i ${i%.tif} nobatch box.train
done

unicharset_extractor *.box
cat unicharset | sed -e "1d;/Joined/d;/Broken/d" > unicharset.tmp
awk 'END { print NR }' unicharset.tmp > unicharset.edited
cat unicharset.tmp >> unicharset.edited
rm -f unicharset.tmp

shapeclustering -F font_properties -U unicharset.edited *.tr
mftraining -F font_properties -U unicharset.edited -O $LANGCODE.unicharset *.tr
cntraining *.tr
for i in inttemp normproto pffmtable shapetable
  do mv -f $i $LANGCODE.$i
done

wordlist2dawg number $LANGCODE.number-dawg $LANGCODE.unicharset
wordlist2dawg punc $LANGCODE.punc-dawg $LANGCODE.unicharset
wordlist2dawg word_list $LANGCODE.word-dawg $LANGCODE.unicharset
wordlist2dawg frequency_list $LANGCODE.freq-dawg $LANGCODE.unicharset
combine_tessdata $LANGCODE.
cp $LANGCODE.traineddata $TESSDATA_PREFIX/tessdata/
