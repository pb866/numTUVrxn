#!/usr/local/bin/julia


"""
# Module numTUVrxn

Correct reaction numbers after alterations of the TUV input file.
Preserve flags for output or set/unset all.
"""
module numTUVrxn

# Add path of self-made modules
push!(LOAD_PATH,"$(pwd())/jl.mod")

# Append ARGS by empty strings
# to avoid error messages in case of missing input
for i = 1:2  push!(ARGS," ")  end


################################################################################
### Functions:                                                                 #
################################################################################

"""
    rdfile(fname)

Check existance of TUV input file or ask for correct input file and
return correct file name and an array with all lines from the TUV file.
"""
function rdfile(fname)

  # Ask for input file, if file given in first script argument doesn't exist
  while isfile(fname) == false
    print("\033[95m'$fname' does not exist.\033[0m Define TUV file: ")
    fname = readline()
  end

  # Read content from input file and return file name and content
  open(fname,"r+") do f
    lines = readlines(f)
    return fname, lines
  end

end #function get_fname


"""
    get_rxn(lines)

From lines in TUV input file, derive top section (top), flags for reactions (flags)
and reaction strings (rxns) from reaction section, and bottom line (bottom)
and return separately.
"""
function get_rxn(lines)

  # Initialise
  rfl = false # flag for reaction section
  flags = String[]
  rxns  = String[]
  top   = String[]
  bottom = String

  # Loop over lines
  for i in eachindex(lines)
    # On keyword for reactions section, save last line to top and set flag for rxn section
    if lines[i] == "===== Available photolysis reactions:"
      push!(top,lines[i]); rfl = true
    # Save last line of file to bottom
    elseif rfl==true && lines[i][1:3]=="==="  bottom = lines[i]
    # In reaction section, only save flags for reactions and reaction strings
    elseif rfl==true  push!(flags,lines[i][1:1]); push!(rxns,lines[i][6:end])
    # Save header and spectral weighting functions to top
    else   push!(top,lines[i])
    end
  end

  # return saved sections separately
  return top, bottom, flags, rxns
end #function find_rxn


"""
    renumber(fl,flags,rxns,top,bottom)

Overwrite reaction numbers in TUV input file and optionally flags for reactions
and adjust parameter `nmj` for number of flagged reactions.

If fl is set to T/t or F/f in the second script argument all reaction flags are
set to T or F, respectively. The reaction section is derived from the reaction flags
flags (or the overwritten flags), new consecutive reaction numbers and the reaction
labels (rxns). All sections top, the new reaction section and bottom are concatenated
and returned as array (lines).
"""
function renumber(fl,flags,rxns,top,bottom)

  # Set all flags to T, if fl = T,t,True,... and set number of flags to # of rxns
  if lowercase(fl[1])=='t'  flags .= "T"; trxn = length(flags)
  # Set all flags to F, if fl = F,f,False,... and set number of flags to 0
  elseif lowercase(fl[1])=='f'  flags .= "F"; trxn = 0
  # Otherwise count true flags
  else  trxn = count(f->f=="T",flags)
  end

  # Rewrite reaction section with consecutive reaction numbers starting at 1
  rlines = String[]
  for i = eachindex(flags)
    push!(rlines,@sprintf("%s%3d %s", flags[i],i,rxns[i]))
  end

  # Search for parameter nmj and replace with new number of true flags
  idx = 0
  # Loop over top section
  for i = eachindex(top)
    # Find nmj
    try idx = search(top[i],"nmj = ")[end] end
    if idx > 0
      srch = search(top[i],r"[0-9]+",idx)
      repl = string(trxn)
      # Adjust length of new nmj to length of old nmj, if shorter
      try  repl = " "^(length(srch)-length(repl))*repl  end
      # replace
      top[i] = top[i][1:srch[end]-length(repl)]*repl*top[i][srch[end]+1:end]
      break
    end
  end

  # return array with complete file content of concatenated sections
  lines = vcat(top,rlines,bottom)

  return lines
end #function renumber


"""
    wrtfile(file,lines)

Overwrite TUV input file (file) with adjusted lines (lines) bearing new reaction
numbers and optionally reaction flags.
"""
function wrtfile(file,lines)

  # remove old TUV file and write new content to file with same file name
  rm(file); open(file,"w") do f
    [println(f, lines[i]) for i = eachindex(lines)]
  end
end #function wrtfile


################################################################################
### End of Functions; Main script:                                             #
################################################################################

# Get file name from script argument or user input and read content (lines)
file,lines = rdfile(ARGS[1])
# Split content in sections and get flags
# and reaction strings from reaction section
top, bottom, flags, rxns = get_rxn(lines)
# Overwrite reaction numbers and optionally flags
# and return complete and revised file content
lines = renumber(ARGS[2],flags,rxns,top,bottom)
# Overwrite old TUV input file
wrtfile(file,lines)

end #module numTUVrxn
