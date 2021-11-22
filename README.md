# Noisy
Pascal program (or programs, I explain more below) to mark (or remove marks) on 
source files so the compiler will give "shout outs" when used, i.e. the program
will be very "noisy".

What exactly does this mean, and why am I creating a program to do this? 
* In large projects with dozens to hundreds to thousands or hundreds of 
thousands of source files -- hey, maybe projects aren't that big now, just wait, 
they will be. Besides, as I said (or rather will say later), this project might 
be used on programs in languages other than Pascal ==  it can be difficult or even 
impossible to determine which file was invoked where, especially when conditional 
compilation is being used (such as a program being released for different operating 
systems or processors). So, what this program does -- or rather, will do, once 
finished -- is to scan a project directory for specific files, usually by the file 
extension, and mark them with a compiler directive to state the file's name as an 
informational warning whem the file is opened by the compiler for compiling. 
* This is in the form of adding some comments at the top of each source file of 
that programming language. In the case of the language Pascal, that is to put 
these lines at the top of each source file:<br />
<code>{.Noisy Processed (the current date and time, and possibly other information) }
{$IFDEF NOISY}{.Noisy}
{$INFO Compiling: Drive:\location\filename.ext} {.Noisy}
{$ENDIF}{.Noisy}</code></br>
so that when that program is being compiled, if the NOISY compile-time flag is set, the 
compiler will announce the file each time it is read by the compiler. 
* The indicator <b><code>{.Noisy</code></b><code> (any text except close brace) }</code> 
tells Noisy that this file has already been processed (so it doesn't do it again) or if 
Noisy is being run to remove these marks, any line containing these seven characters 
<b>{.Noisy</b> (case not significant) it will delete that line but leave the rest of the 
source code intact.
* The original intended project is the source to the Free Pascal Compiler (FPC). This 
medium-size (in terms of the number of lines of source code) compiler has about 250,000 
lines, and the run-time libraries have tens- or hundreds-of-thousands of additional 
lines. If someone (or potentially a group) is going to work on the program, possibly for
writing a port (or fixing or enhancing an existing one) when they're not familiar with
the code base), it's important to know what files are included in those files that are 
used in all versions of the compiler  (the baseline of the compiler), as opposed to that 
port of the compiler. It's intended as an understanding tool, either where you don't 
know what files are being used in what order, or to refresh your memory as to the 
particular order of inclusion. Can be useful if specific units are included for a 
particular build.<br />
It is possible this might have other uses, such as: 
* Inserting other prefix code in files, such as boilerplate, copyright notices or 
refernce to the license being used (GPL v. whatever, BSD, MIT, Mozilla, etc.) the 
file name, or revision/version number, date of new maintenance, etc. 
* Potentially inserting postfix code after the last line (this might have to be done 
carefully; if the compiler ignores everything after the last <b>END.</B> in a Pascal
source file (or some equivalent in other languages), such as a unit or main program, 
then it has to insert the material before that line.)
* Potentially used with other programming languages (and I've already hinted about 
this earlier) C++ probablu needs something like this to understand how those babies
arew constructed.
* More will be added later as I have more information on where the project is going.

Noisy will eventually be a suite of code processing tools, either to gather statistics 
(where just information is collected, or where changes to code are made. It might have 
other uses I haven't discovered yet, or that I'm not even aware of. We shall see.

Paul Robinson<br/>
22 November 2021 06:45 EST (-0500)
