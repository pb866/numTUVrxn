PROGRAM numTUVrxn


!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
! Variable declarations:                                               !
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!

  IMPLICIT NONE

  INTEGER        :: i,ierr,nrxn
  CHARACTER(80)  :: line,ifile
  CHARACTER(1)   :: reset

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!

! Retrieve file name from first programme argument,
! otherwise ask for it:
  CALL getarg(1,ifile)
  IF (ifile == ' ') THEN
    WRITE(*,"('Name of input file: ',A)",advance='no')
    READ(*,*) ifile
  ENDIF
  ifile = TRIM(ADJUSTL(ifile))

! retrieve choice of reaction switch from 2nd programme argument
  CALL getarg(2,reset)

! Open input file and temporary output file:
  OPEN(11,file=ifile)
  OPEN(12,FILE='ofile.txt')

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Read away header and spectral weighting functions:
  head: DO WHILE (line /= '===== Available photolysis reactions:')
    READ(11,'(A)') line
    WRITE(12,'(A)') trim(line)
  ENDDO head

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Initialise count of output (true) reactions:
  i = 0
  nrxn = 0

! Loop over photolysis reactions:
  phot: DO
! Increase counter for total number of reactions
    i = i + 1
! Read in photolysis reactions line by line
    READ(11,'(A)') line

! Exit condition of loop when reaching line starting with '===':
    IF(line(:3) == '===') THEN
! Write final line to temporary output file:
      WRITE(12,'(A)') trim(line)
! Reset rxn counter to total number of reactions, if all reactions are
! forced to true:
      IF(reset=='T') THEN
        nrxn = i-1
! Reset rxn counter to 0, if all reactions are forced to false:
       ELSEIF(reset=='F') THEN
        nrxn = 0
      ENDIF
!     Exit loop:
      EXIT
    ENDIF

! Overwrite reaction switched, if forced to true or false:
    IF(reset=="T" .or. reset=="t") THEN
      WRITE(line(1:1),'(A1)') "T"
     ELSEIF(reset=="F" .or. reset=="f") THEN
      WRITE(line(1:1),'(A1)') "F"
     ELSE
! Otherwise count number of true reactions:
      IF(line(:1)=='T') nrxn = nrxn + 1
    ENDIF
! Write each reaction line with new reaction numbers to temporary output
    WRITE(line(2:4),'(I3)') i
    WRITE(12,'(A)') trim(line)
  ENDDO phot

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Adjust parameter nmj

! Re-read temporary output file from the beginning
! and print output to another temporary output file with adjusted parameter nmj

! Rewind ofile.txt to top
  REWIND(12)
! Open 2nd temporary output file
  OPEN(13,FILE='ofile.dat')
! Loop over first output file
  ll: DO
!   Read again line by line
    READ(12,'(A)',IOSTAT=ierr) line
! Exit on end of file
    IF(ierr<0) THEN
      EXIT
     ELSEIF(ierr>0) THEN
      STOP "Read error in temporary output file 'ofile.txt'!"
    ENDIF
! Override number of output (true) reactions
    IF(INDEX(line,'nmj')>0) WRITE(line(61:66),'(I6)') nrxn
! Write (adjusted) lines to 2nd temporary file
    WRITE(13,'(A)') trim(line)
  ENDDO ll

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Close all files
  CLOSE(11)
  CLOSE(12,STATUS='DELETE')
  CLOSE(13)

! Use Unix to move temporary output over original TUV input file:
  CALL SYSTEM('mv ofile.dat '//trim(ifile))

END PROGRAM numTUVrxn
