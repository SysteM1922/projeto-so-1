#!/bin/bash

# Trabalho realizado por:
# Guilherme Antunes		103600

declare vBi=()
declare vBf=()
declare vBr=()
declare tots=()
declare	vlu=0
declare	vld=0
declare vlt=0
declare sT=1
declare pR=()
declare ctrl=0
declare d=1
declare sort=0
declare rev=0
declare loop=0
declare filter=()
declare p=-1
declare f=0

valArg(){
	if [[ $1 =~ -.* ]]; then
	
        echo "ERRO: Formato de argumento inválido. Argumentos possíveis (-b -k -m -t -r -T -R -l -v -c -p)"
		ctrl=1
        exit
    fi
}

inputs(){
	if ! [[ ${@: -1} =~ ^[0-9]+$ ]]; then
		echo "ERRO: O último valor deve ser o argumento de sleep"
		ctrl=1
		exit
	fi
	while getopts ":p:c:bkmtrTRlv:" opt; do
		case $opt in
			b)
				valArg "$opt"
				if [[ $vlu -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de conversão. Usar apenas um dos argumentos (-b -k -m)"
					ctrl=1
					exit
				fi
				vlu=$((vlu+1))
			;;
			k)
				valArg "$opt"
				if [[ $vlu -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de conversão. Usar apenas um dos argumentos (-b -k -m)"
					ctrl=1
					exit
				fi
				vlu=$((vlu+1))
				d=1024
			;;
			m)
				valArg "$opt"
				if [[ $vlu -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de conversão. Usar apenas um dos argumentos (-b -k -m)"
					ctrl=1
					exit
				fi
				vlu=$((vlu+1))
				d=1048576
			;;
			t)
				valArg "$opt"
				if [[ $vld -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de ordenamento. Usar apenas um dos argumentos (-t -r -T -R)"
					ctrl=1
					exit
				fi
				vld=$((vld+1))
				sort=1
			;;
			r)
				valArg "$opt"
				if [[ $vld -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de ordenamento. Usar apenas um dos argumentos (-t -r -T -R)"
					ctrl=1
					exit
				fi
				vld=$((vld+1))
				sort=2
			;;
			T)
				valArg "$opt"
				if [[ $vld -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de ordenamento. Usar apenas um dos argumentos (-t -r -T -R)"
					ctrl=1
					exit
				fi
				((vld++))
				sort=3
			;;
			R)
				valArg "$opt"
				if [[ $vld -gt 0 ]]; then
					echo "ERRO: Só deve ser utilizada uma opção de ordenamento. Usar apenas um dos argumentos (-t -r -T -R)"
					ctrl=1
					exit
				fi
				((vld++))
				sort=4
			;;
			l)
				valArg "$opt"
				loop=1
			;;
			v)
				valArg "$opt"
				rev=1
			;;
			c)
				valArg "$opt"
				filter=($OPTARG)
				f=1
			;;
			p)
				valArg "$opt"
				if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
					echo "O argumento de -$opt deve ser um número inteiro"
					ctrl=1
					exit
				fi
				p=$OPTARG
			;;
			:)
				echo "ERRO: A opção -$opt precisa de um argumento"
				ctrl=1
                exit
			;;
			*)
				echo "ERRO: Opção -$opt não implementada"
				ctrl=1
                exit
			;;
			\?)
				echo "ERRO: Opção -$opt inválida"
				ctrl=1
				exit
			;;

		esac
	done
}

