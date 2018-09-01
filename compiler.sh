#!/bin/bash

echo "Inicializando Compiler MGOL"
echo "                                                        "
echo "                                                        "
echo " ------------------------------------------------------ "
ruby src/main.rb
echo " ------------------------------------------------------ "
echo "                                                        "
echo "                                                        "
echo " ------------------------------------------------------ "
echo "Compilação completa :)"


echo "Objeto programa.c criado na pasta Data"
echo "Compiling programa.c"

gcc -c data/programa.c
gcc programa.o -o programa
rm programa.o

echo "                                                        "
echo "                                                        "

echo "Executando programa ..."

echo "                                                        "
echo " ------------------------------------------------------ "

# ./programa
