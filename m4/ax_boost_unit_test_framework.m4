# ===========================================================================
#  http://www.nongnu.org/autoconf-archive/ax_boost_unit_test_framework.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_BOOST_UNIT_TEST_FRAMEWORK
#
# DESCRIPTION
#
#   Test for Unit_Test_Framework library from the Boost C++ libraries. The
#   macro requires a preceding call to AX_BOOST_BASE. Further documentation
#   is available at <http://randspringer.de/boost/index.html>.
#
#   This macro calls:
#
#     AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB)
#
#   And sets:
#
#     HAVE_BOOST_UNIT_TEST_FRAMEWORK
#
# LICENSE
#
#   Copyright (c) 2008 Thomas Porschberg <thomas@randspringer.de>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.

AC_DEFUN([AX_BOOST_UNIT_TEST_FRAMEWORK],
[
        AC_ARG_WITH([boost-unit-test-framework],
        AS_HELP_STRING([--with-boost-unit-test-framework@<:@=special-lib@:>@],
                       [use the Unit_Test_Framework library from boost - it is possible to specify a certain library for the linker
                        e.g. --with-boost-unit-test-framework=boost_unit_test_framework-gcc ]),
        [
        if test "$withval" = "no"; then
                want_boost="no"
        elif test "$withval" = "yes"; then
                want_boost="yes"
                ax_boost_user_unit_test_framework_lib=""
        else
                want_boost="yes"
                ax_boost_user_unit_test_framework_lib="$withval"
        fi
        ],
        [want_boost="yes"]
        )

        if test "x$want_boost" = "xyes"; then
                AC_REQUIRE([AC_PROG_CC])

                CPPFLAGS_SAVED="$CPPFLAGS"
                CPPFLAGS="$CPPFLAGS $BOOST_CPPFLAGS"
                export CPPFLAGS

                LDFLAGS_SAVED="$LDFLAGS"
                LDFLAGS="$LDFLAGS $BOOST_LDFLAGS"
                export LDFLAGS

                AC_CACHE_CHECK(whether the Boost::Unit_Test_Framework library is available,
                               ax_cv_boost_unit_test_framework,
                               [AC_LANG_PUSH([C++])
                                AC_COMPILE_IFELSE(AC_LANG_PROGRAM([[@%:@include <boost/test/unit_test.hpp>]],
                                                                  [[using boost::unit_test::test_suite;
                                                                    test_suite* test= BOOST_TEST_SUITE( "Unit test example 1" );
                                                                    return 0;]]),
                                                                  ax_cv_boost_unit_test_framework=yes, ax_cv_boost_unit_test_framework=no)
                                AC_LANG_POP([C++])
                ])

                if test "x$ax_cv_boost_unit_test_framework" = "xyes"; then
                        AC_DEFINE(HAVE_BOOST_UNIT_TEST_FRAMEWORK,,[define if the Boost::Unit_Test_Framework library is available])

                        if test "x$ax_boost_user_unit_test_framework_lib" = "x"; then
                                BOOSTLIBDIR=`echo $BOOST_LDFLAGS | sed -e 's/@<:@^\/@:>@*//'`

                                for libext in so dylib a dll lib; do
                                        ax_lib_files=`ls $BOOSTLIBDIR/libboost_unit_test_framework*.${libext}* | \
                                                      sed -e "s;.*lib\(boost_unit_test_framework.*\).${libext}.*$;\1;"`
                                        for ax_lib in $ax_lib_files; do
                                                AC_CHECK_LIB($ax_lib, exit,
                                                             [BOOST_UNIT_TEST_FRAMEWORK_LIB="-l$ax_lib"; AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB) link_unit_test_framework="yes"; break 2],
                                                             [link_unit_test_framework="no"])
                                        done
                                done
                        else
                                for ax_lib in boost_unit_test_framework-$ax_boost_user_unit_test_framework_lib $ax_boost_user_unit_test_framework_lib; do
                                        AC_CHECK_LIB($ax_lib, exit,
                                                     [BOOST_UNIT_TEST_FRAMEWORK_LIB="-l$ax_lib"; AC_SUBST(BOOST_UNIT_TEST_FRAMEWORK_LIB) link_unit_test_framework="yes"; break],
                                                     [link_unit_test_framework="no"])
                                done
                        fi

                        if test "x$link_unit_test_framework" = "xno"; then
                                AC_MSG_ERROR(Could not link against $ax_lib !)
                        fi
                fi

                CPPFLAGS="$CPPFLAGS_SAVED"
                LDFLAGS="$LDFLAGS_SAVED"
        fi
])
