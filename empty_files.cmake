MACRO(MD5SUM expected filename)
  EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E md5sum ${filename}
    OUTPUT_VARIABLE md5)
  IF (NOT md5 MATCHES ${expected})
    MESSAGE(FATAL_ERROR "unexpected md5sum: " ${expected} " != " ${md5})
  ENDIF()
ENDMACRO()
MACRO(EXECUTE_PROGRAM)
  EXECUTE_PROCESS(COMMAND ${ARGV} RESULT_VARIABLE res)
  IF (res)
    MESSAGE(FATAL_ERROR "${ARGV} failed: " ${res})
  ENDIF()
ENDMACRO()
MACRO(EXECUTE_PROGRAM_EXPECT expect_res)
  EXECUTE_PROCESS(COMMAND ${ARGN} RESULT_VARIABLE res)
  IF (NOT res EQUAL ${expect_res})
    MESSAGE(FATAL_ERROR "${ARGN} failed: " ${res})
  ENDIF()
ENDMACRO()
MACRO(CBMCONVERT)
  EXECUTE_PROGRAM(${CBMCONVERT} ${ARGV})
ENDMACRO()

FILE(REMOVE empty.prg empty.d64 empty.c2n
  e empty.p00 empty.lnx emptz.d64 1!empty 2!empty 3!empty 4!empty)

EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -C)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -L)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -M)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -m)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -a -k -t -z)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -L empty.lnx -M)

EXECUTE_PROGRAM_EXPECT(2 ${CBMCONVERT} -vw -D4 empty.d64 empty.prg)
MD5SUM(274f94a63ada0913cf717677e536cdf9 empty.d64)
FILE(WRITE empty.prg "")
EXECUTE_PROGRAM_EXPECT(2 ${CBMCONVERT} -D4 empty.prg)
EXECUTE_PROGRAM_EXPECT(2 ${CBMCONVERT} -D7 empty.prg)
EXECUTE_PROGRAM_EXPECT(2 ${CBMCONVERT} -D8 empty.prg)
FILE(WRITE empty.p00 "")
EXECUTE_PROGRAM_EXPECT(4 ${CBMCONVERT} -p empty.p00)
FILE(WRITE empty.p00 "26 octets invalid contents")
EXECUTE_PROGRAM_EXPECT(4 ${CBMCONVERT} -p empty.p00)
FILE(REMOVE empty.p00)
FILE(WRITE e "")
EXECUTE_PROGRAM_EXPECT(4 ${CBMCONVERT} -p e)
FILE(REMOVE e)
CBMCONVERT(-v1 -D4 empty.d64 empty.prg)
MD5SUM(b92a237dc6356940542593037d2184cf empty.d64)
CBMCONVERT(-v2 -L empty.lnx -d -- empty.d64)
MD5SUM(67715c3da9c4c73168d2e7177ea25545 empty.lnx)
CBMCONVERT(-vv -P -l empty.lnx)
MD5SUM(34dca27bbc851ac44ca0817dabeb9593 empty.p00)
EXECUTE_PROGRAM_EXPECT(4 ${CBMCONVERT} -v0 -P -l empty.prg)
EXECUTE_PROGRAM_EXPECT(1 ${CBMCONVERT} -vi -P -l empty.prg)
CBMCONVERT(-vv -C empty.c2n empty.prg)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files empty.c2n empty.prg)
CBMCONVERT(-N -c empty.c2n)

EXECUTE_PROGRAM_EXPECT(1 ${DISK2ZIP} -i 0 empty.d64 empty)
EXECUTE_PROGRAM_EXPECT(1 ${DISK2ZIP} -i 00000 empty.d64 empty)
EXECUTE_PROGRAM_EXPECT(1 ${DISK2ZIP} -i0000 empty.d64 empty)
EXECUTE_PROGRAM(${DISK2ZIP} -i 0000 -- empty.d64 empty)

