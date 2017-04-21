Programme numTUVrxn
===================

Purpose
-------

This is a simple FORTRAN routine to relabel TUV photolysis reactions after
ammendments. The programme relies on the fixed format of the TUV input file
and is designed for TUV 5.2\. Consecutive 3-digit reaction numbers are
assigned starting at 1.

Compiling the programme
-----------------------

Compile with `<compiler> numTUVrxn -o numTUVrxn`. The programme has been
tested for the `gfortran` compiler.

Preparing model runs
--------------------

Edit your TUV input file by editing, adding or deleting reactions. If you
want the TUV output only for a fraction of the reactions, switch those
reactions to `T` (first character of each reaction line) and the rest to
`F`. If you want all reactions to be true or false, the programme has
switches for this. This is useful, if the majority of your reactions will
be true or false. You can then edit the output to toggle the switch for a
small fraction of photolysis reactions.

When adding new reactions, keep to the fixed line format of the input file:

- 1\. character: Switch for reactions `T` or `F`
- 2\. - 4\. character: Reaction number
- 6\. - 55\. character: Photolysis reaction

You can use any placeholder for the reaction number (e.g., spaces or 'x')
as it is overwritten by the programme. The remaining parts of the line
need to be specified explicitly. If you force all reactions to be true or
false, the first charcater of each line will be overwritten as well. There
is no need to adjust parameter `nmj` for the number of output (i.e. true)
reactions as it is automatically calculated by the programme.

You also need to stay to the overall file format, i.e.:

- ll. 1 - 19: Header
- ll. 20 - 47: Spectral weighting functions
- l. 48: Label for beginning of photolysis reactions
- '===...' for end of photolysis reactions

Running the programme
---------------------

Place the programme in the TUV `INPUTS` folder (or alternatively the TUV
input file in this programme folder).

Run programme with:

```
./numTUVrxn <TUV input file> <switch for reactions>
```

The first programme argument specifies the name of the input file. In the
input file all reaction numbers will be written on the 2\. to 4\. character
starting at l. 48 and up to the end line indicated by `===...`. All previous
reaction numbers will be overwritten with consecutive numbers starting at 1.

The second programme argument is a switch to toggle all reactions to true
(using `T` or `t` as argument) or false (with `F` or `f`). To leave the
switches as specified in the TUV input file, leave the argument blank.

The programme will modify each reaction line and print the output to a
temporary output file named `ofile.txt / ofile.dat`. At the end the
tempoary output file is renamed with the name of the TUV input file.

So be careful:
__All actions of the programme are destructive and will overwrite the
original TUV input file!__

Content modified is:

- the reaction number of photolysis reactions on character 2 - 4
- if forced to `T` or `F`: the switch for photolysis reactions on char. 1
- parameter `nmj` in the header with the total number of output (true)
  reactions


Open tasks
----------

The current programme version heavily relies on the fixed TUV format. To
be more flexible, the initial read loop of the header could be transformed
into a do while loop reading until the statement  
`===== Available photolysis reactions:`  
rather then reading a fixed number of 48 lines to be more flexible to
changes in additional lines in the header or additional spectral
weighting functions.
