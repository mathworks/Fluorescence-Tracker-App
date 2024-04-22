% Open Scripts Project Shortcut
cd( fileparts( mfilename( "fullpath" ) ) )
files = flip( string( ls( "*.mlx" ) ) );
edit( files{:} )