IF (CMAKE_VERSION VERSION_GREATER_EQUAL 3.19)
  FILE(CHMOD 4!empty PERMISSIONS OWNER_READ)
  EXECUTE_PROCESS(COMMAND ${DISK2ZIP} empty.d64 empty RESULT_VARIABLE res)
  IF (res EQUAL 0)
    MESSAGE("skipping permission tests")
  ELSEIF (NOT res EQUAL 3)
    MESSAGE(FATAL_ERROR "${DISK2ZIP} empty.d64 empty failed: " ${res})
  ELSE()
    FILE(CHMOD 3!empty PERMISSIONS OWNER_READ)
    EXECUTE_PROGRAM_EXPECT(3 ${DISK2ZIP} empty.d64 empty)
    FILE(CHMOD 2!empty PERMISSIONS OWNER_READ)
    EXECUTE_PROGRAM_EXPECT(3 ${DISK2ZIP} empty.d64 empty)
    FILE(CHMOD 1!empty PERMISSIONS OWNER_READ)
    EXECUTE_PROGRAM_EXPECT(3 ${DISK2ZIP} empty.d64 empty)
    FILE(CHMOD empty.d64 PERMISSIONS OWNER_READ)
    EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty)
  ENDIF()
  FILE(REMOVE 1!empty 2!empty 3!empty 4!empty)
  FILE(CHMOD empty.d64 PERMISSIONS OWNER_WRITE OWNER_READ)
ENDIF()

EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty e.d64)
EXECUTE_PROGRAM_EXPECT(3 ${DISK2ZIP} -- - empty)
EXECUTE_PROGRAM_EXPECT(4 ${DISK2ZIP} - empty INPUT_FILE empty.prg)
EXECUTE_PROGRAM_EXPECT(4 ${DISK2ZIP} empty.prg empty)

EXECUTE_PROGRAM(${DISK2ZIP} empty.d64 ././././././empty)
MD5SUM(0c66b6561fb968faeb751eb94a68098b 1!empty)
MD5SUM(ef4bae7508940492d5452b4f13965cab 2!empty)
MD5SUM(026a1e36d2b20820920922d907394cf5 3!empty)
MD5SUM(0cae9f355cf09bc153272c4b8d2b97cd 4!empty)

EXECUTE_PROGRAM(${ZIP2DISK} ././empty e.d64)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files empty.d64 e.d64)
EXECUTE_PROGRAM(${ZIP2DISK} ./empty)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files empty.d64 e.d64)
FILE(RENAME 4!empty 4!e)
EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty fail.d64)
FILE(WRITE 4!empty "")
EXECUTE_PROGRAM_EXPECT(4 ${ZIP2DISK} empty fail.d64)
FILE(RENAME 3!empty 3!e)
EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty fail.d64)
FILE(WRITE 3!empty "")
EXECUTE_PROGRAM_EXPECT(4 ${ZIP2DISK} empty fail.d64)
FILE(RENAME 2!empty 2!e)
EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty fail.d64)
FILE(WRITE 2!empty "")
EXECUTE_PROGRAM_EXPECT(4 ${ZIP2DISK} empty fail.d64)
FILE(RENAME 1!empty 1!e)
EXECUTE_PROGRAM_EXPECT(3 ${ZIP2DISK} empty fail.d64)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files fail.d64 empty.prg)
FILE(WRITE 1!empty "")
EXECUTE_PROGRAM_EXPECT(4 ${ZIP2DISK} empty fail.d64)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files fail.d64 empty.prg)
EXECUTE_PROGRAM(${ZIP2DISK} e empty.d64)
EXECUTE_PROGRAM(${CMAKE_COMMAND} -E compare_files empty.d64 e.d64)

FILE(REMOVE empty.prg empty.d64 empty.c2n empty.p00 empty.lnx e.d64 fail.d64
  1!empty 2!empty 3!empty 4!empty 1!e 2!e 3!e 4!e)
