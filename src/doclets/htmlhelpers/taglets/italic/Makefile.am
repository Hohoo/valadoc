NULL =


AM_CFLAGS =  -g                  \
	-I ../../../../libvaladoc/   \
	-I ../../doclet/             \
	$(GLIB_CFLAGS)               \
	$(LIBVALA_CFLAGS)            \
	$(NULL)


BUILT_SOURCES = libtagletitalic.vala.stamp


tagletitalicdir = $(libdir)/valadoc/plugins/htmlhelpers/taglets/


tagletitalic_LTLIBRARIES =    \
	libtagletitalic.la  \
	$(NULL)


libtagletitalic_la_VALASOURCES = \
	taglet.vala                  \
	$(NULL)


libtagletitalic_la_SOURCES =                \
	libtagletitalic.vala.stamp              \
	$(libtagletitalic_la_VALASOURCES:.vala=.c) \
	$(NULL)


libtagletitalic.vala.stamp: $(libtagletitalic_la_VALASOURCES)
	$(VALAC) -C --vapidir ../../../../vapi --pkg valadoc-1.0 --vapidir ../../doclet/ --pkg libhtmlhelpers-1.0 --basedir . $^
	touch $@


libtagletitalic_la_LDFLAGS = -module -avoid-version


libtagletitalic_la_LIBADD =              \
	../../../../libvaladoc/libvaladoc.la \
	$(LIBGVC_LIBS)                       \
	$(LIBVALA_LIBS)                      \
	$(GLIB_LIBS)                         \
	$(NULL)


EXTRA_DIST = $(libtagletitalic_la_VALASOURCES)  libtagletitalic.vala.stamp 


MAINTAINERCLEANFILES =                         \
	$(libtagletitalic_la_VALASOURCES:.vala=.c) \
	$(NULL)

