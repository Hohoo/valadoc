# src/Makefile.am



libtagletversion_VALASOURCES = \
	taglet.vala       \
	$(NULL)


BUILT_SOURCES = libtagletversion.vala.stamp


libtagletversion.vala.stamp: $(libtagletversion_VALASOURCES)
	$(VALAC) -C --vapidir ../../../htmlhelpers --pkg libhtmlhelpers-1.0 --vapidir ../../../../vapi --pkg valadoc-1.0 --vapidir ../../linkhelper --pkg libhtmlhelper-1.0 --basedir . --disable-non-null --save-temps $^
	touch $@


	

tagletversiondir = $(libdir)/valadoc/plugins/valadoc.org/taglets/

tagletversion_LTLIBRARIES = libtagletversion.la


libtagletversion_la_SOURCES =                \
	libtagletversion.vala.stamp              \
	$(libtagletversion_VALASOURCES:.vala=.c) \
	$(libtagletversion_VALASOURCES:.vala=.h) \
	$(NULL)



AM_CFLAGS =  -g               \
	-I ../../../../libvaladoc/   \
	-I ../../../htmlhelpers/     \
	-I ../../linkhelper/         \
	-I ../../                    \
	$(GLIB_CFLAGS)            \
	$(LIBVALA_CFLAGS)         \
	$(NULL)


libtagletversion_la_LDFLAGS = -module -avoid-version


libtagletversion_la_LIBADD =                 \
	../../../../libvaladoc/libvaladoc.la \
	../../linkhelper/libhtmlhelper.la    \
	$(GLIB_LIBS)                      \
	$(LIBVALA_LIBS)                   \
	$(NULL)




EXTRA_DIST = $(libtagletversion_VALASOURCES)  libtagletversion.vala.stamp 
