PROGRAM numTUVrxn


!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!
! Variable declarations:                                               !
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!

  IMPLICIT NONE

  INTEGER        :: i,nrxn
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
! Assure input file is in the folder level above
  IF(INDEX(ifile,'/')<=0) THEN
    ifile(4:) = ifile(:77)
    ifile(:3) = '../'
  ENDIF

! retrieve choice of reaction switch from 2nd programme argument
  CALL getarg(2,reset)

! Open input file and temporary output file:
  OPEN(11,file=ifile)
  OPEN(12,FILE='ofile.txt')

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Read away header and spectral weighting functions:
  head: DO i = 1, 48
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

! Re-open temporary output file and find line with parameter nmj
  OPEN(13,FILE='ofile.dat')
  REWIND(12)
  DO i = 1, 16
    READ(12,'(A)') line
    WRITE(13,'(A)') trim(line)
  ENDDO
  READ(12,'(A)') line
! Overwrite parameter nmj according to editted photolysis reactions/switches
  WRITE(line(61:66),'(I6)') nrxn
  WRITE(13,'(A)') trim(line)
! Re-write remaining lines unchanged
  DO i = 18, 48
    READ(12,'(A)') line
    WRITE(13,'(A)') trim(line)
  ENDDO
  DO
    READ(12,'(A)') line
    WRITE(13,'(A)') trim(line)
    IF(line(:3) == '===') THEN
      EXIT
    ENDIF
  ENDDO

!––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––!

! Close all files
  CLOSE(11)
  CLOSE(12,STATUS='DELETE')
  CLOSE(13)

! Use Unix to move temporary output over original TUV input file:
  CALL SYSTEM('mv ofile.dat '//trim(ifile))

END PROGRAM numTUVrxn
