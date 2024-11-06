% Open Scripts Project Shortcut
cd( fileparts( mfilename( "fullpath" ) ) )
files = dir( "*.mlx" );
files = flip( {files.name} );
edit( files{:} )