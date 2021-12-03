# Noisy
Pascal program (or programs, I explain more below) to mark (or remove marks) on 
source files so the compiler will give "shout outs" when used, i.e. the program
will be very "noisy".

What exactly does this mean, and why am I creating a program to do this? 
* In large projects with dozens to hundreds to thousands or hundreds of 
thousands of source files (hey, maybe projects aren't that big now, just wait, 
they will be). Besides, as I said (or rather will say later), this project might 
be used on programs in languages other than Pascal.
* It can be difficult or even impossible to determine which file was invoked 
where, especially when conditional compilation is being used (such as a program 
being released for different operating systems and / or processors). So, what 
this program does -- or rather, will do, once finished -- is to scan a project 
directory for specific files, usually by the file extension, and mark them with 
a compiler directive to state the file's name as an informational warning whem 
the file is opened by the compiler for compiling. 
* This is in the form of adding some comments at the top of each source file of 
that programming language. In the case of the language Pascal, that is to put 
these lines at the top of each source file:  
\{.Noisy Processed (the current date and time, and possibly other information)  
\{$IFDEF NOISY}\{.Noisy}  
\{$INFO Compiling: Drive:\\location\\filename.ext} \{.Noisy}  
\{$ENDIF}\{.Noisy}  
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
lines. 
* This tool is not exclusively targeted at the Free Pasca Compiler, but at any medium or
large application (or system) using many files, or which might have different editions 
(like regular, premium and enterprise) or where there are different ports for other 
architectures or operating systems. If someone (or potentially a group) is going to work 
on an application, possibly for writing a port (or fixing or enhancing an existing one) 
when they're not familiar with the code base), it's important to know what files are 
included in those files that are used in all versions of the application (the baseline), 
as opposed to a oarticular edition or port. It's intended as an understanding tool, either 
where you don't know what files are being used in what order, or to refresh your memory as 
to the particular order of inclusion. Can be useful if specific units are included for a 
particular build.

It is possible this might have other uses, such as: 
* Inserting other prefix code in files, such as boilerplate, copyright notices or 
refernce to the license being used (GPL v. whatever, BSD, MIT, Mozilla, etc.) the 
file name, or revision/version number, date of new maintenance, etc. 
* Potentially inserting postfix code after the last line (this might have to be done 
carefully; if the compiler ignores everything after the last <b>END.</B> in a Pascal
source file (or some equivalent in other languages), such as a unit or main program, 
then it has to insert the material before that line.)
* Potentially used with other programming languages (and I've already hinted about 
this earlier.) C++ probablu needs something like this to understand how those babies
are constructed.
* More will be added later as I have more information on where the project is going.

Noisy will eventually be a suite of code processing tools, either to gather statistics 
(where just information is collected}, or where changes to code are made. It might have 
other uses I haven't discovered yet, or that I'm not even aware of. We shall see.

### Paul Robinson<br/>
### 28 November 2021 14:25 EST (-0500)

----
## Additional points:
* This is a work in progress. I will be addong things here as I build the application.
* There will be fits and starts, where it oesn't seem like anything is getting done.
* Sometimes I will commit code foer things that are not related. The reason for this is I need three things:
* A routine to find every file in a directory 
* Potenitally that we ca pick which files to look at (filtr by extensio).
* Read in file up to a maximum size, if larger than that, grab the file in chunks or memory map the file, if Windows (or other operating systems) ccan do that. 
* I'm goinmg to try that as soon as I figure nout how to use memory mapping.of files.
* If not available (or i ca;t figure it out) use the old method of reading up to the size of the buffer, process the part tht'sin the buffer, then fill it again, until there is no more file left to take.
* I found out a coupole of things
* Originally I used a trick thought bu by Vaily Tereshkov, the creator of XDPascal for Windows, in which you open the file, then read it all into a block of memory big enough to hold the entire file, then you trest the file as ohne big block of memry, accessed by a pointer to a character, then when you want the next character, you add one to the pointer, until you reach the end of the block.
* Well, that's fine when you only have small to medium size programs - like the Stanford Pascal Compileer, whose single main program is about 1 megabyte. 
* Well, this cases a problem that I never expected to see. One, I repat one file, that is the part of the Free Pascal Compiler, is mopre than _18 megabytes_ in size! 
* Ain't no way am I going to :gulpread" a file that big.
* Originally, when i was going to read a file, I'd open the file, see how big it is, then ask for that much memory.
* I will use a better method. First, I'll grab as large a block as I reasonably can, to see how much I csn hsve. If it'sat least 2 megaytes, I'll return the excess to be used for any tables I need.
* If not available, see how big a reasonable buffer is, and use tha if the file fits, and use it to read a chuink of the file at once.
* Now that I hase a "plan of action" I can start with that. I'm busy with a side project tht will help we with the cross-refernce  program.

More later as things change.   
### Paul Robinson   
### 30 November 2021, 20:27, EST (-0500)
----
