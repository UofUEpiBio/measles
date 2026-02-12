
##  measles configure.ac
##

## require at least autoconf 2.69
AC_PREREQ([2.69])

## Process this file with autoconf to produce a configure script.
AC_INIT([measles],[0.1.0],[g.vegayon@gmail.com])

## Set R_HOME, respecting an environment variable if one is set
: ${R_HOME=$(R RHOME)}
if test -z "${R_HOME}"; then
    AC_MSG_ERROR([Could not determine R_HOME.])
fi

## Use R to set CXX and CXXFLAGS
CXX=$("${R_HOME}/bin/R" CMD config CXX)
if test -z "${CXX}"; then
    AC_MSG_ERROR([No C++ compiler is available])
fi
CXXFLAGS=$("${R_HOME}/bin/R" CMD config CXXFLAGS)

## Checking if the development version is being built
AC_MSG_CHECKING([whether to build the dev version])
epiworldname="epiworldR"
if test x"${EPI_DEV}" != x"" ; then
    epiworldname="epiworldRdev"
    AC_MSG_RESULT([yes])
else
    AC_MSG_RESULT([no])
fi

AC_SUBST([EPIWORLD_NAME], ["${epiworldname}"])
AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
