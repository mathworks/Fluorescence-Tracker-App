% Open Scripts Project Shortcut
cd( fileparts( mfilename( "fullpath" ) ) )
files = dir( "*.mlx" );
files = {files.name};
edit( files{:} )