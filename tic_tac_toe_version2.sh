#!\bin\sh

#names of the two players
echo "\nThe name of the first player is: "
read name1
echo "\nThe name of the second player is: "
read name2

#making a dir if it is not exist
if ! [ -d ~/tic-tac-toe ]
	then
	mkdir ~/tic-tac-toe
fi

#making a file
timestamp=$(date +%y%m%d%H%M%S)
file_name=$(echo "$name1-$name2-$timestamp.log")
file=~/tic-tac-toe/$file_name
touch $file

#symbols for the two players
touch symbol.tmp

echo "\nThe symbol for $name1 is "
read symbol1
echo "$symbol1" >> symbol.tmp

# validation of the first symbol
while  [ $(( $(grep "[a-z0-9A-Z]" symbol.tmp| wc -m) - 1 )) -ne 1 ]
do
        echo "the symbol must be of one symbol [a-zA-Z0-9] "
	read symbol1
	echo "$symbol1" > symbol.tmp
	if [ $(( $(grep "[a-z0-9A-Z]" symbol.tmp| wc -m) - 1 )) -eq 1 ]
	then	
		break
	fi
done

echo "\nThe symbol for $name2 is "
read symbol2
echo "$symbol2" > symbol.tmp

# validation of the second symbol
while  [ $(( $(grep "[a-z0-9A-Z]" symbol.tmp| wc -m) -1 )) -ne 1 ]
do
        echo "the symbol must be of one symbol [a-zA-Z0-9] "
        read symbol2
        echo "$symbol2" > symbol.tmp
	if [ $(( $(grep "[a-z0-9A-Z]" symbol.tmp| wc -m) )) -eq 1 ]
	then
		break
	fi
done

rm symbol.tmp

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

# check for a winner
win_test(){
	win1=$( grep "$symbol1" check.tmp |wc -l)

	if [ $win1 -eq 3 ]
	then
		echo "$name1, you win" | tee -a $file
		rm board.tmp
		rm check.tmp
		exit
	fi
 
	win2=$(grep "$symbol2" check.tmp | wc -l)
	if [ $win2 -eq 3 ]
	then      
		echo "$name2, you win" | tee -a $file
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

# check if the move is already on the board
all_there(){
	while [ $(grep "$x1 $y1" $file| wc -l) -gt 0 ]
        do     
		echo "error, already there"
		read x1 y1
        done

}

# validate coordinates
validation(){
	all_there $x1 $y1
        until ([ $x1 -eq 1 ] || [ $x1 -eq 2 ] || [ $x1 -eq 3 ] )&& ( [ $y1 -eq 1 ] || [ $y1 -eq 2 ] || [ $y1 -eq 3 ])
	do
                echo "incorrect coordinates, please enter a new move [1-3] [1-3]"
                read x1 y1
		all_there $x1 $y1
        done
}

# moves
for moves in $(seq 1 9)
do
	# player one or player two
	if [ $moves -eq 1 ] || [ $moves -eq 3 ] || [ $moves -eq 5 ] || [ $moves -eq 7 ] || [ $moves -eq 9 ]
	then
		echo "$name1, please enter a move [1-3] [1-3] "
		echo "$name1's " >> $file
		read x1 y1
		validation $x1 $y1
	else
		echo "$name2, please enter a move [1-3] [1-3] "
		echo "$name2's " >> $file
		read x1 y1
		validation $x1 $y1
	
	fi
	
	echo "move: $x1 $y1" | tee -a $file
	
#deciding witch symbol must appear on the board
	if [ $moves -eq 1 ] || [ $moves -eq 3 ] || [ $moves -eq 5 ] || [ $moves -eq 7 ] || [ $moves -eq 9 ]
	then
		current_symbol=$symbol1
	else
		current_symbol=$symbol2
	fi

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
echo "Nobody wins" | tee -a $file
