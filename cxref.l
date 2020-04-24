    /* Christelle Nieves */
    /* COP 4020 */
    /* Program 2: Cross reference scanner */
    /* Description: A C language scanner implemented with flex and c++ */
%{

#include <cstdio>
#include <iostream>
#include <cstdlib>
#include <cctype>
#include <vector>
#include <string>
#include <algorithm>

using namespace std;

#define ID 256
#define CHAR 257
#define NUM 258
#define STRING 259
#define INVALID 260

int key = 0;
int character = 0;
int lineNum = 1;
int pre = 0;

    /* Structure to hold name and line numbers for each identifier. */
typedef struct Ident
{
    string name;
    vector<int> lineNumbers;
} Ident;

    /* Vector of type Ident to hold all discovered identifiers and their respective line numbers. */
vector<Ident> allTokens;

    /* Function prototypes */
void lex_error(const std::string msg="");
void print_tokens(vector<Ident> allToks);
bool sortAlphabetically(const Ident &lhs, const Ident &rhs);

%}

quote       \'
back        \\
ditto       \"
octal       [0-7]
octch       ({back}{octal}|{back}{octal}{octal}|{back}{octal}{octal}{octal})
digit       [0-9]
alpha       [a-zA-Z_]
schar       [^\'\"\n\\]
char        ({back}?({schar}|{ditto})|{back}{back}|{back}{quote}|{octch})
line        \n

%%
    /* Regex to filter out preprocessor directives */
^"#".*      { if (pre) pre = !pre; }

    /* Regex to find a char token */
{quote}     { if (character) character = !character; }
{quote}([\x00-\x7F]|{char}){quote}        { return CHAR; }

    /* Skip over all reserved words */
"auto"      { if (key) key = !key; }
"break"     { if (key) key = !key; }
"case"      { if (key) key = !key; }
"char"      { if (key) key = !key; }
"const"     { if (key) key = !key; }
"continue"  { if (key) key = !key; }
"default"   { if (key) key = !key; }
"do"        { if (key) key = !key; }
"double"    { if (key) key = !key; }
"else"      { if (key) key = !key; }
"extern"    { if (key) key = !key; }
"float"     { if (key) key = !key; }
"for"       { if (key) key = !key; }
"goto"      { if (key) key = !key; }
"if"        { if (key) key = !key; }
"int"       { if (key) key = !key; }
"long"      { if (key) key = !key; }
"register"  { if (key) key = !key; }
"return"    { if (key) key = !key; }
"short"     { if (key) key = !key; }
"signed"    { if (key) key = !key; }
"sizeof"    { if (key) key = !key; }
"static"    { if (key) key = !key; }
"struct"    { if (key) key = !key; }
"switch"    { if (key) key = !key; }
"typedef"   { if (key) key = !key; }
"union"     { if (key) key = !key; }
"unsigned"  { if (key) key = !key; }
"void"      { if (key) key = !key; }
"while"     { if (key) key = !key; }
"enum"      { if (key) key = !key; }
"volatile"  { if (key) key = !key; }

    /* Regex to find an identifier token and return it if its not a char, keyword or preprocesser */
{alpha}({alpha}|{digit})*   { if (!character && !key && !pre) return ID; }

    /* Regex to find a number token */
{digit}+                    { if (!character) return NUM; }

    /* Regex for end of file */
<<EOF>>                     { return EOF; }

    /* Skip all other characters */
.                           { ; }

    /* Increment lineNum each time a newline is encountered. */
{line}                      { ++lineNum; }

    /* Regex to find all comments. Includes both // style and /* style comments. */
L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|(\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8}))*\" { return STRING;}

    /* Regex to find a string token. */
("/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*"*"+"/")|("//".*) { ; }

%%

int main(void) 
{
    int token;
    while ((token = yylex()) != EOF)
    {
        switch (token)
        {
            case ID:
            {
                    /* Store the name of the identifier and convert it to a string. */
                char *newIdentName = yytext;
                std::string str(newIdentName);

                    /* If this is not the first identifier we've encountered. */
                if (allTokens.size() != 0)
                {
                        /* A flag to indicate if we already have this identifier in our token list. */
                    bool found = false;

                        /* Loop through all the tokens we've found and check if we've encountered this identifer before */
                    for (int i = 0; i < allTokens.size(); i++)
                    {
                            /* If we find that we already have this identifier in our list.. */
                        if (allTokens[i].name == newIdentName)
                        {
                                /* Set the found flag to true since we found a match. */
                            found = true;

                                /* Only store the line number if we don't already have it stored in the lineNumbers vector. */
                            if (allTokens[i].lineNumbers.back() != lineNum)
                            {
                                allTokens[i].lineNumbers.push_back(lineNum);
                            }
                            break;
                        }
                    }
                    if (found) break;

                        /* If we reach this point it means the ident doesn't exist yet in our list, so create it. */
                    Ident newID;
                    newID.name = newIdentName;
                    newID.lineNumbers.push_back(lineNum);
                    allTokens.push_back(newID);
                    break;
                }
                else
                {
                        /* If our token list has zero elements, go straight to creating a new ident object. */
                    Ident newID;
                    newID.name = newIdentName;
                    newID.lineNumbers.push_back(lineNum);
                    allTokens.push_back(newID);
                    break;
                }
            }
                /* For all other cases just break from the switch statement, since we don't need them for the output. */
            case NUM:
                break;
            case CHAR:
                break;
            case STRING:
                break;
            case EOF:
                break;
            case INVALID:
                lex_error("Unknown token.");
                break;
            default:
                lex_error("Unknown token.");
                exit(1);
        }
    }
    return 0;
}

int yywrap()
{
    print_tokens(allTokens);    
    return 1;
}

void lex_error(const std::string message)
{
    cout << message << endl;
}

    /* This function sorts ident names alphabetically */
bool sortAlphabetically(const Ident &lhs, const Ident &rhs)
{
    return lhs.name < rhs.name;
}

    /* This function calls the sort function and then prints the sorted tokens, along with their line numbers. */
void print_tokens(vector<Ident> allTokens)
{
        /* Sort the ident names alphabetically. */
    sort(allTokens.begin(), allTokens.end(), sortAlphabetically);

        /* Loop through our token list and print all the contents */
    for (int i = 0; i < allTokens.size(); i++)
    {
        cout << allTokens.at(i).name << ": ";

            for (int j = 0; j < allTokens.at(i).lineNumbers.size(); j++)
                {
                        /* If we are at the last element, don't print the comma. */
                    if (j + 1 == allTokens.at(i).lineNumbers.size())
                    {
                        cout << allTokens.at(i).lineNumbers[j];
                        break;
                    }
                    cout << allTokens.at(i).lineNumbers[j] << ", ";
                }
        cout << endl;
    }
}