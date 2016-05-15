#!/bin/sh

#names of the two playersi
echo "\nThe name of the first player is: "
read name1
echo "\nThe name of the second player is: "
read name2

#making a dir if it is not exist
if ! [ -d .tic-tac-toe ]
	then
	mkdir .tic-tac-toe
fi

#making a file
timestamp=$(date +%y%m%d%H%M%S)
file=$(echo "$name1-$name2-$timestamp.log")
touch $file

#symbols for the two players
echo "\nThe symbol for $name1 is "
read symbol1
echo "\nThe symbol for $name2 is "
read symbol2

echo "\n$name1 plays with $symbol1" | tee -a $file
echo "$name2 plays with $symbol2\n" | tee -a $file

# get a field
field(){
lines=$(head -n$(( ( $1 - 1 ) * 3 + $2 )) $3 | tail -n1)
echo "$lines"
}

# drawing a new board
board() {
touch new_board.tmp
for i in $(seq 1 3)
do
	for j in $(seq 1 3)
	do
		f=$(field $i $j board.tmp)
		if [ $i -ne $1 ] || [ $j -ne $2 ]
		then
			echo "$f" >>  new_board.tmp
		else
			echo "$3" >>  new_board.tmp
		fi
	done
done
mv new_board.tmp board.tmp
}

# check who player wins if there is a winning row
win_test(){
	h1s=$( grep "$symbol1" check.tmp |wc -l)

	if [ $h1s -eq 3 ]
	then
		echo "$name1, you win"
		rm board.tmp
		rm check.tmp
		exit
	fi
 
	h2s=$(grep "$symbol2" check.tmp | wc -l)
	if [ $h2s -eq 3 ]
	then      
		echo "$name2, you win"
		rm board.tmp
		rm check.tmp
		exit
	fi
}


# empty file for the board
touch board.tmp

#drawing the gameboard
echo "The gameboard looks like this: " | tee -a $file
for i in $(seq 1 7)    
do
	if [ $i -eq 2 ] || [ $i -eq 4 ] || [ $i -eq 6 ]
		then 
	 	echo " *   *   *   *" | tee -a $file
	else
		echo " *************" | tee -a $file
	fi 
done

#moves

for moves in $(seq 1 9)
do
# move
	# player one or player two
	if [ $moves -eq 1 ] || [ $moves -eq 3 ] || [ $moves -eq 5 ] || [ $moves -eq 7 ] || [ $moves -eq 9 ]
	then
		echo "$name1, please enter a move: " | tee -a $file
		read x1 y1
	else
		echo "$name2, please enter a move: " | tee -a $file
		read x1 y1
	fi

#validate first coordinate
	until [ $x1 -eq 1 ] || [ $x1 -eq 2 ] || [ $x1 -eq 3 ]
	do
		echo "the first coordinate is incorrect, please enter a new move, which is 1, 2 or 3"
		read x1 y1
	done
#validate second coordinate
	until [ $y1 -eq 1 ] || [ $y1 -eq 2 ] || [ $y1 -eq 3 ]
	do
		echo "the second coordinate is incorrect, please enter a new move, which is 1, 2 or 3"
		read x1 y1
	done

#checking if the move have been made already and the board is not empty there
	while [ $(grep "$x1 $y1" $file| wc -l) -gt 0 ]
	do
		echo "error, already there"
		read x1 y1
	done

	echo "move: $x1 $y1" | tee -a $file
	
#deciding witch symbol must appear on the board
	if [ $moves -eq 1 ] || [ $moves -eq 3 ] || [ $moves -eq 5 ] || [ $moves -eq 7 ] || [ $moves -eq 9 ]
	then
		current_symbol=$symbol1
	else
		current_symbol=$symbol2
	fi

	# echo "move $moves symbol $current_symbol" | tee -a $file

board $x1 $y1 $current_symbol

	echo " *************" | tee -a $file
	for i in $(seq 1 3)
	do
		for j in $(seq 1 3)
		do
			b=$(field $i $j board.tmp)
			if [ -z "$b" ]
			then
				b=" " 
			fi
			echo -n " * $b" | tee -a $file
		done
		echo " * " | tee -a $file
			echo " *************" | tee -a $file
	done


touch check.tmp

# check for winning row	
	for i in $(seq 1 3)
	do
		$(head -n3 board.tmp > check.tmp)
		win_test
		$(head -n6 board.tmp | tail -n3 > check.tmp)
		win_test
		$(tail -n3 board.tmp > check.tmp)
		win_test
	

# winnig first col
		$(head -n1 board.tmp > check.tmp)
		$(head -n4 board.tmp | tail -n1 >> check.tmp)
		$(tail -n3 board.tmp | head -n1 >> check.tmp)
		win_test

# winning second col
		$(head -n2 board.tmp | tail -n1 > check.tmp)
		$(head -n5 board.tmp | tail -n1 >> check.tmp)
		$(tail -n2 board.tmp | head -n1 >> check.tmp)
		win_test

# winning third col
		$(head -n3 board.tmp | tail -n1 > check.tmp)
		$(tail -n4 board.tmp | head -n1 >> check.tmp)
		$(tail -n1 board.tmp >> check.tmp)
		win_test

# winning diagonal first

		$(head -n1 board.tmp > check.tmp)
		$(head -n5 board.tmp | tail -n1 >> check.tmp)
		$(tail -n1 board.tmp >> check.tmp)
		win_test

# winning diagonal second
		$(head -n3 board.tmp | tail -n1 > check.tmp)
		$(head -n5 board.tmp | tail -n1 >> check.tmp)
		$(tail -n3 board.tmp | head -n1 >> check.tmp)
		win_test

	done

done
rm board.tmp
rm check.tmp
echo "Nobody wins"

