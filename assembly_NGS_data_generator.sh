#!/bin/bash

#this is a simple bash script written to generate fake "sequence" data from a 
#text file for an activity that illustrates the differences between genome
#assemblies from short or long read NGS machines
#also accessible are two example text files, mlkjr.txt and churchill.txt
#both are from speeches with a large number of repetitive phrases, to show
#the problems NGS data has with genomic repeats
#crc 161027

#files takes 3 inputs: 
#1) number of short/illumina reads 
#2) number of long/pacbio reads
#3) name of the input text file
#output files are left in present directory

#clear out previous temp files
rm ilmn.tmp pacb.tmp

#count words in the input text file
chars=`cat $3 | wc -c`
charsNoSpace=`cat $3 | sed 's, ,,g' | wc -c`

#begin output file with date and settings
date > $3_ilmn$1_pacb$2_sequences.txt
echo $1 illumina reads >> $3_ilmn$1_pacb$2_sequences.txt
echo $2 pacbio reads >> $3_ilmn$1_pacb$2_sequences.txt
echo $3 original text >> $3_ilmn$1_pacb$2_sequences.txt
cat $3  >> $3_ilmn$1_pacb$2_sequences.txt

#create short reads/illumina data
for n in `seq 1 $1`
	do
	#length of illumina sequence
	ilmn=16
	#number of errors per sequence
	ilmnErr=1

	#pick a start site from the text doc
	a=`echo $(( $RANDOM % $(( chars - $ilmn )) + 1 ))`
	b=$(( a + $ilmn - 1 ))

	#pull out the sequence
	seq=`cut -c$a-$b $3 | sed 's, ,1,g'`

	#set up variable w/errored seq info to use in for loop
	errSeqFinal=`echo $seq`

	#loop to introduce correct number of errors
	for m in `seq 1 $ilmnErr`
	do
		#introduce errors
		errLoc=`echo $(( $RANDOM % $(( ilmn - 2 )) + 2 ))`
		errNo=`echo $(( $RANDOM % $(( chars - 1 )) + 1 ))`
		errChar=`cat $3 | sed 's, ,1,g' | cut -c$errNo`
		before=$(( $errLoc - 1 ))
		after=$(( $errLoc + 1 ))

		#re-"stitch" the correct seq around the errors
		seq1=`echo $errSeqFinal | cut -c1-$before` 
		seq2=`echo $errChar`
		seq3=`echo $errSeqFinal | cut -c$after-$ilmn`
		errSeq=`echo $seq1``echo $seq2``echo $seq3`
		errSeqFinal=`echo "|"``echo $errSeq | sed 's,1, ,g'`
	done

	#pipe symbol is used to dilineate sequence start and end
	#print seq to terminal for visual inspection
	echo $errSeqFinal"|"

	#print to file
	echo $errSeqFinal >> ilmn.tmp
done

#create long reads/pacbio data
for n in `seq 1 $2`
	do
	#length of pacbio sequence
	pacbio=75
	#number of errors per sequence
	pacbioErr=22

	a=`echo $(( $RANDOM % $(( chars - $pacbio )) + 1 ))`
	b=$(( a + $pacbio - 1 ))

	seq=`cut -c$a-$b $3 | sed 's, ,1,g'`

	errSeqFinal=`echo $seq`


	#error introduction
	for m in `seq 1 $pacbioErr`
		do
		#introduce errors
		errLoc=`echo $(( $RANDOM % $(( pabcio - 2 )) + 2 ))`
		errNo=`echo $(( $RANDOM % $charsNoSpace + 1 ))`
		errChar=`cat $3 | sed 's, ,,g' | cut -c$errNo`
		before=$(( $errLoc - 1 ))
		after=$(( $errLoc + 1 ))

		#re-"stitch" the correct seq around the errors
		seq1=`echo $errSeqFinal | cut -c1-$before` 
		seq2=`echo $errChar`
		seq3=`echo $errSeqFinal | cut -c$after-$pacbio`
		errSeq=`echo $seq1``echo $seq2``echo $seq3`
		errSeqFinal=`echo $errSeq | sed 's,11,  ,g' | sed 's,1, ,g'`

		done

	#pipe symbol is used to dilineate sequence start and end
	#print seq to terminal for visual inspection
	errSeqFinal=`echo "|"``echo $errSeq | sed 's,1, ,g'`
	echo $errSeqFinal"|"

	#print to file
	echo $errSeqFinal >> pacb.tmp
	
done

#insert space in outpuf file
echo >> $3_ilmn$1_pacb$2_sequences.txt

#write pacbio reads to file
tr -d '\n' < pacb.tmp >> $3_ilmn$1_pacb$2_sequences.txt
#write illumina reads to file
tr -d '\n' < ilmn.tmp >> $3_ilmn$1_pacb$2_sequences.txt