%{
  #include<stdio.h>
  #include<stdlib.h>
  #include<bits/stdc++.h>
  #include<fstream>
  #include<string>
  using namespace std;
  
  int is_dfa_nfa; // indicates whether the specifications correspond to a DFA or NFA (1-DFA and 0-NFA)
  int number_of_states; // number of states in the finite state automata
  int number_of_final_states; // number of final states in the finite state automata
  int number_of_symbols; // size of the input alphabet
  bool is_e_nfa; // indicates the presence or absence of E-transitions
  map <char,int> alphabet_map; // maps the input alphabets onto their indices in the table
  vector <int> states; // vector of states
  vector <int> final_states; // vector of final states
  vector <vector <int> > DTrans; // DFA Transition Table
  vector <vector <string> > NTrans; // NFA Transition Table

  // Function declaration

  void read_DFA (); 
  void read_NFA ();
  bool is_final_DFA (int);
  bool is_final_NFA (vector <int>);
  int move_DFA (int, char);
  vector <int> move_NFA (vector <int>, char);
  vector <int> Eclosure (vector <int>);
  void DFA (string);
  void NFA (string);
  char* to_char(string);
  
  // Function definitions

  bool is_final_DFA (int state)
  {
    // Checks whether input state of DFA is final state or not
    
    for (int i = 0; i < number_of_final_states; i++)
    {
	    if (state == final_states[i])
	      return true;
    }
    return false;
  }

  bool is_final_NFA (vector <int> state)
  {
    // Checks whether atleast on the states in the set is a final state of the NFA or not
    
    for (int i = 0; i < state.size (); i++)
    {
	    if (is_final_DFA (state[i]))
	      return true;
    }
    return false;
  }

  vector <int> Eclosure (vector <int> T)
  {
    /* Function Eclosure computes the epsilon closure of the set given as input
       
       Algorithm: Eclosure recursively computes the epsilon neighbours of the states in T.
    */

    vector <int> Etrans;
    for (int i = 0; i < T.size (); i++)
    {
	    Etrans.push_back(T[i]); // any set is a subset of its epsilon closure
    }
    if(!is_e_nfa) // no epsilon transtions 
    {
      return Etrans; 
    }
    while (T.size () != 0)
    {
	     int state = T[T.size () - 1];
	     T.pop_back ();
	     vector <int> state_vector;
	     state_vector.push_back (state);
       vector <int> Eneighbours = move_NFA (state_vector, '$'); // returns the immediate epsilon neighbours
       while (Eneighbours.size () != 0)
	     {
	         int current = Eneighbours[Eneighbours.size () - 1];
	         Eneighbours.pop_back ();
	         vector < int >::iterator it;
	         it = find (T.begin (), T.end (), current);
	         if (it == T.end ()) // element is pushed if it is not present already
	         {
		           T.push_back (current);
		           Etrans.push_back (current);
	         }
	     }
    }
    return Etrans;
  }

  char* to_char (string str)
  {
     // A utility function to convert a string to char*

     char *cstr = new char[str.length() + 1];
     strcpy(cstr, str.c_str());
     return cstr;
  }

  int move_DFA (int state, char input_char)
  {
     // returns the state to which the DFA transitions from a given state on input_char

     return DTrans[state][alphabet_map[input_char]];
  }

  vector <int> move_NFA (vector <int> state, char input_char)
  {
     // returns the set of states to which the NFA transitions from a given set of states on a given input

     vector <int> transition_states;
     vector <int>::iterator it;
     for (int i = 0; i < state.size (); i++)
     {
         string entry = NTrans[state[i]][alphabet_map[input_char]];
 	       if(entry=="^") // no transition defined for this state
           continue;
         char *token;
         if (entry.length()==1) // transitions to a single state
         {
             transition_states.push_back(stoi(entry)); 
         }
         else // transition to a set of states
         {
 	          token=strtok (to_char(entry), ",");
            while (token != NULL)
	          {
	            it = find (transition_states.begin (), transition_states.end (), stoi (token));
	            if (it == transition_states.end ())
	            {
		            transition_states.push_back (stoi (token));
		            token = strtok (NULL, ",");
	            }
	          }
         }
     }
     return transition_states;
  }

  void read_DFA ()
  {
    // read_DFA function will read the specifications of the DFA into the global variables
    
    ifstream file;
    file.open ("specification.txt");
    vector <string> line; // to store each line in the file
    while (!file.eof ())
    {
	     string s;
	     getline (file, s);
	     line.push_back (s);
    }
    file.close ();
 
    // processing the states
    
    char* token = strtok (to_char(line[0]), " ");
    while (token != NULL)
    {
	     states.push_back (stoi (token));
	     token = strtok (NULL, " ");
    }
    
    // processing the final states
    
    token = strtok (to_char(line[1]), " ");
    while (token != NULL)
    {
	     final_states.push_back (stoi (token));
	     token = strtok (NULL, " ");
    }
    
    // processing the input symbols
    
    int counter = 0;
    token = strtok (to_char(line[2]), " ");
    while (token != NULL)
    {
       alphabet_map.insert(pair <char,int> (token[0],counter));
	     counter++;
	     token = strtok (NULL, " ");
    }
    
    //processing the transition table

    for (int i = 3; i < line.size (); i++)
    {
	     token = strtok (to_char(line[i]), " ");
	     vector<int> col;	
	     while (token != NULL)
	     {
	         col.push_back(stoi(token));
	         token = strtok (NULL, " ");
	     }
       DTrans.push_back(col);
    }
  }

  void read_NFA ()
  {
     // read_NFA function will read the specifications of the NFA into the global variables
 
     ifstream file;
     file.open ("specification.txt");
     vector <string> line;
     while (!file.eof ())
     {
	       string s;
         getline (file, s);
         line.push_back (s);
     }
     file.close ();
    
    // processing the states of the NFA

    char* token = strtok (to_char(line[0]), " ");
    while (token != NULL)
    {
	     states.push_back (stoi (string (token)));
	     token = strtok (NULL, " ");
    }
    
    // processing the final states of the NFA

    token = strtok (to_char(line[1]), " ");
    while (token != NULL)
    {
	     final_states.push_back (stoi (string (token)));
	     token = strtok (NULL, " ");
    }
    
    // processing the input symbols

    token = strtok (to_char(line[2]), " ");
    int counter = 0;
    while (token != NULL)
    {
	     alphabet_map.insert(pair <char,int> (token[0],counter));
       token = strtok (NULL, " ");
	     counter++;
    }
    alphabet_map.insert(pair <char,int> ('$',counter)); // for epsilon transitions
    
    // processing the transition table

    for (int i = 3; i < line.size(); i++)
    {
       token = strtok (to_char(line[i]), " ");
       counter = 0;
       vector<string> col;
 	     while (token != NULL)
	     {
           col.push_back(string(token));
	         token = strtok (NULL, " ");
	         counter++;
	     }
       NTrans.push_back(col);
    }
    
    if(counter==number_of_symbols)
    {
       is_e_nfa=false;
    }
    else 
    {
       is_e_nfa=true;
    }
  }


  void DFA (string str)
  {
    // to parse over an input string and check whether it is accepted or rejected 
    
    int state = 0;
    int i=0;
    for (; i < str.length (); i++)
    {
       if (alphabet_map.find(str.at(i))==alphabet_map.end())
       {
           cout<<"ERROR"; 
           break;
       }
	     state = move_DFA (state, str.at (i));
    }
    if (is_final_DFA (state) && i==str.length())
       cout << "MATCHED";
    if (!is_final_DFA (state) && i==str.length())
       cout << "ERROR";
  }

  void NFA (string str)
  {
    // to parse over an input string and check whether it is accepted or rejected

    vector <int> start;
    start.push_back (0);
    vector <int> state = Eclosure (start);
    int i=0; 
    for (; i < str.length (); i++)
    {
       if (alphabet_map.find(str.at(i))==alphabet_map.end())
       {
         cout<<"ERROR";
         break;
       }
	     state = Eclosure (move_NFA (state, str.at (i)));
    }
    if (is_final_NFA (state) && i==str.length())
       cout << "MATCHED";
    if (!is_final_NFA (state) && i==str.length())
       cout << "ERROR";
  }

%}



%%

.* {  if (is_dfa_nfa == 1)
      {
        DFA (yytext);
      }
      else
      {
        NFA (yytext);
      }
   } 

%%



int main (int argc, char *argv[])
{
  extern FILE *yyin;
  yyin = fopen("input.txt","r");
  is_dfa_nfa = stoi(argv[1]);
  number_of_states = stoi (argv[2]);
  number_of_final_states = stoi (argv[3]);
  number_of_symbols = stoi (argv[4]);
  if (is_dfa_nfa == 1)
  {
     read_DFA ();
  }
  else
  {
     read_NFA ();
  }
  yylex ();
  return 0;
}