calcBytes(){
	pR=($(ifconfig | grep -oP "\w+(?=: )"))
	vBi=($(ifconfig | grep -oP "(?<=bytes )\w+"))
	sleep $sT
	vBf=($(ifconfig | grep -oP "(?<=bytes )\w+"))
	
	for i in ${!vBi[@]}; do
		vBr[$i]="$((${vBf[i]}-${vBi[i]}))"
	done
	if [[ $loop -eq 2 ]]; then
		for i in ${!vBr[@]}; do
			tots[$i]="$((${tots[i]}+${vBr[i]}))"
		done
	elif [[ $loop -eq 1 ]]; then
		for i in ${!vBr[@]}; do
			tots[$i]=0
		done
		loop=2
	fi
	if [[ $p -gt ${#pR[@]} ]]; then
		p=${#pR[@]}
	fi
	if [[ $p -ge 0 ]]; then
		pR=("${pR[@]:0:$p}")
		vBr=("${vBr[@]:0:$p*2}")
	fi
}

printInfo(){
	if [[ $loop -eq 2 ]]; then
		for i in ${!pR[@]}; do
			if [[ $f -eq 1 ]]; then
				for e in ${!filter[@]}; do
					if [[ ${pR[i]} =~ .*${filter[e]}.* ]]; then 
						printf "%s\t%10.0f\t%10.0f\t%10.1f\t%10.1f\t%10.0f\t%10.0f\n" "${pR[i]}" $(echo "scale=2; ${vBr[i*2+1]}/$d" | bc) $(echo "scale=2; ${vBr[i*2]}/$d" | bc ) $(echo "scale=2; ${vBr[i*2+1]}/($d*$sT)" | bc) $(echo "scale=2; ${vBr[i*2]}/($d*$sT)" | bc) $(echo "scale=2; ${tots[i*2+1]}/$d" | bc) $(echo "scale=2; ${tots[i*2]}/$d" | bc)
					fi
				done
			else
				printf "%s\t%10.0f\t%10.0f\t%10.1f\t%10.1f\t%10.0f\t%10.0f\n" "${pR[i]}" $(echo "scale=2; ${vBr[i*2+1]}/$d" | bc) $(echo "scale=2; ${vBr[i*2]}/$d" | bc ) $(echo "scale=2; ${vBr[i*2+1]}/($d*$sT)" | bc) $(echo "scale=2; ${vBr[i*2]}/($d*$sT)" | bc) $(echo "scale=2; ${tots[i*2+1]}/$d" | bc) $(echo "scale=2; ${tots[i*2]}/$d" | bc)
			fi
		done
		printf "\n"
	else
		for i in ${!pR[@]}; do
			if [[ $f -eq 1 ]]; then
				for e in ${!filter[@]}; do
					if [[ ${pR[i]} =~ .*${filter[e]}.* ]]; then
						printf "%s\t%10.0f\t%10.0f\t%10.1f\t%10.1f\n" "${pR[i]}" $(echo "scale=2; ${vBr[i*2+1]}/$d" | bc) $(echo "scale=2; ${vBr[i*2]}/$d" | bc ) $(echo "scale=2; ${vBr[i*2+1]}/($d*$sT)" | bc) $(echo "scale=2; ${vBr[i*2]}/($d*$sT)" | bc)
					fi
				done
			else
				printf "%s\t%10.0f\t%10.0f\t%10.1f\t%10.1f\n" "${pR[i]}" $(echo "scale=2; ${vBr[i*2+1]}/$d" | bc) $(echo "scale=2; ${vBr[i*2]}/$d" | bc ) $(echo "scale=2; ${vBr[i*2+1]}/($d*$sT)" | bc) $(echo "scale=2; ${vBr[i*2]}/($d*$sT)" | bc)
			fi
		done
	fi
}

print(){
	if [[ $rev -eq 0 ]]; then
		case $sort in
			0) printInfo | sort -k1 ;;
			1) printInfo | sort -k2 -n ;;
			2) printInfo | sort -k3 -n ;;
			3) printInfo | sort -k4 -n ;;
			4) printInfo | sort -k5 -n ;;
		esac
	else
		case $sort in
			0) printInfo | sort -k1 -r ;;
			1) printInfo | sort -k2 -n -r ;;
			2) printInfo | sort -k3 -n -r ;;
			3) printInfo | sort -k4 -n -r ;;
			4) printInfo | sort -k5 -n -r ;;
		esac
	fi
}

execInput(){
	
	if [[ $loop -eq 2 ]]; then
		
		while true; do
			calcBytes
			if [[ $vlt -lt 1 ]]; then
				printf "%s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT"
				((vlt++))
			fi
			print
		done
	else
		calcBytes
		printf "%s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
		print
	fi

}

main(){
	inputs "$@"
	if (( $ctrl == 1 )); then
		exit
	fi
	sT="${@: -1}"
	calcBytes
	execInput
}

main "$@"