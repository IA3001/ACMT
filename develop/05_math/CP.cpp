#include<bits/stdc++.h>
#include<complex>
using namespace std;

int main(){
    complex<double> c;
    c.real(123);
    c.imag(456);
    cout<<c<<"\n";
    cout<<c.real()<<"\n";
    // STL 的 complex 现在无法直接引用 r 和 i 
}