/* vim: set sw=4 sts=4 et foldmethod=syntax : */

#include <vector>
#include <filesystem>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <map>
#include <cstdlib>

using std::cout;
using std::endl;
using std::vector;
using std::filesystem::path;
using std::string;
using std::stringstream;
using std::getline;
using std::map;
using std::stold;
using std::ifstream;

auto main(int argc, char * argv[]) -> int
{
    vector<path> dirs;
    for (int p = 1 ; p < argc ; ++p)
        dirs.emplace_back(argv[p]);

    {
        bool first = true;
        for (auto & d : dirs) {
            if (! first)
                cout << " ";
            cout << d.filename();
            first = false;
        }
        cout << endl;
    }

    ifstream instances{ "instances.txt" };
    string line;
    while (getline(instances, line)) {
        stringstream line_s{ line };
        string n, p, t, f;
        if (! (line_s >> n >> p >> t >> f))
            return EXIT_FAILURE;

        cout << n;
        for (auto & d : dirs) {
            path p = d / n / "run-experiment.out";
            ifstream result{ p };
            map<string, string> entries;
            string result_line;
            while (getline(result, result_line)) {
                auto eq = result_line.find('=');
                if (eq == string::npos)
                    return EXIT_FAILURE;
                entries.emplace(result_line.substr(0, eq), result_line.substr(eq + 1));
            }

            if (! (entries.count("started") && entries.count("finished") && entries.count("retcode")))
                return EXIT_FAILURE;

            if (entries["retcode"] == "0") {
                long double s = stold(entries["started"]), f = stold(entries["finished"]);
                cout << " " << (f - s);
            }
            else if (entries["retcode"] == "1") {
                cout << " NaN";
            }
            else
                return EXIT_FAILURE;
        }
        cout << endl;
    }

    return EXIT_SUCCESS;
}
