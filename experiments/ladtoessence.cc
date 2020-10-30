/* vim: set sw=4 sts=4 et foldmethod=syntax : */

#include <fstream>
#include <iostream>
#include <string>

using std::cout;
using std::endl;
using std::ifstream;
using std::string;

auto convert(const bool notable, const string & filename, const string & nodes, const string & labels, const string & lfn,
        const string & fn) -> void
{
    ifstream infile{ filename };
    int nv;
    infile >> nv;
    cout << "letting " << nodes << " be " << nv << endl;
    cout << "letting " << labels << " be 1" << endl;

    if (! notable) {
        cout << "letting " << fn << " be function" << endl;

        bool first = true;
        for (int i = 0 ; i < nv ; ++i) {
            int ne;
            infile >> ne;
            for (int j = 0 ; j < ne ; ++j) {
                int t;
                infile >> t;

                if (first) {
                    cout << "( ";
                    first = false;
                }
                else
                    cout << ", ";
                cout << "(" << (i + 1) << "," << (t + 1) << ") --> 1" << endl;
            }
        }
        cout << ")" << endl;
    }

    cout << "letting " << lfn << " be function" << endl;
    bool first = true;
    for (int i = 0 ; i < nv ; ++i) {
        if (first) {
            cout << "( ";
            first = false;
        }
        else
            cout << ", ";
        cout << (i + 1) << " --> 1";
    }
    cout << ")" << endl;
}

auto main(int argc, char * argv[]) -> int
{
    if (3 != argc && 4 != argc)
        return EXIT_FAILURE;

    bool notable = (argc == 4 && string{ argv[1] } == "--notable");

    convert(notable, argv[1 + notable], "p", "l", "plab", "pat");
    convert(notable, argv[2 + notable], "t", "e", "tlab", "tgt");
    return EXIT_SUCCESS;
}

