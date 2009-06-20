/*
 * Valadoc - a documentation tool for vala.
 * Copyright (C) 2008 Florian Brosch
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

using GLib.Path;
using Valadoc;
using Config;
using GLib;
using Gee;



public class ValaDoc : Object {
	private static string basedir = null;
	private static string directory = null;
	private static string pkg_name = null;
	private static string pkg_version = null;

	private static bool add_inherited = false;
	private static bool _protected = false;
	private static bool with_deps = false;
	private static bool _private = false;
	private static bool version;

	private static string pluginpath;

	private static bool non_null_experimental = false;
	private static bool disable_checking;
	private static bool force = false;


	[CCode (array_length = false, array_null_terminated = true)]
	private static string[] vapi_directories;
	[CCode (array_length = false, array_null_terminated = true)]
	private static string[] tsources;
	[CCode (array_length = false, array_null_terminated = true)]
	private static string[] tpackages;

	private const GLib.OptionEntry[] options = {
		{ "vapidir", 0, 0, OptionArg.FILENAME_ARRAY, ref vapi_directories, "Look for package bindings in DIRECTORY", "DIRECTORY..." },
		{ "pkg", 0, 0, OptionArg.STRING_ARRAY, ref tpackages, "Include binding for PACKAGE", "PACKAGE..." },
		{ "directory", 'o', 0, OptionArg.FILENAME, ref directory, "Output directory", "DIRECTORY" },
		{ "protected", 0, 0, OptionArg.NONE, ref _protected, "Adds protected elements to documentation", null },
		{ "private", 0, 0, OptionArg.NONE, ref _private, "Adds private elements to documentation", null },
		{ "inherit", 0, 0, OptionArg.NONE, ref add_inherited, "Adds inherited elements to a class", null },
		{ "deps", 0, 0, OptionArg.NONE, ref with_deps, "Adds packages to the documentation", null },
		{ "enable-non-null-experimental", 0, 0, OptionArg.NONE, ref non_null_experimental, "Enable experimentalenhancements for non-null types", null },
		{ "doclet", 0, 0, OptionArg.STRING, ref pluginpath, "plugin", "Name of an included doclet or path to custom doclet" },
		{ "package-name", 0, 0, OptionArg.STRING, ref pkg_name, "package name", "DIRECTORY" },
		{ "package-version", 0, 0, OptionArg.STRING, ref pkg_version, "package version", "DIRECTORY" },
		{ "force", 0, 0, OptionArg.NONE, ref force, "force", null },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref tsources, null, "FILE..." },
		{ null }
	};

	private static int quit ( ErrorReporter reporter ) {
		if ( reporter.errors == 0) {
			stdout.printf ("Succeeded - %d warning(s)\n", reporter.warnings );
			return 0;
		}
		else {
			stdout.printf ("Failed: %d error(s), %d warning(s)\n", reporter.errors, reporter.warnings );
			return 1;
		}
	}

	private static bool check_pkg_name () {
		if ( pkg_name == null )
			return true;

		if ( pkg_name == "glib-2.0" || pkg_name == "gobject-2.0" )
			return false;

		foreach (string package in tsources ) {
			if ( pkg_name == package )
				return false;
		}
		return true;
	}

	private string get_pkg_name ( ) {
		if ( this.pkg_name == null ) {
			if ( this.directory.has_suffix ( "/" ) )
				this.pkg_name = GLib.Path.get_dirname ( this.directory );
			else
				this.pkg_name = GLib.Path.get_basename ( this.directory );
		}

		return this.pkg_name;
	}


	private int run ( ErrorReporter reporter ) {
		var settings = new Valadoc.Settings ( );
		settings.pkg_name = this.get_pkg_name ( );
		settings.pkg_version = this.pkg_version;
		settings.add_inherited = this.add_inherited;
		settings._protected = this._protected;
		settings.with_deps = this.with_deps;
		settings._private = this._private;
		settings.path = realpath ( this.directory );
		
		string fulldirpath = "";
		if ( pluginpath == null ) {
			pluginpath = build_filename ( Config.plugin_dir, "html" );
		} else if ( is_absolute ( pluginpath ) == false ) {
			/* 
		   * Test to see if the plugin exists in the expanded path and then fallback
		   * to using the configured plugin directory
		   */
			string local_path = build_filename ( Environment.get_current_dir(),
				pluginpath);
		  if ( FileUtils.test( local_path, FileTest.EXISTS ) ) {
		  	fulldirpath = local_path;
		  } else {
		    fulldirpath = build_filename ( Config.plugin_dir, pluginpath );
	    }
		} else {
		  fulldirpath = pluginpath;
	  }
		ModuleLoader modules = new ModuleLoader ();
		bool tmp = modules.load ( fulldirpath );
		if ( tmp == false ) {
			reporter.simple_error ( "failed to load plugin" );
			return quit ( reporter );
		}

		Valadoc.Parser docparser = new Valadoc.Parser ( settings, reporter, modules );
		Valadoc.Tree doctree = new Valadoc.Tree ( reporter, settings, non_null_experimental, disable_checking, basedir, directory );

		if (!doctree.add_external_package ( vapi_directories, "glib-2.0" )) {
			reporter.simple_error ( "glib-2.0 not found in specified Vala API directories" );
			return quit ( reporter );
		}

		if (!doctree.add_external_package ( vapi_directories, "gobject-2.0" )) {
			reporter.simple_error ( "gobject-2.0 not found in specified Vala API directories" );
			return quit ( reporter );
		}

		if ( this.tpackages != null ) {
			foreach (string package in this.tpackages ) {
				if (!doctree.add_external_package ( vapi_directories, package )) {
					reporter.simple_error ( "%s not found in specified Vala API directories".printf(package) );
					return quit ( reporter );
				}
			}
			this.tpackages = null;
		}

		if ( tsources != null ) {
			foreach ( string src in tsources ) {
				if ( !doctree.add_file ( src ) ) {
					reporter.simple_error ( "%s not found".printf(src) );
					return quit ( reporter );
				}
			}
			tsources = null;
		}

		if ( !doctree.create_tree( ) )
			return quit ( reporter );

		doctree.parse_comments ( docparser );
		if ( reporter.errors > 0 )
			return quit ( reporter );

		doctree.visit ( modules.doclet );
		return quit ( reporter );
	}

	private static bool remove_directory ( string rpath ) {
		try {
			GLib.Dir dir = GLib.Dir.open ( rpath );
			if ( dir == null )
				return false;

			for ( weak string entry = dir.read_name(); entry != null ; entry = dir.read_name() ) {
				string path = rpath + entry;

				bool is_dir = GLib.FileUtils.test ( path, GLib.FileTest.IS_DIR );
				if ( is_dir == true ) {
					bool tmp = remove_directory ( path );
					if ( tmp == false ) {
						return false;
					}
				}
				else {
					int tmp = GLib.FileUtils.unlink ( path );
					if ( tmp > 0 ) {
						return false;
					}
				}
			}
		}
		catch ( GLib.FileError err ) {
			return false;
		}

		return true;
	}

	static int main ( string[] args ) {
		ErrorReporter reporter = new ErrorReporter();
    
		try {
			var opt_context = new OptionContext ("- Vala Documentation Tool");
			opt_context.set_help_enabled (true);
			opt_context.add_main_entries (options, null);
			opt_context.parse ( ref args);
		}
		catch (OptionError e) {
			reporter.simple_error ( e.message );
			stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			return quit ( reporter );
		}

		if ( version ) {
			stdout.printf ("Valadoc %s\n", "0.1" );
			return quit ( reporter );
		}

		if ( directory == null ) {
			reporter.simple_error ( "No output directory specified." );
			return quit ( reporter );
		}
        
		if ( !check_pkg_name () ) {
			reporter.simple_error ( "File allready exists" );
			return quit ( reporter );
		}

		if ( FileUtils.test ( directory, FileTest.EXISTS ) ) {
			if ( force == true ) {
				bool tmp = remove_directory ( directory );
				if ( tmp == false ) {
					reporter.simple_error ( "Can't remove directory." );
					return quit ( reporter );
				}
			}
			else {
				reporter.simple_error ( "File allready exists" );
				return quit ( reporter );
			}
		}

		var valadoc = new ValaDoc( );
		return valadoc.run ( reporter );
	}
}

