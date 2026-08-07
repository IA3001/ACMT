g++ %1.cpp -std=c++17 -o %1.exe -Wall -Wl,--stack=268435456
%1.exe
del %1.exe

